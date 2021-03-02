import 'package:flutter/material.dart';
import 'package:leaf/messages/models/recipient.dart';

class RecipientItem extends StatelessWidget {
  final Recipient _recipient;

  const RecipientItem(this._recipient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          CircleAvatar(backgroundImage: NetworkImage(_recipient.receiverImage)),
      title: Text(_recipient.receiverName),
      subtitle: Text(_recipient.lastMessage),    
    );
  }
}
