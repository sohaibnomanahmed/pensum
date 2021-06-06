import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leaf/messages/recipients_provider.dart';
import 'package:leaf/messages/widgets/recipients_list.dart';

class RecipientsPage extends StatefulWidget {
  @override
  _RecipientsPageState createState() => _RecipientsPageState();
}

class _RecipientsPageState extends State<RecipientsPage>{
  @override
  void initState() {
    super.initState();
    context.read<RecipientsProvider>().fetchRecipients();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RecipientsProvider>().isLoading;
    final silentLoading = context.watch<RecipientsProvider>().silentLoading;
    return Scaffold(
        appBar: CupertinoNavigationBar(
        leading: Icon(Icons.forum_rounded, size: 50, color: Theme.of(context).splashColor,),
        middle:
            Text('Messages', style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).hintColor
            )),
      ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >
                                (scrollInfo.metrics.maxScrollExtent * 0.8)) {
                              if (!silentLoading){    
                                context
                                    .read<RecipientsProvider>()
                                    .fetchMoreRecipients();
                              }
                            }
                            return true;
                          },child: RecipientsList()));
  }
}
