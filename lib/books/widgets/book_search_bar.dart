import 'package:flutter/material.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import '../books_provider.dart';
import 'book_search_delegate.dart';

class BookSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // search delegate cant access provider, so books as passed through the constructor
    final bookTitles = context.watch<BooksProvider>().bookTitles;
    final isLoading = context.watch<BooksProvider>().isLoading;
    final loc = Localization.of(context);
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
            : () => showSearch(
                  context: context,
                  delegate: BookSearchDelegate(context, bookTitles),
                ),
        icon: Icon(Icons.search),
        label: Text(loc.getTranslatedValue('book_search_bar_text')),
      ),
    );
  }
}
