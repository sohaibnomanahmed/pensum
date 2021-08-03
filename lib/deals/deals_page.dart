import 'package:flutter/material.dart';
import 'package:leaf/deals/widgets/blurred_image_app_bar.dart';
import 'package:leaf/deals/widgets/deal_list.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
import 'package:leaf/global/widgets/paging_view.dart';
import 'package:leaf/localization/localization.dart';
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
    final isFilter = context.watch<DealsProvider>().isFilter;
    final isLoading = context.watch<DealsProvider>().isLoading;
    final isError = context.watch<DealsProvider>().isError;
    final isFollowBtnLoading =
        context.watch<DealsProvider>().isFollowBtnLoading;
    final isFollowing = context.watch<DealsProvider>().isFollowing;
    final loc = Localization.of(context);
    return Scaffold(
      appBar: BlurredImageAppBar(widget.book, _one, _two),
      body: PagingView(
        action: () =>
              context.read<DealsProvider>().fetchMoreDeals(widget.book.isbn),
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
                  description: loc.getTranslatedValue('showcase_follow_btn_text'),
                  contentPadding: EdgeInsets.all(10),
                  shapeBorder: RoundedRectangleBorder(),
                  showArrow: false,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: (isLoading || isFollowing)
                        ? null
                        : () => onPressHandler(
                              context: context,
                              action: () async => await context
                                  .read<DealsProvider>()
                                  .followBook(widget.book),
                              successMessage:
                                  loc.getTranslatedValue('follow_success_msg_text'),
                              errorMessage:
                                  loc.getTranslatedValue('follow_error_msg_text'),
                            ),
                    child: isFollowBtnLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text(loc.getTranslatedValue('follow_btn_text')),
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
              label: Text(loc.getTranslatedValue('clear_filter_btn_text')),
              icon: Icon(Icons.clear_all_rounded),
            )
          : null,
    );
  }
}
