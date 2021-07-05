import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/following/follow_provider.dart';
import 'package:leaf/following/widgets/follow_list.dart';
import 'package:leaf/global/widgets/paging_view.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  @override
  void initState() {
    super.initState();
    context.read<FollowProvider>().fetchFollows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: Icon(Icons.notifications_on_rounded, size: 45, color: Theme.of(context).splashColor),
        middle:
            Text('Following', style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).hintColor
            )),
      ),
      body: PagingView(
          action: () => 
                context.read<FollowProvider>().fetchMoreFollows(),
          child: FollowList()),
    );
  }
}
