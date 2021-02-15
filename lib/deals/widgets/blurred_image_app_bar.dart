import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/books/models/book.dart';
import 'package:provider/provider.dart';

import '../deals_provider.dart';
import 'add_deal_bottom_sheet.dart';
import 'filter_deals_bottom_sheet.dart';

class BlurredImageAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Book book;
  final DealsProvider dealsProvider;

  BlurredImageAppBar(this.book, this.dealsProvider)
      : preferredSize = Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(book.titles.first),
      flexibleSpace: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(book.image),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      ),
      elevation: 0,
      actions: [
        // IconButton(
        //   icon: Icon(Icons.remove_red_eye),
        //   onPressed: (){}
        // ),
        IconButton(
          icon: Icon(Icons.filter_list_rounded),
          onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: dealsProvider,
              child: FilterDealsBottomSheet(book),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: dealsProvider,
              child: AddDealBottomSheet(book),
            ),
          ),
        )
      ],
    );
  }
}
