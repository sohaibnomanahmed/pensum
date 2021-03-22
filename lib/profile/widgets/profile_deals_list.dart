import 'package:flutter/material.dart';
import 'package:leaf/deals/deals_page.dart';
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
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (_, index) => InkWell(
          onTap: () async {
            final book = await context
                .read<ProfileProvider>()
                .getDealedBook(profileDeals[index].pid);
            if (book != null) {
              // navigate to books page
              await Navigator.of(context).pushNamed(
                DealsPage.routeName,
                arguments: book,
              );
            } else {
              // show error message
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              // remove snackbar if existing and show a new with error message
              scaffoldMessenger.hideCurrentSnackBar();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).errorColor,
                  content: Text('Something went wrong, please try again!'),
                ),
              );
            }
          },
          child: ProfileDealItem(profileDeals[index]),
        ),
        itemCount: profileDeals.length,
      ),
    );
  }
}
