import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/leaf_image.dart';
import 'package:leaf/localization/localization.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: LeafImage(text: loc.getTranslatedValue('page_not_found_text'), assetImage: 'assets/images/404.png',),
    );
  }
}
