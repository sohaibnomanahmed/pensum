import 'package:flutter/material.dart';

import '../models/book.dart';

class BookItem extends StatelessWidget {
  final Book? book;

  const BookItem({Key? key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          PhysicalModel(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
            elevation: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: (book == null)
                  ? Container(
                      color: Colors.grey,
                      height: 100,
                      width: 70,
                    )
                  : Hero(
                      tag: book!.isbn,
                      child: Image.network(
                        book!.image,
                        fit: BoxFit.cover,
                        height: 100,
                        width: 70,
                        errorBuilder: (_, __, ___) => Container(
                          height: 100,
                          width: 70,
                          child: Icon(
                            Icons.wifi_off_rounded,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (book == null)
                    ? Container(
                        height: 14, color: Colors.grey, width: double.infinity)
                    : Text(book!.titles.first,
                        style: Theme.of(context).textTheme.bodyText1),
                (book == null)
                    ? Container(
                        height: 14, color: Colors.grey, width: double.infinity)
                    : Text(book!.getAuthors),
                (book == null)
                    ? Container(
                        height: 14, color: Colors.grey, width: double.infinity)
                    : Text(book!.year,
                        style: Theme.of(context).textTheme.caption),
              ],
            ),
          ),
          if (book != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                  color: book!.deals > 0
                      ? book!.deals > 3
                          ? book!.deals > 7
                              ? Colors.green[400]
                              : Colors.green[200]
                          : Colors.deepOrange[200]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)),
              child: FittedBox(child: Text('${book!.deals}')),
            )
        ],
      ),
    );
  }
}
