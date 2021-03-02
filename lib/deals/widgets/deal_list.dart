import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'deal_item.dart';
import '../deals_provider.dart';

class DealList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deals = context.watch<DealsProvider>().deals;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) => DealItem(deals[index]),
      itemCount: deals.length,
    );
  }
}
