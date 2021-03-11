import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leaf/follow/follow_provider.dart';
import 'package:leaf/follow/models/Follow.dart';

class FollowItem extends StatelessWidget {
  final Follow follow;

  FollowItem(this.follow);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 90,
        width: 50,
        child: Image.network(
          follow.image,
          errorBuilder: (_, __, ___) => Icon(
            Icons.wifi_off_rounded,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
      title: Text(follow.title),
      subtitle: Text(follow.year),
      trailing: IconButton(
        icon: Icon(Icons.delete_rounded, color: Theme.of(context).errorColor),
        onPressed: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final errorColor = Theme.of(context).errorColor;
          final primaryColor = Theme.of(context).primaryColor;
          final result =
              await context.read<FollowProvider>().unfollow(follow.id);
          if (!result) {
            // remove snackbar if existing and show a new with error message
            final errorMessage = context.read<FollowProvider>().errorMessage;
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(
                backgroundColor: errorColor,
                content: Text(errorMessage),
              ),
            );
          }
          if (result) {
            // remove snackbar if existing and show a new with error message
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(
                backgroundColor: primaryColor,
                content: Text('Succesfully unfollowed'),
              ),
            );
          }
        },
      ),
    );
  }
}
