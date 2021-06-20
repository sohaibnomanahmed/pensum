import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/messages/recipients_service.dart';

import 'models/recipient.dart';

class RecipientsProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService(FirebaseAuth.instance);
  final _recipientsService = RecipientsService();

  List<Recipient> _recipients = [];
  final _pageSize = 10;
  var _isError = false;
  var _isLoading = true;
  late var _subscription;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  List<Recipient> get recipients => [..._recipients];

  /// Subsbribe to the recipients stream, Should be called in the [init state] method of the page
  /// from where it is called, stores the result in [recipients] and stop [loading]
  /// if an error accours the stream will be canceled, and we will set [isError]
  void fetchRecipients() async {
    // get original first batch of messages, should be called on build
    final user = _authenticationService.currentUser!;
    final stream =
        _recipientsService.fetchRecipients(sid: user.uid, pageSize: _pageSize);
    _subscription = stream.listen((recipients) {
      _recipients = recipients;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching recipients: $error');
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }, cancelOnError: true);
  }

  /// refetch recipients when an error occurs, reset [loading] and [error]
  /// then call [fetchRecipients] again to remake the stream 
  void refetchRecipients() async {
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchRecipients();
  }

  /// fetch more recipients, starts with setting a [silent loader] so that the method does 
  /// not get called again. Check if [recipients] is empty or [isError] or [isSearch] is set
  /// add fetched recipients at the end of [recipients], catch errors if any and return
  Future<void> fetchMoreRecipients() async {
    // only get called one time and not on error screen
    // Aslo if no lastFollow to start from, needs to return
    if (_recipients.isEmpty || _isError) {
      return;
    }

    // get current user and messages
    final user = _authenticationService.currentUser!;
    List<Recipient> moreRecipients;
    try{
      moreRecipients = await _recipientsService.fetchMoreRecipients(
        sid: user.uid, pageSize: _pageSize);
    } catch(error){
      print('Error fetching more recipients $error');
      return;
    }
    
    // add them the end of the messages list
    _recipients.addAll(moreRecipients);
    notifyListeners();
  }

  /// Dispose when the provider is destroyed, cancel the recipients subscription
  @override
  void dispose() async {
    super.dispose();
    await _subscription.cancel();
  }
}
