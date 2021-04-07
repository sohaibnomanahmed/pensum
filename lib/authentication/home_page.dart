import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:leaf/notifications/notification_provider.dart';
import 'package:leaf/notifications/widgets/badge.dart';
import 'package:provider/provider.dart';

import '../following/follow_page.dart';
import '../following/follow_provider.dart';
import '../global/404_page.dart';
import '../messages/recipients_page.dart';
import '../messages/recipients_provider.dart';
import '../profile/profile_page.dart';
import '../profile/profile_provider.dart';
import '../books/books_page.dart';
import '../books/books_provider.dart';
import '../settings/settings_page.dart';
import '../deals/deals_page.dart';
import '../deals/deals_provider.dart';

class HomePage extends StatefulWidget {
  // list of pages
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex;

  // custom routes when possible to navigate to deals page
  Route<dynamic> dealsGeneratedRoutes(RouteSettings settings) {
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
  }

  List<Widget> get _pages => [
        CupertinoTabView(
            builder: (_) => ChangeNotifierProvider(
                create: (_) => BooksProvider(), child: BooksPage()),
            onGenerateRoute: dealsGeneratedRoutes),
        CupertinoTabView(
            builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => RecipientsProvider(),
                  child: RecipientsPage(),
                )),
        CupertinoTabView(
            builder: (_) {
              final profileProvider = ProfileProvider();
              return ChangeNotifierProvider(
                  create: (_) => profileProvider, child: ProfilePage());
            },
            onGenerateRoute: dealsGeneratedRoutes),
        CupertinoTabView(
            builder: (ctx) => ChangeNotifierProvider(
                create: (_) => FollowProvider(), child: FollowPage()),
            onGenerateRoute: dealsGeneratedRoutes),
        CupertinoTabView(builder: (ctx) => SettingsPage())
      ];

  @override
  void initState() {
    super.initState();
    // setup notifications
    context
        .read<NotificationProvider>()
        .configureNotifications(context, _setCurrentIndex);
    _currentIndex = 0;

    // fetch notification indicators for bottombar
    context.read<NotificationProvider>().fetchFollowingNotification;
    context.read<NotificationProvider>().fetchChatNotification;

    // track if paused or resumed etc..
    WidgetsBinding.instance.addObserver(this);
    Provider.of<AuthenticationProvider>(context, listen: false)
          .configurePresence();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      print('Paused');
      Provider.of<AuthenticationProvider>(context, listen: false)
          .goOffline();
    }

    if (state == AppLifecycleState.resumed) {
      print('Ressumed');
      Provider.of<AuthenticationProvider>(context, listen: false)
          .goOnline();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _setCurrentIndex(int index) {
    // TODO not working
    print('Changing current index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    final followingNotification =
        context.watch<NotificationProvider>().followingNotification;
    final chatNotification =
        context.watch<NotificationProvider>().chatNotification;
    return isLoading
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
                currentIndex: _currentIndex,
                border: Border(top: BorderSide(color: Colors.grey, width: 0.1)),
                backgroundColor: Theme.of(context).canvasColor.withOpacity(1),
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chrome_reader_mode), label: 'Books'),
                  BottomNavigationBarItem(
                      icon: chatNotification
                          ? Badge(
                              color: Colors.red[400],
                              child: Icon(Icons.chat_bubble_rounded))
                          : Icon(Icons.chat),
                      label: 'Chat'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                  BottomNavigationBarItem(
                      icon: followingNotification
                          ? Badge(
                              color: Colors.red[400],
                              child: Icon(Icons.notifications_rounded))
                          : Icon(Icons.notifications_rounded),
                      label: 'Following'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: 'Settings'),
                ]),
            tabBuilder: (context, index) => _pages[index],
          );
  }
}
