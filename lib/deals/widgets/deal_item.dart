import 'package:flutter/material.dart';

import '../../messages/messages_page.dart';
import '../models/deal.dart';

class DealItem extends StatelessWidget {
  final Deal deal;

  DealItem(this.deal);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(deal.userImage)),
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
              Text(deal.quality)
            ],
          ),
          trailing: IconButton(
            splashColor: Theme.of(context).backgroundColor,
            icon:
                Icon(Icons.send_rounded, color: Theme.of(context).primaryColor),
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
