import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/books/books_page.dart';
import 'package:leaf/books/books_provider.dart';
import 'package:leaf/books/books_service.dart';
import 'package:provider/provider.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  final _booksService = BooksService(firestore);
  final _booksProvider = BooksProvider(_booksService);

  testWidgets('Should double the number of books when scrolling the book page to the end', (tester) async {
    // GIVEN: books page with books
    await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider(
          create: (_) => _booksProvider, child: BooksPage()),
    ));
  });
}
