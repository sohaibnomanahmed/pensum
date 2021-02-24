import 'package:flutter/material.dart';
import 'package:leaf/chat/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  final String rid;
  final String receiverName;
  final String receiverImage;

  const ChatPage({this.rid, this.receiverName, this.receiverImage});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().fetchMessages(widget.rid);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChatProvider>().isLoading;
    final isError = context.watch<ChatProvider>().isError;
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName),),
    );
  }
}
