import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/book_list.dart';
import 'widgets/book_search_bar.dart';
import 'books_provider.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late bool lock;

  @override
  void initState() {
    super.initState();
    context.read<BooksProvider>().fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    // set lock to prevent multiple calls to the function
    lock = false;
    final isSearch = context.watch<BooksProvider>().isSearch;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            if (!lock){
              lock = true;
              context.read<BooksProvider>().fetchMoreBooks();
            }
          }
          return true;
        },
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
