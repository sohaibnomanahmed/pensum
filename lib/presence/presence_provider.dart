import 'package:flutter/foundation.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/presence/presence_service.dart';

// class PresenceProvider with ChangeNotifier{
//   final _authenticationService = AuthenticationService();
//   final _presenceService = PresenceService();

//   // get connection status
//   Stream<dynamic> getUserPresenceStream(String uid){
//     return database.reference().child('presence').child(uid).onValue.map((event) {
//       final presenceData = event.snapshot.value;
//       print(presenceData);
//       if (presenceData['connections'] == null){
//         final lastSeen = DateTime.fromMillisecondsSinceEpoch(presenceData['lastOnline']);
//         return lastSeen;
//       }
//       return true;
//     });
//   }

// }