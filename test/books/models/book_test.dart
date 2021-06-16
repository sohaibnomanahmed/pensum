import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/books/models/book.dart';

void main() {
  test('Test making list of book authors into a string', () async {
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
    final authors = book.getAuthors;
    expect(authors, 'Jack Frost, Bella Hadi, Hassan Ali');
  });
}