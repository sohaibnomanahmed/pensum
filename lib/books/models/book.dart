import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final List<dynamic> titles;
  final List<dynamic> authors;
  final String image;
  final String language;
  final String publisher;
  final String pages;
  final String edition;
  final String year;
  final String isbn;

  Book({
    required this.titles,
    required this.authors,
    required this.image,
    required this.language,
    required this.publisher,
    required this.pages,
    required this.edition,
    required this.year,
    required this.isbn,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw 'Error creating Book from null value';
    }
    final List<dynamic>? titles = data['title'];
    final List<dynamic>? authors = data['authors'];
    final String? image = data['image'];
    final String? language = data['language'];
    final String? publisher = data['publisher'];
    final String? pages = data['pages'];
    final String? edition = data['edition'];
    final String? year = data['year'];

    if (titles == null ||
        authors == null ||
        image == null ||
        language == null ||
        publisher == null ||
        pages == null ||
        edition == null ||
        year == null) {
      throw 'Error creating Book from null value';
    }

    return Book(
        titles: titles,
        authors: authors,
        image: image,
        language: language,
        publisher: publisher,
        pages: pages,
        edition: edition,
        year: year,
        isbn: doc.id);
  }

  String get getAuthors {
    var res = '';
    authors.forEach((author) {
      if (author == authors.last) {
        res += author;
      } else {
        res += author + ', ';
      }
    });
    return res;
  }

  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      'authors': authors,
      'image': image,
      'language': language,
      'publisher': publisher,
      'pages': pages,
      'edition': edition,
      'year': year,
      'isbn': isbn,
    };
  }
}
