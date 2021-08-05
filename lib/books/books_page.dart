import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leaf/global/widgets/paging_view.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import 'widgets/book_list.dart';
import 'widgets/book_search_bar.dart';
import 'books_provider.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => context
        .read<BooksProvider>()
        .fetchBooks(Localization.of(context).locale.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final isSearch = context.watch<BooksProvider>().isSearch;
    final loc = Localization.of(context);
    return Scaffold(
      body: PagingView(
        action: () => context.read<BooksProvider>().fetchMoreBooks(context),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).canvasColor,
                  elevation: 1,
                  title: BookSearchBar(),
                  floating: true,
                ),
                BookList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isSearch
          ? FloatingActionButton.extended(
              onPressed: () => context
                  .read<BooksProvider>()
                  .clearSearch(Localization.of(context).locale.languageCode),
              label: Text(loc.getTranslatedValue('clear_search_btn_text')),
              icon: Icon(Icons.search_off_rounded),
            )
          : null,
    );
  }
}
