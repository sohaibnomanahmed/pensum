import 'package:flutter/material.dart';
import 'package:leaf/localization/localization.dart';
import 'package:leaf/messages/messages_provider.dart';
import 'package:leaf/messages/widgets/fast_message_bottom_sheet.dart';
import 'package:leaf/presence/widgets/presence_bubble.dart';
import 'package:leaf/profile/profile_page.dart';
import 'package:provider/provider.dart';

import '../../messages/messages_page.dart';
import '../models/deal.dart';

class DealItem extends StatelessWidget {
  final Deal deal;

  const DealItem({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child:
                    CircleAvatar(backgroundImage: NetworkImage(deal.userImage)),
              ),
              PresenceBubble(deal.uid, PresenceBubble.smallSize)
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(deal.userName, overflow: TextOverflow.ellipsis)),
              Text(deal.price)
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(deal.place, overflow: TextOverflow.ellipsis)),
              Text(loc.getTranslatedValue(deal.quality))
            ],
          ),
          trailing: GestureDetector(
            onLongPress: () => showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0))),
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) => ChangeNotifierProvider(
                create: (context) => MessagesProvider(),
                child: FastMessageBottomSheet(
                  rid: deal.uid,
                  receiverName: deal.userName,
                  receiverImage: deal.userImage,
                ),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded,
                  color: Theme.of(context).primaryColor),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pushNamed(
                MessagesPage.routeName,
                arguments: {
                  'id': deal.uid,
                  'image': deal.userImage,
                  'name': deal.userName
                },
              ),
            ),
          ),
          onTap: () async {
                    // navigate to profile page
                    await Navigator.of(context, rootNavigator: true).pushNamed(
                      ProfilePage.routeName,
                      arguments: deal.uid,
                    );
                  },
        ),
        if (deal.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              deal.description,
              textAlign: TextAlign.start,
            ),
          )
      ],
    );
  }
}
