import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/leaf_empty.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: LeafEmpty(text: 'Page not found'),
    );
  }
}
