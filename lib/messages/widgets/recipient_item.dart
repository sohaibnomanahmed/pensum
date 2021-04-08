import 'package:flutter/material.dart';
import 'package:leaf/messages/models/recipient.dart';
import 'package:leaf/presence/widgets/presence_bubble.dart';

class RecipientItem extends StatelessWidget {
  final Recipient _recipient;

  const RecipientItem(this._recipient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: CircleAvatar(
                backgroundImage: NetworkImage(_recipient.receiverImage)),
          ),
          PresenceBubble(_recipient.rid, 18)
        ],
      ),
      title: Text(_recipient.receiverName),
      subtitle: Text(_recipient.lastMessage),
      trailing: _recipient.notification
          ? CircleAvatar(
              radius: 5, backgroundColor: Theme.of(context).backgroundColor)
          : null,
    );
  }
}
