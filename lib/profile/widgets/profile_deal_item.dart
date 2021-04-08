import 'package:flutter/material.dart';
import 'package:leaf/deals/deals_provider.dart';
import 'package:leaf/deals/widgets/add_deal_bottom_sheet.dart';
import 'package:leaf/profile/profile_provider.dart';
import 'package:provider/provider.dart';

import '../../deals/models/deal.dart';

class ProfileDealItem extends StatelessWidget {
  final Deal deal;

  ProfileDealItem(this.deal);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          leading: Container(
            height: 90,
            width: 50,
            child: Hero(
              tag: deal.pid,
              child: Image.network(
                deal.productImage,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.wifi_off_rounded,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child:
                      Text(deal.productTitle, overflow: TextOverflow.ellipsis)),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                onPressed: () => showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => DealsProvider(),
                    child: AddDealBottomSheet(
                      pid: deal.pid,
                      productImage: deal.productImage,
                      productTitle: deal.productTitle,
                      deal: deal,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_rounded,
                    color: Theme.of(context).errorColor),
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final errorColor = Theme.of(context).errorColor;
                  final primaryColor = Theme.of(context).primaryColor;
                  final result =
                      await context.read<ProfileProvider>().deleteDeal(
                            productId: deal.pid,
                            id: deal.id,
                          );
                  if (!result) {
                    // remove snackbar if existing and show a new with error message
                    final errorMessage =
                        context.read<DealsProvider>().errorMessage;
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
                        content: Text('Succesfully deleted the deal'),
                      ),
                    );
                  }
                },
              ),
            ],
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
