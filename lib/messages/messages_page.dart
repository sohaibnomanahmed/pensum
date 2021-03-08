import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'messages_provider.dart';
import 'widgets/message_bar.dart';
import 'widgets/messages_list.dart';
import '../global/widgets/leaf_error.dart';

class MessagesPage extends StatefulWidget {
  static const routeName = '/chat';
  final String rid;
  final String receiverName;
  final String receiverImage;

  const MessagesPage({this.rid, this.receiverName, this.receiverImage});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MessagesProvider>().fetchMessages(widget.rid);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MessagesProvider>().isLoading;
    final isError = context.watch<MessagesProvider>().isError;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        elevation: 0,
      ),
      body: isError
          ? Center(
              child: LeafError(context.read<MessagesProvider>().refetchMessages, widget.rid))
          : isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(child: MessagesList()),
                      MessageBar(
                        rid: widget.rid,
                        receiverName: widget.receiverName,
                        receiverImage: widget.receiverImage,
                      )
                    ],
                  ),
              ),
    );
  }
}
