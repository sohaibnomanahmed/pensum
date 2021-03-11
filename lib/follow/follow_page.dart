import 'package:flutter/material.dart';
import 'package:leaf/follow/follow_provider.dart';
import 'package:leaf/follow/widgets/follow_list.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  @override
  void initState() {
    super.initState();
    context.read<FollowProvider>().fetchFollows;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            context.read<FollowProvider>().fetchMoreFollows;
          }
          return true;
        },
        child: FollowList()
      ),
    );
  }
}