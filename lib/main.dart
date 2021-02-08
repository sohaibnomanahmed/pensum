import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'authentication/authentication_provider.dart';
import 'authentication/authentication_page.dart';
import 'authentication/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.authStateChanges().isEmpty;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          textTheme: GoogleFonts.ralewayTextTheme(Theme.of(context).textTheme),
        ),
        home: Consumer<User>(
          builder: (context, user, child) {
            return (user == null || !user.emailVerified)
                ? AuthenticationPage()
                : HomePage();
          },
        ),
      ),
    );
  }
}
