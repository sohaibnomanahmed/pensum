import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';

class Book {
  final List<dynamic> titles;
  final List<dynamic> authors;
  final String image;
  final String language;
  late String? translatedLanguage;
  final String publisher;
  final String pages;
  final String edition;
  final String year;
  final String isbn;
  final int deals;
  final int followings; // number of deals for this book

  Book(
      {required this.titles,
      required this.authors,
      required this.image,
      required this.language,
      required this.publisher,
      required this.pages,
      required this.edition,
      required this.year,
      required this.isbn,
      required this.deals,
      required this.followings,
      });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw 'Error creating Book from null';
    }
    final List<dynamic>? titles = data['title'];
    final List<dynamic>? authors = data['authors'];
    final String? image = data['image'];
    final String? language = data['language'];
    final String? publisher = data['publisher'];
    final String? pages = data['pages'];
    final String? edition = data['edition'];
    final String? year = data['year'];
    final int? deals = data['deals'];
    final int? followings = data['followings'];

    if (titles == null ||
        authors == null ||
        image == null ||
        language == null ||
        publisher == null ||
        pages == null ||
        edition == null ||
        year == null ||
        deals == null ||
        followings == null) {
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
        deals: deals,
        followings: followings,
        isbn: doc.id);
  }

  Future<void> translateLanguage(String locale) async {
    final translator = GoogleTranslator();
    var translation = await translator.translate(language, to: locale);
    translatedLanguage = translation.text;
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
      'title': titles,
      'authors': authors,
      'image': image,
      'language': language,
      'publisher': publisher,
      'pages': pages,
      'edition': edition,
      'year': year,
      'isbn': isbn,
      'deals': deals,
      'followings': followings,
    };
  }
}
