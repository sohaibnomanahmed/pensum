import 'package:flutter/material.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import '../data/place_data.dart';
import '../data/quality_data.dart';
import '../data/price_data.dart';
import '../deals_provider.dart';
import '../models/deal.dart';

class AddDealBottomSheet extends StatefulWidget {
  final String pid;
  final String productImage;
  final String productTitle;
  final Deal? deal;

  AddDealBottomSheet({
    required this.pid,
    required this.productImage,
    required this.productTitle,
    this.deal,
  });

  @override
  _AddDealBottomSheetState createState() => _AddDealBottomSheetState();
}

class _AddDealBottomSheetState extends State<AddDealBottomSheet> {
  var _price = '';
  var _quality = '';
  var _place = '';
  var _description = '';

  @override
  void initState() {
    super.initState();
    final deal = widget.deal;
    if (deal != null) {
      _price = deal.price;
      _quality = deal.quality;
      _place = deal.place;
      _description = deal.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded,
                  size: 65, color: Theme.of(context).primaryColor),
              // Makse sure the value matches a value in items
              DropdownButtonFormField(
                value: _price.isEmpty ? null : _price,
                hint: Text(loc.getTranslatedValue('select_price_hint')),
                onChanged: (String? value) => value == null ? null : setState(() {
                  _price = value;
                }),
                items: prices
                    .map((price) =>
                        DropdownMenuItem(value: price, child: Text(price)))
                    .toList(),
              ),
              DropdownButtonFormField(
                value: _quality.isEmpty ? null : _quality,
                hint: Text(loc.getTranslatedValue('select_quality_hint')),
                onChanged: (String? value) => value == null ? null : setState(() {
                  _quality = value;
                }),
                items: qualities
                    .map((quality) =>
                        DropdownMenuItem(value: quality, child: Text(quality)))
                    .toList(),
              ),
              DropdownButtonFormField(
                value: _place.isEmpty ? null : _place,
                hint: Text(loc.getTranslatedValue('select_place_hint')),
                onChanged: (String? value) => value == null ? null : setState(() {
                  _place = value;
                }),
                items: places
                    .map((place) =>
                        DropdownMenuItem(value: place, child: Text(place)))
                    .toList(),
              ),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                maxLength: 150,
                initialValue: _description.isEmpty ? null : _description,
                minLines: 3,
                maxLines: 3,
                decoration:
                    InputDecoration(labelText: loc.getTranslatedValue('deal_description_hint')),
                onChanged: (value) => _description = value,
              ),
              ElevatedButton(
                onPressed:
                    (_price.isEmpty || _quality.isEmpty || _place.isEmpty)
                        ? null
                        : () => onPressHandler(
                              context: context,
                              popScreen: true,
                              action: () async =>
                                  await context.read<DealsProvider>().setDeal(
                                        id: widget.deal?.id,
                                        pid: widget.pid,
                                        productImage: widget.productImage,
                                        productTitle: widget.productTitle,
                                        price: _price,
                                        quality: _quality,
                                        place: _place,
                                        description: _description,
                                      ),
                              errorMessage:
                                  loc.getTranslatedValue('add_deal_error_msg_text'),
                              successMessage: loc.getTranslatedValue('add_deal_success_msg_text'),
                            ),
                child: Text(loc.getTranslatedValue('add_deal_btn_text')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
