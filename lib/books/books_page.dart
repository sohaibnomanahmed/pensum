import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/paging_view.dart';
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
    context.read<BooksProvider>().fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final isSearch = context.watch<BooksProvider>().isSearch;
    return Scaffold(
      body: PagingView(
        action: context.read<BooksProvider>().fetchMoreBooks,
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
      floatingActionButton: isSearch
          ? FloatingActionButton.extended(
              onPressed: () => context.read<BooksProvider>().clearSearch(),
              label: Text('Clear Search'),
              icon: Icon(Icons.search_off_rounded),
            )
          : null,
    );
  }
}
