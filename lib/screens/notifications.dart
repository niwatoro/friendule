import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/services/authentication.dart';
import 'package:friendule/services/firestore.dart';

import '../models/notification.dart' as model;

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.notifications),
      ),
      body: StreamBuilder<List<model.Notification>>(
          stream: FirestoreService().getNotificationsStream(
              AuthenticationService().getCurrentUserId()!),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            return ListView.builder(
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body));
              },
              itemCount: notifications.length,
            );
          }),
    );
  }
}
