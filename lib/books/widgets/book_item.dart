import 'package:flutter/material.dart';

import '../models/book.dart';

class BookItem extends StatelessWidget {
  final Book book;

  BookItem(this.book);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          PhysicalModel(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                book.image,
                fit: BoxFit.cover,
                height: 100,
                width: 70,
                errorBuilder: (_, __, ___) => Container(
                  // TODO theme color?
                  child: Icon(Icons.wifi_off_rounded, color: Colors.grey[600],),
                  height: 100,
                  width: 70,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
            elevation: 5,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.titles.first,
                    style: Theme.of(context).textTheme.bodyText1),
                Text(book.getAuthors),
                Text(book.year, style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
