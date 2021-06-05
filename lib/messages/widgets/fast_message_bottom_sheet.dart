import 'package:flutter/material.dart';

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
              title: Text('Send fast message to:'),
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