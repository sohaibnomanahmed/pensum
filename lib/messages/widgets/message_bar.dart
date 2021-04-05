import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/messages/widgets/message_action_sheet.dart';
import 'package:provider/provider.dart';

import '../messages_provider.dart';

class MessageBar extends StatefulWidget {
  final String rid;
  final String receiverName;
  final String receiverImage;

  const MessageBar({this.rid, this.receiverName, this.receiverImage});

  @override
  _MessageBarState createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final _controller = TextEditingController();
  var _message = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      prefix: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (ctx) => ChangeNotifierProvider.value(
                  value: context.read<MessagesProvider>().provider,
                  child: MessageActionSheet(
                    rid: widget.rid,
                    receiverName: widget.receiverName,
                    receiverImage: widget.receiverImage,
                  ),
                ),
              );
            },
          ),
          suffix: IconButton(
              icon: Icon(Icons.send),
              onPressed: _message.isEmpty
                  ? null
                  : () async {
                      _controller.clear();
                      final result =
                          await context.read<MessagesProvider>().sendMessage(
                                text: _message,
                                rid: widget.rid,
                                receiverName: widget.receiverName,
                                receiverImage: widget.receiverImage,
                              );
                      _message = '';
                      if (!result) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Something went wrong!'),
                          backgroundColor: Theme.of(context).errorColor,
                        ));
                      }
                    }),
      placeholder: 'Send a message...',
      onChanged: (value) => setState(() => _message = value),
    );
  }
}
