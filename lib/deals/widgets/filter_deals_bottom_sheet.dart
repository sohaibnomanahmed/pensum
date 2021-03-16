import 'package:flutter/material.dart';
import 'package:leaf/books/models/book.dart';
import 'package:provider/provider.dart';

import '../data/place_data.dart';
import '../data/quality_data.dart';
import '../data/price_data.dart';
import '../deals_provider.dart';

class FilterDealsBottomSheet extends StatefulWidget {
  final Book book;

  FilterDealsBottomSheet(this.book);

  @override
  _FilterDealsBottomSheetState createState() => _FilterDealsBottomSheetState();
}

class _FilterDealsBottomSheetState extends State<FilterDealsBottomSheet> {
  RangeValues _currentRangeValues = RangeValues(
      0, double.parse(prices.last.replaceAll(RegExp('[^0-9]'), '')));
  var _quality = '';
  List<String> _places = [];

  @override
  void initState() {
    super.initState();
    // if filter already applied, load those values
    final dealFilter = context.read<DealsProvider>().dealFilter;
    if (!dealFilter.isEmpty) {
      _currentRangeValues = RangeValues(
          dealFilter.priceAbove.toDouble(), dealFilter.priceBelow.toDouble());
      _quality = dealFilter.quality;
      _places = dealFilter.places;    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded,
                size: 65, color: Theme.of(context).primaryColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price above: ' +
                    _currentRangeValues.start.round().toString()),
                Text('Price below: ' +
                    _currentRangeValues.end.round().toString()),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: double.parse(prices.last.replaceAll(RegExp('[^0-9]'), '')),
              divisions:
                  (double.parse(prices.last.replaceAll(RegExp('[^0-9]'), '')) *
                              0.01)
                          .round() *
                      2,
              labels: RangeLabels(
                _currentRangeValues.start.round().toString(),
                _currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            DropdownButtonFormField(
              value: _quality.isNotEmpty ? _quality: null,
              hint: Text('Select quality'),
              onChanged: (value) => _quality = value,
              items: qualities
                  .map((quality) =>
                      DropdownMenuItem(value: quality, child: Text(quality)))
                  .toList(),
            ),
            DropdownButtonFormField(
              hint: Text('Add up to 10 places'),
              onChanged: (value) => setState(() {
                // firebase limit on array checks
                if (_places.length < 10 && !_places.contains(value)) {
                  _places.add(value);
                }
              }),
              items: places
                  .map((place) =>
                      DropdownMenuItem(value: place, child: Text(place)))
                  .toList(),
            ),
            if (_places.isEmpty)
              SizedBox(
                height: 48,
              ),
            Wrap(
              spacing: 3,
              children: [
                ..._places
                    .map((e) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Theme.of(context).backgroundColor,
                            child: Icon(Icons.place_rounded),
                          ),
                          label: Text(e),
                          backgroundColor: Theme.of(context).backgroundColor,
                          onDeleted: () => setState(() {
                            _places.removeWhere((element) => element == e);
                          }),
                        ))
                    .toList()
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  // pop screen
                  Navigator.of(context).pop();
                  // try adding the deal
                  await context.read<DealsProvider>().filterDeals(
                        isbn: widget.book.isbn,
                        priceAbove: _currentRangeValues.start.round(),
                        priceBelow: _currentRangeValues.end.round(),
                        places: _places,
                        quality: _quality,
                      );
                },
                child: Text('Filter deals'))
          ],
        ),
      ),
    );
  }
}
