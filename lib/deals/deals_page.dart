import 'package:flutter/material.dart';
import 'package:leaf/deals/widgets/blurred_image_app_bar.dart';
import 'package:leaf/deals/widgets/deal_list.dart';
import 'package:provider/provider.dart';

import '../deals/deals_provider.dart';
import 'widgets/blurred_image_app_bar.dart';
import 'widgets/book_info.dart';
import '../books/models/book.dart';

class DealsPage extends StatefulWidget {
  static const routeName = '/deals';
  final Book book;
  final DealsProvider dealsProvider;

  DealsPage(this.book, this.dealsProvider);

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
    final isFilter = context.watch<DealsProvider>().isFilter;
    return Scaffold(
      appBar: BlurredImageAppBar(widget.book, widget.dealsProvider),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            context.read<DealsProvider>().fetchMoreDeals(widget.book.isbn);
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: ElevatedButton(onPressed: () {}, child: Text('Follow')),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DealList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isFilter
          ? FloatingActionButton.extended(
              onPressed: () => context.read<DealsProvider>().clearFilter(),
              label: Text('Clear Filter'),
              icon: Icon(Icons.search_off_rounded),
            )
          : null,
    );
  }
}
