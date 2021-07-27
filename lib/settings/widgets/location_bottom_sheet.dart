// import 'package:flutter/material.dart';
// import 'package:leaf/global/utils.dart';
// import 'package:leaf/localization/localization.dart';
// import 'package:provider/provider.dart';

// class LocationBottomSheet extends StatefulWidget {
//   @override
//   _LocationBottomSheetState createState() => _LocationBottomSheetState();
// }

// class _LocationBottomSheetState extends State<LocationBottomSheet> {
//   var _location = '';
//   var _language = '';
//   var _currency = '';

//   @override
//   void initState() {
//     super.initState();
//     _language = Localization.of(context).title;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Container(
//         color: Colors.transparent,
//         padding: const EdgeInsets.all(10.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.translate_rounded,
//                   size: 65, color: Theme.of(context).primaryColor),
//               // Makse sure the value matches a value in items
//               DropdownButtonFormField(
//                 value: _language,
//                 onChanged: (String? value) => value == null ? null : setState(() {
//                   _language = value;
//                 }),
//                 items: prices
//                     .map((price) =>
//                         DropdownMenuItem(value: price, child: Text(price)))
//                     .toList(),
//               ),
//               DropdownButtonFormField(
//                 value: _quality.isEmpty ? null : _quality,
//                 hint: Text('Select quality'),
//                 onChanged: (String? value) => value == null ? null : setState(() {
//                   _quality = value;
//                 }),
//                 items: qualities
//                     .map((quality) =>
//                         DropdownMenuItem(value: quality, child: Text(quality)))
//                     .toList(),
//               ),
//               DropdownButtonFormField(
//                 value: _place.isEmpty ? null : _place,
//                 hint: Text('Select place'),
//                 onChanged: (String? value) => value == null ? null : setState(() {
//                   _place = value;
//                 }),
//                 items: places
//                     .map((place) =>
//                         DropdownMenuItem(value: place, child: Text(place)))
//                     .toList(),
//               ),
//               TextFormField(
//                 textCapitalization: TextCapitalization.sentences,
//                 maxLength: 150,
//                 initialValue: _description.isEmpty ? null : _description,
//                 minLines: 3,
//                 maxLines: 3,
//                 decoration:
//                     InputDecoration(labelText: 'Description (Optional)'),
//                 onChanged: (value) => _description = value,
//               ),
//               ElevatedButton(
//                 onPressed:
//                     (_price.isEmpty || _quality.isEmpty || _place.isEmpty)
//                         ? null
//                         : () => onPressHandler(
//                               context: context,
//                               popScreen: true,
//                               action: () async =>
//                                   await context.read<DealsProvider>().setDeal(
//                                         id: widget.deal?.id,
//                                         pid: widget.pid,
//                                         productImage: widget.productImage,
//                                         productTitle: widget.productTitle,
//                                         price: _price,
//                                         quality: _quality,
//                                         place: _place,
//                                         description: _description,
//                                       ),
//                               errorMessage:
//                                   'Something went wrong, please try again!',
//                               successMessage: 'Succesfully added deal',
//                             ),
//                 child: Text('Add deal'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
