import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'authentication/authentication_provider.dart';
import 'authentication/authentication_page.dart';
import 'authentication/home_page.dart';
import 'global/services.dart';
import 'messages/messages_page.dart';
import 'messages/messages_provider.dart';
import 'global/404_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.authStateChanges().isEmpty;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Switch host based on platform.
  final host = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2:8080'
      : 'localhost:8080';
  // setup local developement environment
  FirebaseService.firestore.settings  =
    Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  await FirebaseService.firebaseAuth.useEmulator('http://localhost:9099'); 
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // for Android
      statusBarIconBrightness: Brightness.dark, // for Android
      statusBarBrightness: Brightness.dark // for IOS
      ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (ctx) => AuthenticationProvider(),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationProvider>().authState,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            textTheme:
                GoogleFonts.ralewayTextTheme(Theme.of(context).textTheme),
            cardTheme: Theme.of(context).cardTheme.copyWith(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
        home: Consumer<User>(
          builder: (context, user, child) {
            return (user == null || !user.emailVerified)
                ? AuthenticationPage()
                : HomePage();
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
                builder: (_) => ChangeNotifierProvider<MessagesProvider>(
                  create: (_) => MessagesProvider(),
                  child: MessagesPage(
                    rid: args['id'],
                    receiverName: args['name'],
                    receiverImage: args['image'],
                  ),
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
