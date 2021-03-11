import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/follow/follow_page.dart';
import 'package:leaf/follow/follow_provider.dart';
import 'package:leaf/global/404_page.dart';
import 'package:leaf/messages/recipients_page.dart';
import 'package:leaf/messages/recipients_provider.dart';
import 'package:leaf/profile/profile_page.dart';
import 'package:leaf/profile/profile_provider.dart';
import 'package:provider/provider.dart';

import '../books/books_page.dart';
import '../books/books_provider.dart';
import '../settings/settings_page.dart';
import '../deals/deals_page.dart';
import '../deals/deals_provider.dart';

class HomePage extends StatelessWidget {
  // list of pages
  final List<Widget> _pages = [
    // books page
    CupertinoTabView(
      builder: (_) => ChangeNotifierProvider(
          create: (_) => BooksProvider(), child: BooksPage()),
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        switch (settings.name) {
          case DealsPage.routeName:
            final dealProvider = DealsProvider();
            return MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                  create: (_) => dealProvider,
                  child: DealsPage(book: args, dealsProvider: dealProvider)),
            );
          default:
            return MaterialPageRoute(builder: (_) => PageNotFound());
        }
      },
    ),
    CupertinoTabView(builder: (ctx) => ChangeNotifierProvider(
      create: (_) => RecipientsProvider(),
      child: RecipientsPage(),
    )),
    CupertinoTabView(builder: (_) {
      final profileProvider = ProfileProvider();
      return ChangeNotifierProvider(
          create: (_) => profileProvider,
          child: ProfilePage(profileProvider: profileProvider));
    }),
    CupertinoTabView(builder: (ctx) => ChangeNotifierProvider(
          create: (_) => FollowProvider(),
          child: FollowPage())),
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
            icon: Icon(Icons.notifications_rounded),
            label: 'Following',
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
