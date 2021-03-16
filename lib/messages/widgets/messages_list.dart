import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../messages_provider.dart';
import '../widgets/message_bubble.dart';

class MessagesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final messages = context.watch<MessagesProvider>().messages;
    // TODO scroll down on new message
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        reverse: true,
        itemBuilder: (_, index) => MessageBubble(messages[index]),
        itemCount: messages.length,
      ),
    );
  }
}
