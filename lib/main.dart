import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaf/presence/presence_provider.dart';
import 'package:leaf/profile/profile_page.dart';
import 'package:leaf/profile/profile_provider.dart';
import 'package:provider/provider.dart';

import 'authentication/authentication_provider.dart';
import 'authentication/authentication_page.dart';
import 'authentication/home_page.dart';
import 'messages/messages_page.dart';
import 'messages/messages_provider.dart';
import 'global/404_page.dart';
import 'notifications/notification_provider.dart';

// // emulator related
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // // Switch host based on platform.
  // final host = defaultTargetPlatform == TargetPlatform.android
  //     ? '10.0.2.2:8080'
  //     : 'localhost:8080';
  // // setup local developement environment
  // FirebaseFirestore.instance.settings  =
  //   Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  // await FirebaseAuth.instance.useEmulator('http://localhost:9099');

  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Handle Crashlytics enabled status when not in Debug,
    // e.g. allow your users to opt-in to crash reporting.
    
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  await FirebaseAuth.instance.authStateChanges().isEmpty;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // for Android
      statusBarIconBrightness: Brightness.dark, // for Android
      statusBarBrightness: Brightness.light // for IOS
      ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthenticationProvider(),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationProvider>().authState,
        )
      ],
      child: MaterialApp(
        title: 'Leaf',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            textTheme:
                GoogleFonts.ralewayTextTheme(Theme.of(context).textTheme),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
              elevation: 0,
            )),
            cardTheme: Theme.of(context).cardTheme.copyWith(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
        home: Consumer<User>(
          builder: (context, user, child) {
            return (user == null || !user.emailVerified)
                ? AuthenticationPage()
                : MultiProvider(
                    providers: [
                      ChangeNotifierProvider<NotificationProvider>(
                        create: (ctx) => NotificationProvider(),
                      ),
                      ChangeNotifierProvider<PresenceProvider>(
                        create: (ctx) => PresenceProvider(),
                      ),
                    ],
                    child: HomePage(),
                  );
          },
        ),
        /**
          * Here we have a list of possible routes from the main navigator, 
          * these will create a page on the whole screen and are listed here for 
          * easier lookup table. Since some of them need input variables, we use the 
          * on GenerateRoute method and throught the settings value we can provide
          * input as condstuctor values.
          */
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case MessagesPage.routeName:
              Map args = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => MessagesProvider(),
                  child: MessagesPage(
                    rid: args['id'],
                    receiverName: args['name'],
                    receiverImage: args['image'],
                  ),
                ),
              );
            case ProfilePage.routeName:
              String uid = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ProfileProvider(),
                  child: ProfilePage(uid),
                ),
              );
            default:
              return MaterialPageRoute(builder: (_) => PageNotFound());
          }
        },
      ),
    );
  }
}
