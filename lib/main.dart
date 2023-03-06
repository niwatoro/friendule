import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/screens/home_page.dart';
import 'package:friendule/screens/landing_page.dart';

import 'firebase_options.dart';
import 'services/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Friendule',
      theme: ThemeData(
        shadowColor: Colors.grey.shade300,
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationService().getIsUserSignedIn()
          ? const HomePage()
          : const LandingPage(),
    );
  }
}
