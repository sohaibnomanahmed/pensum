import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/messages/messages_page.dart';
import 'package:leaf/notifications/notification_service.dart';

import 'models/notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
}

class NotificationProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService();
  final _notificationsService = NotificationService();

  Notifications _notifications;
  StreamSubscription _subscription;
  StreamSubscription _followingNotificationSubscription;
  StreamSubscription _chatNotificationSubscription;
  var _followingNotification = false;
  var _chatNotification = false;

  // getters
  Notifications get notifications => _notifications;
  bool get followingNotification => _followingNotification;
  bool get chatNotification => _chatNotification;

  /*
   * configure notifications to handle both foreground and background
   * messages, on foreground a flushbar is shown for the user to click and see 
   * notifications. On the data propery a type field is given to check if 
   * notification is a message or book aler. 
   */
  void configureNotifications(BuildContext context, Function(int index) setCurrentIndex) async {
    var settings = await _notificationsService.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    // handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      if (message?.data['type'] == 'message') {
        final id = message.data['id'];
        final name = message.data['name'];
        final image = message.data['image'];
        final text = message.data['message'];
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: ListTile(
                contentPadding: EdgeInsets.all(0),
                dense: true,
                leading: CircleAvatar(backgroundImage: NetworkImage(image)),
                title: Text(name),
                subtitle: Text(text),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  Navigator.pushNamed(
                    context,
                    MessagesPage.routeName,
                    arguments: {'id': id, 'image': image, 'name': name},
                  );
                },
              )),
        );
      }
      if (message?.data['type'] == 'book') {
        //final id = message.data['id'];
        final title = message.data['title'];
        final image = message.data['image'];
        final text = message.data['message'];
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: ListTile(
                contentPadding: EdgeInsets.all(0),
                dense: true,
                leading: Container(
                  height: 90,
                  width: 50,
                  child: Image.network(
                    image,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.wifi_off_rounded,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                title: Text(title),
                subtitle: Text(text),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setCurrentIndex(3);
                },
              )),
        );
      }
    });

    // Get any messages which caused the application to open from
    // a terminated state.
    final initialMessage = await _notificationsService.getInitialMessage;

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      if (initialMessage?.data['type'] == 'message'){
        await Navigator.pushNamed(
          context,
          MessagesPage.routeName,
          arguments: {
            'id': initialMessage?.data['id'],
            'image': initialMessage?.data['image'],
            'name': initialMessage?.data['name']
          },
        );
      }
      if (initialMessage?.data['type'] == 'book'){
        setCurrentIndex(3);
      }
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'message') {
        Navigator.pushNamed(
          context,
          MessagesPage.routeName,
          arguments: {
            'id': initialMessage?.data['id'],
            'image': initialMessage?.data['image'],
            'name': initialMessage?.data['name']
          },
        );
      }
      if (message.data['type'] == 'book'){
        setCurrentIndex(3);
      }
    });

    // setup background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /*
   * get following notification stream, should only get value
   * no error check or cancelation
   */
  void get fetchFollowingNotification{
    // get original following notification indicator
    final user = _authenticationService.currentUser;
    final stream = _notificationsService.fetchFollowingNotification(user.uid);
    _followingNotificationSubscription = stream.listen(
      (followingNotification) {
        _followingNotification = followingNotification;
        notifyListeners();
      },
    );
  }

   /*
   * get following notification stream, should only get value
   * no error check or cancelation
   */
  void get fetchChatNotification{
    // get original following notification indicator
    final user = _authenticationService.currentUser;
    final stream = _notificationsService.fetchChatNotification(user.uid);
    _chatNotificationSubscription = stream.listen(
      (chatNotification) {
        _chatNotification = chatNotification;
        notifyListeners();
      },
    );
  }

  /*
   * Cancel suscription on dispose 
   */
  @override
  void dispose() async {
    super.dispose();
    if (_subscription != null) {
      await _subscription.cancel();
    }
    if (_chatNotificationSubscription != null){
      await _chatNotificationSubscription.cancel();
    }
    if (_followingNotificationSubscription != null){
      await _followingNotificationSubscription.cancel();
    }
  }
}
