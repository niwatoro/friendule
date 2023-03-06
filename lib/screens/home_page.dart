import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/screens/feed.dart';
import 'package:friendule/screens/my_schedule.dart';
import 'package:friendule/screens/settings.dart';
import 'package:friendule/services/authentication.dart';
import 'package:friendule/services/firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/user.dart';
import 'add_following.dart';
import 'landing_page.dart';
import 'notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authenticationService = AuthenticationService();

  int _currentIndex = 0;
  final _tabs = [const MySchedule(), const Feed()];

  @override
  void initState() {
    super.initState();
    _getFcmToken();
  }

  Future<void> _getFcmToken() async {
    final token = await _authenticationService.getFcmToken();
    if (token != null) {
      await FirestoreService().updateFcmToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirestoreService()
            .getUserStream(_authenticationService.getCurrentUserId()!),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Friendule"),
              actions: [
                IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => const NotificationPage());
                    },
                    icon: const Icon(Icons.notifications_sharp)),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AddFollowingPage()));
                    },
                    icon: const Icon(Icons.person_add_alt_1_sharp)),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: user == null
                        ? Center(
                            child: LoadingAnimationWidget.waveDots(
                                color: Colors.blue, size: 30))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                user.name,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                              user.photoUrl == null
                                  ? const Center(
                                      child: Text("No Data"),
                                    )
                                  : Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.fitHeight,
                                    ),
                            ],
                          ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_sharp),
                    title: Text(AppLocalizations.of(context)!.settings),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_sharp),
                    title: Text(AppLocalizations.of(context)!.logout),
                    onTap: () async {
                      await _authenticationService.signOut();
                      if (!_authenticationService.getIsUserSignedIn() &&
                          mounted) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LandingPage()));
                      }
                    },
                  ),
                ],
              ),
            ),
            body: _tabs[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
                onTap: (value) {
                  setState(() {
                    _currentIndex = value;
                  });
                },
                currentIndex: _currentIndex,
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.calendar_month_sharp),
                      label: AppLocalizations.of(context)!.myschedule),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.people_sharp),
                      label: AppLocalizations.of(context)!.feed),
                ]),
          );
        });
  }
}
