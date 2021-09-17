// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'models/mobile.dart';

// class BooksService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late DocumentSnapshot _lastBook;

//   /// fetch books
//   Stream<List<Book>> fetchBooks(int pageSize) {
//     return _firestore
//         .collection('books')
//         .orderBy('deals', descending: true)
//         .orderBy('followings', descending: true)
//         .limit(pageSize)
//         .snapshots()
//         .map(
//       (list) {
//         if (list.docs.isNotEmpty) {
//           _lastBook = list.docs.last;
//         }
//         return list.docs
//             .map((document) => Book.fromFirestore(document))
//             .toList();
//       },
//     );
//   }

//   /// fetch and return more books, from current last. If no more books return null
//   Future<List<Book>> fetchMoreBooks(int pageSize) async {
//     final books = await _firestore
//         .collection('books')
//         .orderBy('deals', descending: true)
//         .orderBy('followings', descending: true)
//         .startAfterDocument(_lastBook)
//         .limit(pageSize)
//         .get();
//     if (books.docs.isNotEmpty) {
//       _lastBook = books.docs.last;
//     }
//     return books.docs.map((document) => Book.fromFirestore(document)).toList();
//   }

//   /// fetch book titles
//   Stream<Map<String, dynamic>> fetchBookTitles() {
//     return _firestore.collection('books').doc('metadata').snapshots().map(
//       (snapshot) {
//         Map<String, dynamic> map;
//         map = {};
//         // check if the document exist
//         if (snapshot.exists){
//           // check is the document is not null
//           final data = snapshot.data();
//           if (data != null){
//             return data['titles'] ?? map;
//           }    
//         }
//         return map;
//       },
//     );
//   }

//   /// get book
//   Future<Book> getBook(String isbn) async {
//     final book = await _firestore.collection('books').doc(isbn).get();
//     return Book.fromFirestore(book);
//   }

//   /// Search books by title
//   Stream<List<Book>> searchBooks(String isbn){
//     return _firestore
//         .collection('books')
//         .where('isbn', isEqualTo: isbn)
//         .snapshots()
//         .map((books) => books.docs
//             .map((document) => Book.fromFirestore(document))
//             .toList());
//   }
// }
