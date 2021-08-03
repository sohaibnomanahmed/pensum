import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:leaf/images/photo_page.dart';
import 'package:leaf/localization/localization.dart';
import '../../books/models/book.dart';

class BookInfo extends StatelessWidget {
  final Book book;

  BookInfo(this.book);

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          OpenContainer(
            useRootNavigator: true,
            openBuilder: (_, __) => PhotoPage(book.image),
            closedBuilder: (_, __) => Container(
              height: 200,
              width: 150,
              child: Hero(
                  tag: book.isbn,
                  child: Image.network(
                    book.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  )),
            ),
          ),
          Flexible(
            child: Column(
              children: [
                if (book.language.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.language),
                    title: Text(book.language),
                  ),
                if (book.pages.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.description),
                    title: Text(book.pages + loc.getTranslatedValue('deal_item_page_count_suffix')),
                  ),
                if (book.edition.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.edit_rounded),
                    title: Text(book.edition),
                  ),
                if (book.publisher.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.menu_book_rounded),
                    title: Text(book.publisher),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
