import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:leaf/deals/widgets/deal_list.dart';
import 'package:provider/provider.dart';

import '../deals/deals_provider.dart';
import '../deals/widgets/add_deal_bottom_sheet.dart';
import 'widgets/book_info.dart';
import '../books/models/book.dart';

class DealsPage extends StatefulWidget {
  static const routeName = '/deals';
  final Book book;

  DealsPage(this.book);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DealsProvider>().fetchDeals(widget.book.isbn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.titles.first),
        flexibleSpace: ClipRect(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.book.image),
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
          IconButton(icon: Icon(Icons.filter_list_rounded), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => AddDealBottomSheet(context, widget.book),
            ),
          )
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            //context.read<DealsProvider>().fetchMoreDeals();
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BookInfo(widget.book),
              ),
              // TODO make paging
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DealList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
