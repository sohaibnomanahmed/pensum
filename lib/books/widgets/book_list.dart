import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_item.dart';
import '../books_provider.dart';

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>().books;
    final isError = context.watch<BooksProvider>().isError;
    return isError
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/empty_rack.png', height: 200),
                SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () => context.read<BooksProvider>().fetchBooks,
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Try again'),
                )
              ],
            ),
          )
        : ListView.builder(
            itemBuilder: (_, index) => BookItem(books[index]),
            itemCount: books.length,
          );
  }
}
