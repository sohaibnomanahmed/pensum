import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:leaf/messages/messages_provider.dart';

class MessageActionSheet extends StatelessWidget {
  final String rid;
  final String receiverImage;
  final String receiverName;

  const MessageActionSheet({
    @required this.rid,
    @required this.receiverName,
    @required this.receiverImage,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<MessagesProvider>().sendImage(
                source: ImageSource.camera,
                rid: rid,
                receiverName: receiverName,
                receiverImage: receiverImage);
          },
          child: Text('Camera'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<MessagesProvider>().sendImage(
                source: ImageSource.gallery,
                rid: rid,
                receiverName: receiverName,
                receiverImage: receiverImage);
          },
          child: Text('Photo Library'),
        ),
        CupertinoActionSheetAction(
            onPressed: () {}, child: Text('Location')),
      ],
      cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel')),
    );
  }
}
