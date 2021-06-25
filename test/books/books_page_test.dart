import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/books/books_page.dart';
import 'package:leaf/books/books_provider.dart';
import 'package:leaf/books/books_service.dart';
import 'package:leaf/books/models/book.dart';
import 'package:provider/provider.dart';

const BooksCollection = 'books';
void main() {
  group('Scrolling pages test', () {
    testWidgets(
        'Should double the number of books when scrolling the book page to the end',
        (tester) async {
      // GIVEN: books page with books
      final _firestore = FakeFirebaseFirestore();
      for (var i = 0; i < 25; i++) {
        await _firestore.collection(BooksCollection).add(Book(
                titles: ['title'],
                authors: ['authors'],
                image: 'image',
                language: 'language',
                publisher: 'publisher',
                pages: 'pages',
                edition: 'edition',
                year: 'year',
                isbn: 'isbn',
                deals: i)
            .toMap());
      }
      final _booksService = BooksService(_firestore);
      final _pageSize = 10;
      final _booksProvider = BooksProvider(_booksService, _pageSize);

      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider(
            create: (_) => _booksProvider, child: BooksPage()),
      ));

      // Let the snapshots stream fire a snapshot.
      await tester.idle();
      // Re-render.
      await tester.pump();

      // verify the books start with pageSize
      expect(_booksProvider.books.length, _pageSize);
      // Verify the output.
      expect(_booksProvider.isError, false);
      //expect(find.text('19'), findsOneWidget);

      // WHEN: scrolled to the end
      // not working with slivers
      // await tester.drag(find.byType(BookList), const Offset(0, -300));
      final gesture =
          await tester.startGesture(Offset(0, 0)); //Position of the scrollview
      await gesture.moveBy(Offset(0, -1000)); //How much to scroll by
      // Let the snapshots stream fire a snapshot.
      await tester.idle();
      // Re-render.
      await tester.pump();

      // THEN: number of books should be doubled
      expect(_booksProvider.books.length, _pageSize * 2);
    });
  });
}
