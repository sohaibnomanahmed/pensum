import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'book_item.dart';
import '../books_provider.dart';

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>().books;
    final isLoading = context.watch<BooksProvider>().isLoading;
    final isError = context.watch<BooksProvider>().isError;
    return isError
        ? SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => isLoading
                  ? Shimmer.fromColors(
                      highlightColor: Theme.of(context).canvasColor,
                      baseColor: Theme.of(context).splashColor,
                      child: BookItem(null),
                    )
                  : BookItem(books[index]),
              childCount: isLoading ? 6 : books.length,
            ),
          );
  }
}
