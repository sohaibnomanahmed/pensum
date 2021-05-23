import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  FirebaseDatabase database = FirebaseDatabase.instance;
  StreamSubscription subscription;
  StreamSubscription subsub;
  DatabaseReference con;

  // Configure user presence
  Future<void> configureUserPresence(String uid) async {
    final myConnectionsRef =
        database.reference().child('presence').child(uid).child('connections');
    final lastOnlineRef =
        database.reference().child('presence').child(uid).child('lastOnline');

    // Needs to go back online if once gone offline i.g. logging out and inn
    await database.goOnline();    

    /*
      Need to have an extra listener just so, there some listener left after onDisconnect
      triggers, since if there are no listeners left, the listener to .info/connected
      will stop listening after 60 second and we have gotcha: remove wifi re add wifi
      more info on:
      https://stackoverflow.com/questions/47265074/firebase-listener-does-not-identify-or-resume-connection-after-idle-time
      https://stackoverflow.com/questions/53069484/firebase-realtime-database-info-connected-false-when-it-should-be-true
      https://firebase.googleblog.com/2013/06/how-to-build-presence-system.html
     */
    subsub = database
        .reference()
        .child('presence')
        .child(uid)
        .onValue
        .listen((event) {});

    subscription = database.reference().child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value) {
        // We're connected (or reconnected)! Do anything here that should happen only if online (or on reconnect)
        con = myConnectionsRef.push();
        
        // When I disconnect remove this device
        con.onDisconnect().remove();
        
        // Add this device to my connections list
        // this value could contain info about the device or a timestamp too
        con.set(true);
        
        // When I disconnect, update the last time I was seen online
        lastOnlineRef.onDisconnect().set(ServerValue.timestamp);
      }
    });
  }

  // Get connection status
  Stream<dynamic> getUserPresenceStream(String uid){
    return database.reference().child('presence').child(uid).onValue.map((event) {
      final presenceData = event.snapshot.value;
      if (presenceData['connections'] == null){
        final lastSeen = DateTime.fromMillisecondsSinceEpoch(presenceData['lastOnline']);
        return lastSeen;
      }
      return true;
    });
  }

  // Connect back to the firebase realtime database
  void connect(){
    database.goOnline();
  }

  // Remove connection for this device when signing out
  Future<void> disconnect({bool signout = false}) async {
    if (signout && subscription != null){
      await subscription.cancel();
      await subsub.cancel();
    }
    await database.goOffline();
  }
}
