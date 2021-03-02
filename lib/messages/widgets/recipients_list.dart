import 'package:flutter/material.dart';
import 'package:leaf/messages/recipients_provider.dart';
import 'package:provider/provider.dart';

import 'package:leaf/messages/widgets/recipient_item.dart';

import '../messages_page.dart';

class RecipientsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipients = context.read<RecipientsProvider>().recipients;
    return ListView.builder(
      itemBuilder: (_, index) => InkWell(
        child: RecipientItem(recipients[index]),
        onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(
          MessagesPage.routeName,
          arguments: {
            'id': recipients[index].rid,
            'image': recipients[index].receiverImage,
            'name': recipients[index].receiverName,
          },
        ),
      ),
      itemCount: recipients.length,
    );
  }
}
