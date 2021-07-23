import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry, kDebugMode;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaf/authentication/onboarding_page.dart';
import 'package:leaf/authentication/update_page.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presence/presence_provider.dart';
import 'profile/profile_page.dart';
import 'profile/profile_provider.dart';
import 'authentication/authentication_provider.dart';
import 'authentication/authentication_page.dart';
import 'authentication/home_page.dart';
import 'messages/messages_page.dart';
import 'messages/messages_provider.dart';
import 'global/404_page.dart';
import 'notifications/notification_provider.dart';

// ------------- FIREBASE EMULATOR -----------------
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ------------- FIREBASE EMULATOR -----------------
  // // Switch host based on platform.
  // final host = defaultTargetPlatform == TargetPlatform.android
  //     ? '10.0.2.2:9080'
  //     : 'localhost:9080';
  // // setup local developement environment
  // FirebaseFirestore.instance.settings  =
  //   Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  // await FirebaseAuth.instance.useEmulator('http://localhost:9099');
  // await FirebaseStorage.instance.useEmulator(host: 'localhost', port: 9199);

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
  // check if onboarding is needed
  _sharedPreferences = await SharedPreferences.getInstance();
  // check if logged in
  await FirebaseAuth.instance.authStateChanges().isEmpty;
  // check if update is needed
  final newVersion = NewVersion();
  status = await newVersion.getVersionStatus();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // for Android
      statusBarIconBrightness: Brightness.dark, // for Android
      statusBarBrightness: Brightness.light // for IOS
      )); 

  // lisence for fonts
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });       
  runApp(MyApp());
}

// shared prefrences to check if onboarding is complete or not
late SharedPreferences _sharedPreferences;
late VersionStatus? status;
bool lock = false;

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
          initialData: null,
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
        // HAS STILL MANY ISSUES NOT YET READY FOR EASY USE
        // darkTheme: ThemeData(
        //   primarySwatch: Colors.teal,
        //   brightness: Brightness.dark,
        //   cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark),
        //   textTheme: GoogleFonts.ralewayTextTheme(
        //       ThemeData(brightness: Brightness.dark).textTheme),
        //   elevatedButtonTheme: ElevatedButtonThemeData(
        //       style: ElevatedButton.styleFrom(
        //     elevation: 0,
        //   )),
        //   cardTheme: Theme.of(context).cardTheme.copyWith(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(10))),
        // ),
        //ThemeData.dark(),
        home: status!.canUpdate ? UpdatePage(status: status) : Consumer<User?>(
          builder: (context, user, child) {
            if (_sharedPreferences.getBool('ONBOARD') ?? true && !lock) {
              // avoid race conditions
              lock = true;
              late OverlayEntry onboardingScreen;
              onboardingScreen = OverlayEntry(
                  builder: (_) => OnboardingPage(onboardingScreen));
              WidgetsBinding.instance!.addPostFrameCallback(
                  (_) => Overlay.of(context)!.insert(onboardingScreen));
            }
            return (user == null || !user.emailVerified)
                ? AuthenticationPage()
                : MultiProvider(
                    providers: [
                      ChangeNotifierProvider<NotificationProvider>(
                        create: (ctx) => NotificationProvider()
                      ),
                      ChangeNotifierProvider<PresenceProvider>(
                        create: (ctx) => PresenceProvider()
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
              final args = settings.arguments as Map<String, dynamic>;
              final rid = args['id'];
              final receiverImage = args['image'];
              final receiverName = args['name'];
              if (rid == null ||
                  receiverName == null ||
                  receiverImage == null) {
                return MaterialPageRoute(builder: (_) => PageNotFound());
              }
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => MessagesProvider(),
                  child: MessagesPage(
                    rid: rid,
                    receiverName: receiverName,
                    receiverImage: receiverImage,
                  ),
                ),
              );
            case ProfilePage.routeName:
              final uid = settings.arguments as String?;
              if (uid == null) {
                return MaterialPageRoute(builder: (_) => PageNotFound());
              }
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
