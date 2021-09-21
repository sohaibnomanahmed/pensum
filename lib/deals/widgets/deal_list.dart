import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/leaf_image.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import 'deal_item.dart';
import '../deals_provider.dart';

class DealList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deals = context.watch<DealsProvider>().deals;
    final loc = Localization.of(context);
    return deals.isEmpty
        ? LeafImage(
              assetImage: 'assets/images/empty_street.png',
              text: loc.getTranslatedValue('empty_list_msg_text'),
            )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) => DealItem(deal: deals[index]),
            itemCount: deals.length,
          );
  }
}
