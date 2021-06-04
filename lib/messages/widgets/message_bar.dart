import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/global/functions.dart';
import 'package:leaf/messages/widgets/message_action_sheet.dart';
import 'package:provider/provider.dart';

import '../messages_provider.dart';

class MessageBar extends StatefulWidget {
  final String rid;
  final String receiverName;
  final String receiverImage;

  const MessageBar({@required this.rid, @required this.receiverName, @required this.receiverImage});

  @override
  _MessageBarState createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final _controller = TextEditingController();
  var _message = '';

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
          prefixIcon: IconButton(
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
          suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: _message.isEmpty
                  ? null
                  : () async {
                      _controller.clear();
                      await ButtonFunctions.onPressHandler(
                          context: context,
                          action: () async => await context
                              .read<MessagesProvider>()
                              .sendMessage(
                                text: _message,
                                rid: widget.rid,
                                receiverName: widget.receiverName,
                                receiverImage: widget.receiverImage,
                              ),
                          errorMessage: 'Something went wrong!');
                      // we send message cant be set to empty before it is sent
                      _message = '';
                    }),
          hintText: 'Send a message...',
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor))),
      onChanged: (value) => setState(() => _message = value),
    );
  }
}
