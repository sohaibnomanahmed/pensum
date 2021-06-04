import 'package:flutter/material.dart';
import 'package:leaf/deals/deals_page.dart';
import 'package:leaf/following/follow_provider.dart';
import 'package:leaf/following/widgets/follow_item.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
import 'package:provider/provider.dart';

class FollowList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final follows = context.watch<FollowProvider>().follows;
    final isLoading = context.watch<FollowProvider>().isLoading;
    final isError = context.watch<FollowProvider>().isError;
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : isError
            ? LeafError(context.read<FollowProvider>().reFetchFollows)
            : ListView.builder(
                itemBuilder: (_, index) => InkWell(
                  onTap: () async {
                    final book = await context
                        .read<FollowProvider>()
                        .getFollowedBook(follows[index].pid);
                    context
                        .read<FollowProvider>()
                        .removeFollowingNotification(follows[index].pid);
                    // TODO what if firebase dont find book null occurs?? test
                    // navigate to books page
                    await Navigator.of(context).pushNamed(
                      DealsPage.routeName,
                      arguments: book,
                    );
                  },
                  child: FollowItem(follows[index]),
                ),
                itemCount: follows.length,
              );
  }
}
