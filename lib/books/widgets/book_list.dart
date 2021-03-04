import 'package:flutter/material.dart';
import 'package:leaf/deals/deals_page.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
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
    print(books);
    return isError
        ? SliverFillRemaining(
            child: LeafError(context.read<BooksProvider>().reFetchBooks))
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => isLoading
                  ? Shimmer.fromColors(
                      highlightColor: Theme.of(context).canvasColor,
                      baseColor: Theme.of(context).splashColor,
                      child: BookItem(null),
                    )
                  : InkWell(
                      child: BookItem(books[index]),
                      onTap: () => Navigator.of(context).pushNamed(
                          DealsPage.routeName,
                          arguments: books[index]),
                    ),
              childCount: isLoading ? 6 : books.length,
            ),
          );
  }
}
