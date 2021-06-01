import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../messages_provider.dart';
import '../widgets/message_bubble.dart';

class MessagesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final messages = context.watch<MessagesProvider>().messages;
    final messageLoading = context.watch<MessagesProvider>().messageLoading;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              reverse: true,
              itemBuilder: (_, index) => MessageBubble(messages[index]),
              itemCount: messages.length,
            ),
          ),
          if (messageLoading)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ],
      ),
    );
  }
}
