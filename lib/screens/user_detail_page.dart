import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/screens/edit_profile.dart';
import 'package:friendule/screens/my_schedule.dart';
import 'package:friendule/services/firestore.dart';
import 'package:friendule/widgets/user_schedule.dart';

import '../models/user.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final bool isMyProfile;

  const UserDetailPage(
      {super.key, required this.userId, required this.isMyProfile});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late final String _userId;
  late final bool _isMyProfile;
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _isMyProfile = widget.isMyProfile;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _firestore.getUserStream(_userId),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              actions: [
                Visibility(
                  visible: !_isMyProfile,
                  child: DropdownButton(
                    underline: Container(),
                    onChanged: (value) {
                      switch (value) {
                        case "report":
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.report),
                              content: Text(
                                  AppLocalizations.of(context)!.report_content),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.report),
                                ),
                              ],
                            ),
                          );
                          break;
                        default:
                      }
                    },
                    icon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: "report",
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.report),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      user.photoUrl == null
                          ? const CircleAvatar(
                              child: Text("No Data"),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(user.photoUrl!),
                            ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "@${user.username}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      user.profile.isEmpty
                          ? const Text("(bio not set)",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic))
                          : Text(user.profile),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(user.followers.length.toString()),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.followers,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Row(
                            children: [
                              Text(user.followings.length.toString()),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.followings,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isMyProfile
                      ? FullWidthButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const EditProfile()));
                          },
                          label: AppLocalizations.of(context)!.edit_profile,
                        )
                      : StreamBuilder<bool>(
                          stream: FirestoreService()
                              .checkIfIFollowStream(user.userId),
                          builder: (context, snapshot) {
                            final bool isFollowing = snapshot.data ?? false;
                            if (isFollowing) {
                              return FullWidthButton(
                                  onPressed: () async {
                                    _firestore.removeFollowing(user.userId);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .unfollowed)));
                                  },
                                  label:
                                      AppLocalizations.of(context)!.unfollow);
                            }
                            return FullWidthButton(
                                onPressed: () async {
                                  _firestore.addFollowing(user.userId);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .followed)));
                                },
                                label: AppLocalizations.of(context)!.follow);
                          },
                        ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                      top: BorderSide(color: Theme.of(context).shadowColor),
                    )),
                    child: _isMyProfile
                        ? const MySchedule()
                        : UserSchedule(userId: user.userId),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class FullWidthButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  const FullWidthButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          )),
      onPressed: onPressed,
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ))),
    );
  }
}
