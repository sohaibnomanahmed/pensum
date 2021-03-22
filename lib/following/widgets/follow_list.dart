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
                    if (book != null) {
                      // navigate to books page
                      await Navigator.of(context).pushNamed(
                        DealsPage.routeName,
                        arguments: book,
                      );
                    } else {
                      // show error message
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      // remove snackbar if existing and show a new with error message
                      scaffoldMessenger.hideCurrentSnackBar();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).errorColor,
                          content:
                              Text('Something went wrong, please try again!'),
                        ),
                      );
                    }
                  },
                  child: FollowItem(follows[index]),
                ),
                itemCount: follows.length,
              );
  }
}
