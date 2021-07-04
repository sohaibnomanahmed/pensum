import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/books/models/book.dart';

void main() {
  test('Should print out list of book authors as a easily readable string', () async {
    // GIVEN: book with list of authors: ['Jack Frost', 'Bella Hadi', 'Hassan Ali']
    final book = Book(
      titles: [''],
      edition: '',
      image: '',
      isbn: '',
      language: '',
      pages: '',
      publisher: '',
      year: '',
      deals: 0,
      authors: ['Jack Frost', 'Bella Hadi', 'Hassan Ali']
    );
    // WHEN: book.getAuthors is called
    final authors = book.getAuthors;
    // THEN: authors is 'Jack Frost, Bella Hadi, Hassan Ali'
    expect(authors, 'Jack Frost, Bella Hadi, Hassan Ali');
  });
}