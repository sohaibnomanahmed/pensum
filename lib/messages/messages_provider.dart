import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/images/image_picker_service.dart';
import 'package:leaf/images/image_upload_service.dart';
import 'package:leaf/location/google_map_service.dart';
import 'package:leaf/location/location_service.dart';
import 'package:leaf/messages/messages_service.dart';
import 'package:leaf/messages/recipients_service.dart';
import 'package:leaf/notifications/notification_service.dart';

import 'models/recipient.dart';
import 'models/message.dart';

class MessagesProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService();
  final _notificationService = NotificationService();
  final _messagesService = MessagesService();
  final _recipientService = RecipientsService();
  final _imageUploadService = ImageUploadService();
  final _imagePickerService = ImagePickerService();
  final _googleMapService = GoogleMapService();
  final _locationService = LocationService();

  final List<Message> _messages = [];
  final _pageSize = 10;
  var _isError = false;
  var _isLoading = true;
  var _silentLoading = false;
  var _subscription;

  // getters
  MessagesProvider get provider => this;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  List<Message> get messages => [..._messages];

  /*
   * Sets up a stream, reciving messages connected to a spesific user.
   * This stream is cancelled on error, isLoading is true from the getgo
   * and will be set to false, when the messages are comming through
   * the messages will also be set to seen, when loaded and added to the start of the list. 
   */
  void fetchMessages(String rid) async {
    // get original first batch of messages, should be called on build
    final user = _authenticationService.currentUser;
    final stream = _messagesService.fetchMessages(
        sid: user.uid, rid: rid, pageSize: _pageSize);
    _subscription = stream.listen((messages) {
      // if no messages are sent we return
      if (messages == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      const seenMap = {'seen': true};
      messages.reversed.toList().forEach((message) {
        message.isMe = message.sid == user.uid;
        // if not already loaded, add to _message list
        if (!_messages.contains(message)) {
          _messages.insert(0, message);
        }
        
        // change seen status if changed in the databse
        final index = _messages.indexOf(message);
        if (_messages[index].seen != message.seen){
          _messages[index].seen = message.seen;
        }
        
        // set message as seen for the sender i.e the other user
        if (!message.isMe){
          _messagesService.setSeen(id: message.id, sid: user.uid, rid: rid, message: seenMap);
        }
      });
      // set recipeint notification as false for receiver i.e one self
      const notificationMap = {'notification': false};
      _recipientService.setNotification(sid: user.uid, rid: rid, recipient: notificationMap);
      // remove notification 
      //firestoreService.notification.setChatNotification(user.uid, false);
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching messages: $error');
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }, cancelOnError: true);
  }

  /*
   *  reload messages when an error occurs, set loading and fetch the messages
   *  again by remaking the stream 
   */
  void refetchMessages(String rid) async {
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchMessages(rid);
  }

  /*
   * fetch more messages, if no more messages, return null. If more messages
   * add them at the end of the list, uses a silent loader to not be called
   * while loading messages. 
   */
  Future<void> fetchMoreMessages(String rid) async {
    if (_silentLoading == true) {
      return;
    }
    // set silent loader so taht this method does not get called again
    // Also silent so that the UI does not get updated
    _silentLoading = true;

    // get current user and messages
    final user = _authenticationService.currentUser;
    if (_messages.isEmpty) {
      // no messages loaded, no last document so need to return
      _silentLoading = false;
      return;
    }
    var moreMessages = await _messagesService.fetchMoreMessages(
        sid: user.uid, rid: rid, pageSize: _pageSize);
    if (moreMessages == null) {
      // no more documents need to return
      _silentLoading = false;
      return;
    }
    // set isMe boolean on all messages
    moreMessages.forEach((message) => message.isMe = message.sid == user.uid);
    // add them the end of the messages list
    _messages.addAll(moreMessages);
    print(_messages.length);
    // update UI wait for a sec to let it complate before setting silent loading to false
    notifyListeners();
    _silentLoading = false;
  }

  /*
   * Send message to a user, store the message for the sender and store the
   * recipient information for the sender, cloud functions will store the information
   * for the receiver. There should not be a loader, should feel like contant flow.
   * If successfull return true, if an error occurs return false 
   */
  Future<bool> sendMessage({
    @required String rid,
    @required String receiverName,
    @required String receiverImage,
    String text,
    String image,
    String address,
    double latitude,
    double longitude,
    String type = 'text',
    String messageText,
  }) async {
    final user = _authenticationService.currentUser;
    final time = Timestamp.now();

    // information about the receiver displayed for the sender
    // chat -- sender --> receiver
    final recipient = Recipient(
      rid: rid,
      time: time,
      notification: false,
      receiverImage: receiverImage,
      receiverName: receiverName,
      lastMessage: (messageText == null) ? text : messageText,
    );

    // my message should not be seen by the recipeint before he load them in
    final message = Message(
      sid: user.uid,
      rid: rid,
      text: text,
      image: image,
      address: address,
      latitude: latitude,
      longitude: longitude,
      time: time,
      type: type,
      seen: false,
    );
    try {
      await _messagesService.sendMessage(
          sid: user.uid, rid: rid, message: message, recipient: recipient);
    } catch (error) {
      print('Error sending message: $error');
      return false;
    }
    return true;
  }

  /*
   * Send image message to a user, pick a image, and upload it to storage
   * Then call sendMessage. There should not be a loader, should feel like contant flow.
   * If successfull return true, if an error occurs return false 
   */
  Future<bool> sendImage({
    @required ImageSource source,
    @required String rid,
    @required String receiverName,
    @required String receiverImage,
  }) async {
    try {
      // Choose image from image picker service
      final image = await _imagePickerService.pickImage(source);
      if (image == null) {
        return true;
      }
      // Upload image to firebase storage
      final imageUrl = await _imageUploadService.uploadChatMessageImage(image);
      // Upload image to firestore chat
      await sendMessage(
          image: imageUrl,
          rid: rid,
          receiverName: receiverName,
          receiverImage: receiverImage,
          messageText: 'You sent a image',
          type: 'image');
    } catch (error) {
      print('Error sending message: $error');
      return false;
    }
    return true;
  }

  /*
   * Send location message to a user, pick a location and get a address and image
   * Then call sendMessage. There should not be a loader, should feel like contant flow.
   * If successfull return true, if an error occurs return false 
   */
  Future<bool> sendLocation({
    @required bool currentLocation,
    @required String rid,
    @required String receiverName,
    @required String receiverImage,
    double latitude,
    double longitude
  }) async {
    try {
      // check if current location
      if (currentLocation){
        final location = await _locationService.getCurrentUserLocation();
        latitude = location.latitude;
        longitude = location.longitude;
      }
      // Get location address
      final address = await _googleMapService.getPlaceAddress(latitude: latitude, longitude: longitude);
      // Get location image
      final url = _googleMapService.generateLocationPreviewImage(latitude: latitude, longitude: longitude);
      // Upload image to firebase storage
      final image = await _imageUploadService.urlToFile(url);
      final imageUrl = await _imageUploadService.uploadChatMessageImage(image);
      // delete cached file
      await _imageUploadService.deleteLastCachedFile();
      // Upload image to firestore chat
      await sendMessage(
          image: imageUrl,
          rid: rid,
          receiverName: receiverName,
          receiverImage: receiverImage,
          address: address,
          latitude: latitude,
          longitude: longitude,
          messageText: 'You sent a location',
          type: 'location');
    } catch (error) {
      print('Error sending message: $error');
      return false;
    }
    return true;
  }

  /*
   * This method is mainly used in the chat page to unsubscribe from topics
   * unsubscribes from the chat topic of the user so that the notifications wont apear 
   */
  void unsubscribeFromChatNotifications() async{
    final user = _authenticationService.currentUser;
    await _notificationService.unsubscribeFromTopic(user.uid);
  }

  /*
   * This method is mainly used in the chat page to subscribe to a topics
   * subscribes to the chat topic of the user so that the notifications will apear
   */
  void subscribeToChatNotifications() async{
    final user = _authenticationService.currentUser;
    await _notificationService.subscribeToTopic(user.uid);
  }

  // dispose
  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}
