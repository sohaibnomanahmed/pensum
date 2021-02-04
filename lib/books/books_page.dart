import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/book_list.dart';
import 'books_provider.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  var _isSearch = false;

  @override
  void initState() {
    super.initState();
    context.read<BooksProvider>().fetchBooks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >
                (scrollInfo.metrics.maxScrollExtent * 0.8)) {
              if (!_isSearch){    
              context.read<BooksProvider>().fetchMoreBooks();
              }
            }
            return true;
          },
        child: BookList(),
      ),
    );
  }
}
