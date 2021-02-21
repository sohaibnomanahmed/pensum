import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_deal_item.dart';
import '../profile_provider.dart';

class ProfileDealsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileDeals = context.watch<ProfileProvider>().profileDeals;
    // list view puts on top padding if not app bar
    // https://github.com/flutter/flutter/issues/14842
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_,__) => Divider(),
        itemBuilder: (_, index) => ProfileDealItem(profileDeals[index]),
        itemCount: profileDeals.length,
      ),
    );
  }
}
