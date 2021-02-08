import 'package:flutter/material.dart';

class BookSearchDelegate extends SearchDelegate<String> {
  List<String> bookMatches;
  final Map<String, dynamic> bookTitles;

  BookSearchDelegate(this.bookTitles);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return super.appBarTheme(context).copyWith(
        textTheme: theme.textTheme.copyWith(
          headline6: theme.textTheme.bodyText2
              .copyWith(color: Theme.of(context).hintColor),
        ),
        appBarTheme:
            super.appBarTheme(context).appBarTheme.copyWith(elevation: 1));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
        size: 24,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    FocusScope.of(context).unfocus();
    return ListView.builder(
      itemCount: bookMatches.length,
      itemBuilder: (ctx, index) => ListTile(
        onTap: () => close(context, bookTitles[bookMatches[index]]['title']),
        title: Text(
          bookTitles[bookMatches[index]]['title'],
          style: Theme.of(context).textTheme.bodyText2,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.network(
            bookTitles[bookMatches[index]]['image'],
            width: 30,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {
              return Icon(Icons.wifi_off_rounded);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var searchText = '.?';
    for (var i = 0; i < query.length; i++) {
      searchText += query[i] + '.?';
    }

    var regExp = RegExp(
      searchText,
      caseSensitive: false,
      multiLine: false,
    );
    bookMatches = bookTitles.keys
        .where((k) => regExp.hasMatch(bookTitles[k]['title']))
        .toList();

    return ListView.builder(
      itemCount: bookMatches.length,
      itemBuilder: (ctx, index) => ListTile(
        onTap: () => close(context, bookTitles[bookMatches[index]]['title']),
        title: Text(
          bookTitles[bookMatches[index]]['title'],
          style: Theme.of(context).textTheme.bodyText2,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.network(
            bookTitles[bookMatches[index]]['image'],
            width: 30,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {
              return Icon(
                Icons.wifi_off_rounded,
                size: 30,
              );
            },
          ),
        ),
      ),
    );
  }
}
