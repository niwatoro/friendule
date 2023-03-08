import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/services/authentication.dart';
import 'package:friendule/services/firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: ListView(children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.terms_of_service),
            onTap: () async {
              final url = Uri.parse(
                  "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/");
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                debugPrint("Could not launch $url");
              }
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.privacy_policy),
            onTap: () async {
              final url =
                  Uri.parse("https://www.niwatoro.com/friendule/privacypolicy");
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                debugPrint("Could not launch $url");
              }
            },
          ),
          ListTile(
              title: Text(
                AppLocalizations.of(context)!.delete_account,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title:
                            Text(AppLocalizations.of(context)!.delete_account),
                        content: Text(AppLocalizations.of(context)!
                            .delete_account_confirm),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              await AuthenticationService().signOut();
                              await FirestoreService().deleteUser(
                                  AuthenticationService().getCurrentUserId()!);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
                          )
                        ],
                      );
                    });
              })
        ]));
  }
}
