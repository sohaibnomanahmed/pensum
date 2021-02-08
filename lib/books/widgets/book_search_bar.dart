import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../books_provider.dart';
import 'book_search_delegate.dart';

class BookSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // search delegate cant access provider, so books as passed through the constructor
    final bookTitles = context.watch<BooksProvider>().bookTitles;
    final isLoading = context.watch<BooksProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          primary: Theme.of(context).disabledColor,
          backgroundColor: Theme.of(context).splashColor,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isLoading
            ? null
            : () async {
                final title = await showSearch(
                  context: context,
                  delegate: BookSearchDelegate(bookTitles),
                );
                if (title == null) {
                  return;
                }
                await context.read<BooksProvider>().fetchSearchedBook(title);
              },
        icon: Icon(Icons.search),
        label: Text('Search books'),
      ),
    );
  }
}
