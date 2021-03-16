import 'package:flutter/material.dart';
import 'package:leaf/deals/widgets/blurred_image_app_bar.dart';
import 'package:leaf/deals/widgets/deal_list.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
import 'package:provider/provider.dart';

import '../deals/deals_provider.dart';
import 'widgets/blurred_image_app_bar.dart';
import 'widgets/book_info.dart';
import '../books/models/book.dart';

class DealsPage extends StatefulWidget {
  static const routeName = '/deals';
  final Book book;
  final DealsProvider dealsProvider;

  DealsPage({this.book, this.dealsProvider});

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
    final isLoading = context.watch<DealsProvider>().isLoading;
    final isError = context.watch<DealsProvider>().isError;
    final isFollowBtnLoading =
        context.watch<DealsProvider>().isFollowBtnLoading;
    final isFollowing = context.watch<DealsProvider>().isFollowing;
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BookInfo(widget.book),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                    onPressed: (isLoading || isFollowing)
                        ? null
                        : () async {
                            final result = await context
                                .read<DealsProvider>()
                                .followBook(widget.book);
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final errorColor = Theme.of(context).errorColor;
                            final primaryColor = Theme.of(context).primaryColor;
                            // check if an error occured
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
                                  content: Text(
                                      'Succesfully started following this book'),
                                ),
                              );
                            }
                          },
                    child: isFollowBtnLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Follow')),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 60),
                child: isLoading
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : isError
                        ? LeafError(context.read<DealsProvider>().refetchDeals,
                            widget.book.isbn)
                        : DealList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isFilter
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.read<DealsProvider>().clearFilter(widget.book.isbn),
              label: Text('Clear Filter'),
              icon: Icon(Icons.clear_all_rounded),
            )
          : null,
    );
  }
}
