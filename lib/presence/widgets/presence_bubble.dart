import 'package:flutter/material.dart';
import 'package:leaf/presence/widgets/timeago_flutter.dart';
import 'package:shimmer/shimmer.dart';
//import 'package:timeago_flutter/timeago_flutter.dart';

import 'package:leaf/presence/presence_service.dart';

/*
 * This widgets as a contrast to others talk directly to a service and not through
 * a provider, this is done since this widget is used in profile, chat list, deal list and
 * chat page and there is no need to send over the same stream through 4 different provider
 */
class PresenceBubble extends StatefulWidget {
  final String uid;
  final double size;

  PresenceBubble(this.uid, this.size);

  @override
  _PresenceBubbleState createState() => _PresenceBubbleState();
}

class _PresenceBubbleState extends State<PresenceBubble> {
  @override
  Widget build(BuildContext context) {
    /**
         * Stream builder with RTDB works a little bit different then Firestore
         * some documentation is in this medium article
         * https://medium.com/codechai/realtime-database-in-flutter-bef0f29e3378 
         */
    return StreamBuilder(
      stream: PresenceService().getUserPresenceStream(widget.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          // return shimmer
          return Shimmer.fromColors(
            highlightColor: Colors.white,
            baseColor: Colors.grey[300],
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: widget.size / 2,
            ),
          );
        }
        var presence = snap.data;

        if (presence == true) {
          return CircleAvatar(
            backgroundColor: Colors.green,
            radius: widget.size / 2,
          );
        } else {
          return Container(
            height: widget.size/1.2,
            decoration: BoxDecoration(
                color: Colors.amber[900],
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: FittedBox(
                  child: Timeago(
                builder: (_, value) => Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
                date: presence,
                refreshRate: Duration(minutes: 1),
                locale: 'en_short',
              )),
            ),
          );
        }
      },
    );
  }
}
