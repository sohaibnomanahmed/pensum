import 'package:flutter/material.dart';
import 'package:leaf/follow/follow_provider.dart';
import 'package:leaf/follow/widgets/follow_item.dart';
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
                itemBuilder: (_, index) => FollowItem(follows[index]),
                itemCount: follows.length,
              );
  }
}
