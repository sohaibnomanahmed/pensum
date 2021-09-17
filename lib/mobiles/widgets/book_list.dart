// import 'package:flutter/material.dart';
// import 'package:leaf/deals/deals_page.dart';
// import 'package:leaf/global/widgets/leaf_error.dart';
// import 'package:leaf/localization/localization.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';

// import 'book_item.dart';
// import '../mobiles_provider.dart';

// class BookList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final books = context.watch<BooksProvider>().books;
//     final isLoading = context.watch<BooksProvider>().isLoading;
//     final isError = context.watch<BooksProvider>().isError;
//     return isError
//         ? SliverFillRemaining(
//             child: LeafError(context.read<BooksProvider>().reFetchBooks, Localization.of(context).locale.languageCode))
//         : SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) => isLoading
//                   ? Shimmer.fromColors(
//                       highlightColor: Theme.of(context).canvasColor,
//                       baseColor: Theme.of(context).splashColor,
//                       child: BookItem(),
//                     )
//                   : InkWell(
//                       onTap: () => Navigator.of(context).pushNamed(
//                           DealsPage.routeName,
//                           arguments: books[index]),
//                       child: BookItem(book: books[index]),
//                     ),
//               childCount: isLoading ? 6 : books.length,
//             ),
//           );
//   }
// }
