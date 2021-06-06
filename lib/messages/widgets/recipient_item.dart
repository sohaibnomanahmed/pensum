import 'package:flutter/material.dart';
import 'package:leaf/messages/models/recipient.dart';
import 'package:leaf/presence/widgets/presence_bubble.dart';

class RecipientItem extends StatelessWidget {
  final Recipient recipient;

  const RecipientItem({Key? key, required this.recipient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: CircleAvatar(
                backgroundImage: NetworkImage(recipient.receiverImage)),
          ),
          PresenceBubble(recipient.rid, 18)
        ],
      ),
      title: Text(recipient.receiverName),
      subtitle: Text(recipient.lastMessage),
      trailing: recipient.notification
          ? CircleAvatar(
              radius: 5, backgroundColor: Theme.of(context).backgroundColor)
          : null,
    );
  }
}
