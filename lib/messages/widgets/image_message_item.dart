import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:leaf/images/photo_page.dart';
import 'package:leaf/messages/models/message.dart';

class ImageMessageItem extends StatelessWidget {
  final ImageMessage message;

  ImageMessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openBuilder: (_, __) => PhotoPage(message.image),
      closedBuilder: (_, __) => Image.network(
        message.image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.wifi_off_rounded,
            size: 60,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }
}
