import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/leaf_image.dart';
import 'package:provider/provider.dart';

import 'deal_item.dart';
import '../deals_provider.dart';

class DealList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deals = context.watch<DealsProvider>().deals;
    return deals.isEmpty
        ? LeafImage(
              assetImage: 'assets/images/empty_street.png',
              text: 'There are no deals yet',
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
