import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaf/messages/messages_page.dart';

import 'models/notifications.dart';
import '../global/services.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
}

class NotificationProvider with ChangeNotifier {
  final _authenticationService = FirebaseService.authentication;
  final _notificationsService = FirebaseService.notifications;

  Notifications _notifications;
  StreamSubscription _subscription;

  // getters
  Notifications get notifications => _notifications;

  /*
   * configure notifications to handle both foreground and background
   * messages, on foreground a flushbar is shown for the user to click and see 
   * notifications. On the data propery a type field is given to check if 
   * notification is a message or book aler. 
   */
  void configureNotifications(BuildContext context) async {
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
    if (initialMessage != null && initialMessage?.data['type'] == 'message') {
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
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // subscribe to own topic for chat messages
    final user = _authenticationService.currentUser;
    print('SUBSCRIBING!!!');
    await _notificationsService.subscribeToTopic(user.uid);
  }

  /*
   * Cancel suscription on dispose 
   */
  @override
  void dispose() {
    super.dispose();
    // TODO null here
    final user = _authenticationService.currentUser;
    _notificationsService.unsubscribeFromTopic(user.uid);
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}
