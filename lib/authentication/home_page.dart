import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../books/books_page.dart';
import '../books/books_provider.dart';
import '../settings/settings_page.dart';

class HomePage extends StatelessWidget {
  // list of pages
  final List<Widget> _pages = [
    CupertinoTabView(
        builder: (ctx) => ChangeNotifierProvider(
            create: (_) => BooksProvider(), child: BooksPage())),
    CupertinoTabView(builder: (ctx) => Scaffold(body: Text('Chat'))),
    CupertinoTabView(builder: (ctx) => Scaffold(body: Text('Profile'))),
    CupertinoTabView(builder: (ctx) => SettingsPage())
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.1)),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(1),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chrome_reader_mode),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) => _pages[index],
    );
  }
}
