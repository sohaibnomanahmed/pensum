import 'package:flutter/material.dart';
import 'package:leaf/deals/deals_provider.dart';
import 'package:leaf/deals/widgets/add_deal_bottom_sheet.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:leaf/profile/profile_provider.dart';
import 'package:provider/provider.dart';

import '../../deals/models/deal.dart';

class ProfileDealItem extends StatelessWidget {
  final Deal deal;

  const ProfileDealItem({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final loc = Localization.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          leading: Container(
            height: 90,
            width: 50,
            // child: Hero(
            //   tag: deal.pid,
            child: Image.network(
              deal.productImage,
              errorBuilder: (_, __, ___) => Icon(
                Icons.wifi_off_rounded,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          // ),
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
          trailing: !profile!.isMe
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Theme.of(context).primaryColor),
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
                      onPressed: () => onPressHandler(
                        context: context,
                        action: () async => await context
                            .read<ProfileProvider>()
                            .deleteProfileDeal(pid: deal.pid, id: deal.id),
                        errorMessage: loc.getTranslatedValue('error_msg'),
                        successMessage: loc.getTranslatedValue('profile_dealitem_delete_msg_txt'),
                      ),
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
