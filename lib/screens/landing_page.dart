import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/screens/home_page.dart';
import 'package:friendule/services/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/transparent_appbar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _authenticationService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _subscripbeToMyTopic();
  }

  void _subscripbeToMyTopic() async {
    final userId = _authenticationService.getCurrentUserId();
    if (userId != null) {
      await FirebaseMessaging.instance.subscribeToTopic(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TransparentAppBar(
          appBar: AppBar(),
          title: const Text("Friendule"),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
          const Text('Welcome to Friendule'),
          const SizedBox(
            height: 20,
          ),
          LogInButton(
            icon: const Icon(MdiIcons.google),
            bgColor: Colors.blueAccent,
            child: Text(AppLocalizations.of(context)!.signin_with_google),
            onPressed: () async {
              await _authenticationService.signInWithGoogle();
              if (_authenticationService.getIsUserSignedIn() && mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()));
              }
            },
          ),
          const SizedBox(
            height: 8,
          ),
          LogInButton(
            icon: const Icon(MdiIcons.apple),
            bgColor: Colors.black,
            child: Text(AppLocalizations.of(context)!.signin_with_apple),
            onPressed: () async {
              await AuthenticationService().signInWithApple();
              if (AuthenticationService().getIsUserSignedIn() && mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()));
              }
            },
          ),
        ])));
  }
}

class LogInButton extends StatelessWidget {
  final Icon icon;
  final Color bgColor;
  final Widget child;
  final void Function() onPressed;
  const LogInButton(
      {super.key,
      required this.icon,
      required this.bgColor,
      required this.child,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(16)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        )),
        backgroundColor: MaterialStateProperty.all<Color>(bgColor),
      ),
      icon: icon,
      label: SizedBox(width: 200, child: child),
    );
  }
}
