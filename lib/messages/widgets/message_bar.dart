import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:leaf/messages/widgets/message_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../messages_provider.dart';

class MessageBar extends StatefulWidget {
  final String rid;
  final String receiverName;
  final String receiverImage;

  const MessageBar(
      {required this.rid,
      required this.receiverName,
      required this.receiverImage});

  @override
  _MessageBarState createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final _controller = TextEditingController();
  var _showMessageOptions = false;
  var _message = '';

  void _showOptions() {
    HapticFeedback.lightImpact();
    setState(() {
      _showMessageOptions = !_showMessageOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    // return TextField(
    //   controller: _controller,
    //   keyboardType: TextInputType.multiline,
    //   minLines: 1,
    //   maxLines: 5,
    //   decoration: InputDecoration(
    //       prefixIcon: IconButton(
    //         icon: Icon(Icons.add),
    //         onPressed: () {
    //           showBottomSheet(
    //             context: context,
    //             builder: (ctx) => ChangeNotifierProvider.value(
    //               value: context.read<MessagesProvider>().provider,
    //               child: MessageBottomSheet(
    //                 rid: widget.rid,
    //                 receiverName: widget.receiverName,
    //                 receiverImage: widget.receiverImage,
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    //       suffixIcon: IconButton(
    //           icon: Icon(Icons.send),
    //           onPressed: _message.isEmpty
    //               ? null
    //               : () async {
    //                   // we send message cant be set to empty before it is sent
    //                   final message = _message;
    //                   // set state to disable button
    //                   setState(() {
    //                     _message = '';
    //                   });
    //                   _controller.clear();
    //                   await onPressHandler(
    //                       context: context,
    //                       action: () async => await context
    //                           .read<MessagesProvider>()
    //                           .sendMessage(
    //                             text: message,
    //                             rid: widget.rid,
    //                             receiverName: widget.receiverName,
    //                             receiverImage: widget.receiverImage,
    //                           ),
    //                       errorMessage: loc.getTranslatedValue('error_msg'));
    //                 }),
    //       hintText: loc.getTranslatedValue('send_message_hint_text'),
    //       border: InputBorder.none,
    //       focusedBorder: UnderlineInputBorder(
    //           borderSide: BorderSide(color: Theme.of(context).primaryColor))),
    //   onChanged: (value) => setState(() => _message = value),
    // );
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                    _showMessageOptions ? Icons.cancel_sharp : Icons.add,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () => _showOptions()),
              Expanded(
                child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: loc.getTranslatedValue('send_message_hint_text'),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: Colors.grey[200]!, width: 1)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: Colors.grey[200]!, width: 1)),
                        contentPadding: EdgeInsets.all(10),
                        fillColor: Colors.grey[200],
                        filled: true,
                        isDense: true),
                    onChanged: (value) => setState(() {
                          _message = value;
                        })),
              ),
              IconButton(
                icon: Icon(Icons.send),
                color: Theme.of(context).primaryColorDark,
                onPressed: _message.trim().isEmpty ? null : () {
                  // we send message cant be set to empty before it is sent
    //                   final message = _message;
    //                   // set state to disable button
    //                   setState(() {
    //                     _message = '';
    //                   });
    //                   _controller.clear();
    //                   await onPressHandler(
    //                       context: context,
    //                       action: () async => await context
    //                           .read<MessagesProvider>()
    //                           .sendMessage(
    //                             text: message,
    //                             rid: widget.rid,
    //                             receiverName: widget.receiverName,
    //                             receiverImage: widget.receiverImage,
    //                           ),
    //                       errorMessage: loc.getTranslatedValue('error_msg'));
                },
              )
            ],
          ),
        ),
        AnimatedContainer(
          height: _showMessageOptions ? null : 0,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(seconds: 2),
          child: MessageBottomSheet(
              hideOptions: _showOptions,
              rid: widget.rid,
              receiverName: widget.receiverName,
              receiverImage: widget.receiverImage),
        ),
      ],
    );
  }
}
