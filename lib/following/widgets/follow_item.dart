import 'package:flutter/material.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import 'package:leaf/following/follow_provider.dart';
import 'package:leaf/following/models/Follow.dart';

class FollowItem extends StatelessWidget {
  final Follow follow;

  const FollowItem({Key? key, required this.follow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return ListTile(
      leading: Container(
        height: 90,
        width: 50,
        child: Hero(
          tag: follow.pid,
          child: Image.network(
            follow.image,
            errorBuilder: (_, __, ___) => Icon(
              Icons.wifi_off_rounded,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ),
      title: Text(follow.title),
      subtitle: Text(follow.year),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (follow.notification)
            CircleAvatar(
                radius: 5, backgroundColor: Theme.of(context).backgroundColor),
          IconButton(
            icon:
                Icon(Icons.delete_rounded, color: Theme.of(context).errorColor),
            onPressed: () => onPressHandler(
              context: context,
              action: () async =>
                  await context.read<FollowProvider>().unfollow(follow.pid),
              errorMessage: loc.getTranslatedValue('unfollow_error_msg_text'),
              successMessage: loc.getTranslatedValue('unfollow_success_msg_text'),
            ),
          ),
        ],
      ),
    );
  }
}
