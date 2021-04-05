import 'package:animations/animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:leaf/images/photo_page.dart';
import 'package:leaf/location/map_page.dart';

import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble(this.message);

  @override
  Widget build(BuildContext context) {
    final date = message.time.toDate();
    final formattedDate = DateFormat('EEE d MMM kk:mm').format(date);
    // need row, since the list takes the full width the container with gets over-ruled
    return Row(
      mainAxisAlignment:
          message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: message.isMe
                ? Colors.grey[200]
                : Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft:
                  message.isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight:
                  !message.isMe ? Radius.circular(12) : Radius.circular(0),
            ),
          ),
          //width: 200,
          constraints: BoxConstraints(maxWidth: 200),
          padding: message.type != 'text'
              ? EdgeInsets.all(0)
              : EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: message.type != 'text'
                    ? EdgeInsets.all(8.0)
                    : EdgeInsets.all(0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formattedDate,
                        style: Theme.of(context).textTheme.caption),
                    SizedBox(width: 5),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 10,
                      color: message.seen
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).splashColor,
                    )
                  ],
                ),
              ),
              if (message.type == 'text') Text(message.text),
              if (message.type == 'image')
                OpenContainer(
                  openBuilder: (_, __) => PhotoPage(message.image),
                  closedBuilder: (_, __) => Image.network(
                    message.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              if (message.type == 'location')
                OpenContainer(
                  openBuilder: (_, __) => MapPage(
                    initialLocation: LatLng(message.latitude, message.longitude),
                  ),
                  closedBuilder: (_, __) => Image.network(
                    message.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                )  
            ],
          ),
        ),
      ],
    );
  }
}
