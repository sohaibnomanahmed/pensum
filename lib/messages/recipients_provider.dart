import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/messages/recipients_service.dart';

import 'models/recipient.dart';

class RecipientsProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService();
  final _recipientsService = RecipientsService();

  List<Recipient> _recipients = [];
  final _pageSize = 10;
  var _isError = false;
  var _isLoading = true;
  var _silentLoading = false;
  var _subscription;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  List<Recipient> get recipients => [..._recipients];

  /*
   * Sets up a stream, reciving recipients connected to a spesific user.
   * This stream is cancelled on error, isLoading is true from the getgo
   * and will be set to false, when the recipients are comming through
   */
  void get fetchRecipients async {
    // get original first batch of messages, should be called on build
    final user = _authenticationService.currentUser;
    final stream =
        _recipientsService.fetchRecipients(sid: user.uid, pageSize: _pageSize);
    _subscription = stream.listen((recipients) {
      // if no recipients are sent we return
      if (recipients == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
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

  /*
   *  reload recipients when an error occurs, set loading and fetch the recipients
   *  again by remaking the stream 
   */
  void refetchRecipients() async {
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchRecipients;
  }

  /*
   * fetch more messages, if no more recipients, return null. If more recipients
   * add them at the end of the list, uses a silent loader to not be called
   * while loading recipients. 
   */
  Future<void> fetchMoreRecipients() async {
    if (_silentLoading == true) {
      return;
    }
    // set silent loader so that this method does not get called again
    // Also silent so that the UI does not get updated
    _silentLoading = true;

    // get current user and messages
    final user = _authenticationService.currentUser;
    if (_recipients.isEmpty) {
      // no recipients loaded, no last document so need to return
      _silentLoading = false;
      return;
    }
    var moreRecipients = await _recipientsService.fetchMoreRecipients(
        sid: user.uid, pageSize: _pageSize);
    if (moreRecipients == null) {
      // no more documents need to return
      _silentLoading = false;
      return;
    }
    // add them the end of the messages list
    _recipients.addAll(moreRecipients);
    // update UI wait for a sec to let it complate before setting silent loading to false
    notifyListeners();
    _silentLoading = false;
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
