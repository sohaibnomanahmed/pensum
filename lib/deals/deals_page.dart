import 'package:flutter/material.dart';
import 'package:leaf/deals/widgets/blurred_image_app_bar.dart';
import 'package:leaf/deals/widgets/deal_list.dart';
import 'package:leaf/global/functions.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../deals/deals_provider.dart';
import 'widgets/blurred_image_app_bar.dart';
import 'widgets/book_info.dart';
import '../books/models/book.dart';

class DealsPage extends StatefulWidget {
  static const routeName = '/deals';
  static const SHOWCASE = 'DEALS_PAGE_SHOWCASE';
  final Book book;

  DealsPage(this.book);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  late bool lock;

  @override
  void initState() {
    super.initState();
    context.read<DealsProvider>().fetchDeals(widget.book.isbn);

    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _isFirstLaunch().then((result) {
              if (result) {
                ShowCaseWidget.of(context)!.startShowCase([_one, _two, _three]);
              }
            }));
  }

  Future<bool> _isFirstLaunch() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final isFirstLaunch = sharedPreferences.getBool(DealsPage.SHOWCASE) ?? true;

    if (isFirstLaunch) {
      await sharedPreferences.setBool(DealsPage.SHOWCASE, false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    lock = false;
    final isFilter = context.watch<DealsProvider>().isFilter;
    final isLoading = context.watch<DealsProvider>().isLoading;
    final isError = context.watch<DealsProvider>().isError;
    final isFollowBtnLoading =
        context.watch<DealsProvider>().isFollowBtnLoading;
    final isFollowing = context.watch<DealsProvider>().isFollowing;
    return Scaffold(
      appBar: BlurredImageAppBar(widget.book, _one, _two),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            if (!lock) {
              lock = true;
              context.read<DealsProvider>().fetchMoreDeals(widget.book.isbn);
            }
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
                child: Showcase(
                  key: _three,
                  description:
                      'Follow a book to receive notifications on new deals',
                  contentPadding: EdgeInsets.all(10),
                  showArrow: false,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: (isLoading || isFollowing)
                        ? null
                        : () => ButtonFunctions.onPressHandler(
                              context: context,
                              action: () async => await context
                                  .read<DealsProvider>()
                                  .followBook(widget.book),
                              successMessage:
                                  'Succesfully started following this book',
                              errorMessage:
                                  'Something went wrong, please try again!',
                            ),
                    child: isFollowBtnLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Follow'),
                  ),
                ),
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
