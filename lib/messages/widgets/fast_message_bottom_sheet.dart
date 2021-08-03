import 'package:flutter/material.dart';
import 'package:leaf/localization/localization.dart';

import 'message_bar.dart';

class FastMessageBottomSheet extends StatelessWidget {
  final String rid;
  final String receiverName;
  final String receiverImage;

  const FastMessageBottomSheet({
    required this.rid,
    required this.receiverImage,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return SafeArea(
          child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(receiverImage),
              ),
              title: Text(loc.getTranslatedValue('fast_message_title')),
              subtitle: Text(receiverName),
            ),
            MessageBar(
              rid: rid,
              receiverName: receiverName,
              receiverImage: receiverImage,
            )
          ],
        ),
      ),
    );
  }
}