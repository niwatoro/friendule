import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart' as auth;
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:intl/intl.dart";

import "../models/event.dart";
import "../models/notification.dart" as model;
import "../models/signal.dart";
import "../models/user.dart";
import "../services/authentication.dart";

class FirestoreService {
  final _usersCollectionRef = FirebaseFirestore.instance.collection("users");
  final _eventsCollectionRef = FirebaseFirestore.instance.collection("events");
  final _notificationsCollectionRef =
      FirebaseFirestore.instance.collection("notifications");
  final _storageRef = FirebaseStorage.instance.ref();

  Future<void> addUser(User user) async {
    try {
      await _usersCollectionRef.doc(user.userId).set(user.toMap());
    } catch (e) {
      debugPrint("addUser Error: $e");
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _usersCollectionRef.doc(user.userId).update(user.toMap());
    } catch (e) {
      debugPrint("updateUser Error: $e");
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final userDoc = await _usersCollectionRef.doc(userId).get();
      return User.fromMap(userDoc.data()!);
    } catch (e) {
      debugPrint("getUser Error: $e");
      return null;
    }
  }

  Stream<User?> getUserStream(String userId) async* {
    yield* _usersCollectionRef
        .doc(userId)
        .snapshots()
        .map((event) => User.fromMap(event.data()!));
  }

  Future<void> deleteUser(String userId) async {
    await _usersCollectionRef.doc(userId).delete();
  }

  Future<bool> checkIfUserExists(String userId) async {
    final exists =
        _usersCollectionRef.doc(userId).get().then((value) => value.exists);
    return exists;
  }

  Future<QuerySnapshot> searchUsers(String searchText) async {
    final searchResult = await _usersCollectionRef
        .where("name", isGreaterThanOrEqualTo: searchText)
        .where("name", isLessThan: "${searchText}z")
        .get();
    return searchResult;
  }

  Future<void> signIn() async {
    if (!AuthenticationService().getIsUserSignedIn()) {
      debugPrint("No user signed in");
      return;
    }

    final userId = AuthenticationService().getCurrentUserId();
    final exists = await checkIfUserExists(userId!);
    if (exists) {
      await getUser(userId);
    } else {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      await addUser(User(
          userId: authUser!.uid,
          username: authUser.uid,
          name: authUser.displayName ?? authUser.uid,
          photoUrl: authUser.photoURL,
          followers: [],
          followings: [],
          profile: "",
          token: ""));
    }
  }

  Future<List<String>> getFollowings(String userId) async {
    final userMap = await getUser(userId);
    return userMap!.followings;
  }

  Stream<List<String>> getFollowingsStream(String userId) async* {
    yield* _usersCollectionRef
        .doc(userId)
        .snapshots()
        .map((event) => User.fromMap(event.data()!).followings);
  }

  Future<void> addFollowing(String followingId) async {
    final userId = AuthenticationService().getCurrentUserId();
    final user = await getUser(userId!);
    final followings = user!.followings;
    followings.add(followingId);
    await updateUser(user);

    final followingUser = await getUser(followingId);
    final followers = followingUser!.followers;
    followers.add(userId);
    await updateUser(followingUser);

    sendNotification(model.Notification(
        title: "Follow (${user.name})",
        body: user.profile,
        sender: userId,
        receiver: followingId,
        createdAt: DateTime.now()));
  }

  Future<void> removeFollowing(String followingId) async {
    final userId = AuthenticationService().getCurrentUserId();
    final user = await getUser(userId!);
    final followings = user!.followings;
    followings.remove(followingId);
    await updateUser(user);

    final followingUser = await getUser(followingId);
    final followers = followingUser!.followers;
    followers.remove(userId);
    await updateUser(followingUser);
  }

  Future<bool> checkIfIFollow(String userId) async {
    final myId = AuthenticationService().getCurrentUserId();
    final followings = await getFollowings(myId!);
    return followings.contains(userId);
  }

  Stream<bool> checkIfIFollowStream(String userId) async* {
    final myId = AuthenticationService().getCurrentUserId();
    yield* _usersCollectionRef.doc(myId).snapshots().map(
        (event) => User.fromMap(event.data()!).followings.contains(userId));
  }

  Future<bool> checkIfIFollowed(String userId) async {
    final myId = AuthenticationService().getCurrentUserId();
    final user = await getUser(userId);
    final followers = user!.followers;
    return followers.contains(myId);
  }

  Future<void> updateFcmToken(String token) async {
    _usersCollectionRef
        .doc(AuthenticationService().getCurrentUserId())
        .update({"token": token});
  }

  String getEventId(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<void> addEvent(String userId, Event event) async {
    if (await checkIfEventExists(userId, event.dateString)) {
      debugPrint("Event already exists");
      return;
    }
    try {
      await _eventsCollectionRef
          .doc(userId)
          .collection("userEvents")
          .doc(event.dateString)
          .set({"date": event.getDateTime(), ...event.toMap()});
    } catch (e) {
      debugPrint("addEvent Error: $e");
    }
  }

  Future<void> updateEvent(String userId, Event event) async {
    try {
      await _eventsCollectionRef
          .doc(userId)
          .collection("userEvents")
          .doc(event.dateString)
          .update({"date": event.getDateTime(), ...event.toMap()});
    } catch (e) {
      debugPrint("updateEvent Error: $e");
    }
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _eventsCollectionRef
          .doc(userId)
          .collection("userEvents")
          .doc(eventId)
          .delete();
    } catch (e) {
      debugPrint("deleteEvent Error: $e");
    }
  }

  Future<bool> checkIfEventExists(String userId, String dateString) async {
    final exists = _eventsCollectionRef
        .doc(userId)
        .collection("userEvents")
        .doc(dateString)
        .get()
        .then((value) => value.exists);
    return exists;
  }

  Stream<List<Event>> getEventsStream(
      String userId, DateTime startDate, DateTime endDate) async* {
    try {
      final exactEndDate = endDate.add(const Duration(days: 1));
      final eventsQuerySnapshot = _eventsCollectionRef
          .doc(userId)
          .collection("userEvents")
          .where("date", isGreaterThanOrEqualTo: startDate)
          .orderBy("date")
          .snapshots();
      yield* eventsQuerySnapshot.map((eventQuerySnapshot) {
        final events = eventQuerySnapshot.docs
            .map((eventDoc) => Event.fromMap(eventDoc.data()))
            .where((element) {
          final dateTime = element.getDateTime();
          return dateTime.isBefore(exactEndDate) ||
              dateTime.isAtSameMomentAs(exactEndDate);
        }).toList();
        return events;
      });
    } catch (e) {
      debugPrint("getEventsStream Error: $e");
      yield [];
    }
  }

  Stream<Event> getEventStream(String userId, DateTime date) async* {
    try {
      final eventsQuerySnapshot = _eventsCollectionRef
          .doc(userId)
          .collection("userEvents")
          .doc(getEventId(date))
          .snapshots();
      yield* eventsQuerySnapshot.map((eventQuerySnapshot) {
        return Event.fromMap(eventQuerySnapshot.data()!);
      });
    } catch (e) {
      debugPrint("getEventsStream Error: $e");
    }
  }

  void sendSignal(Signal signal) async {
    try {
      final notification = model.Notification(
          createdAt: DateTime.now(),
          sender: signal.sender.userId,
          receiver: signal.receiverId,
          title:
              "Signal (${signal.sender.name}, ${DateFormat.MEd().format(signal.date)})",
          body: signal.message);
      await _notificationsCollectionRef
          .doc(signal.receiverId)
          .collection("userNotifications")
          .add(notification.toMap());
    } catch (e) {
      debugPrint("sendSignal Error: $e");
    }
  }

  void showSignalDialog(
      {required BuildContext context,
      required String to,
      required DateTime date}) {
    final controller = TextEditingController();
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: StreamBuilder<User?>(
                stream: getUserStream(to),
                builder: (context, snapshot) {
                  return Text(
                    "${AppLocalizations.of(context)!.signal} (${DateFormat.jm().format(date)}, ${snapshot.data?.name ?? "No Date"})",
                  );
                }),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: controller,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(
                  onPressed: () async {
                    final signal = Signal(
                        sender: (await getUser(
                            AuthenticationService().getCurrentUserId()!))!,
                        receiverId: to,
                        date: date,
                        message: controller.text);
                    sendSignal(signal);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.send))
            ],
          );
        });
  }

  Future<void> sendNotification(model.Notification notification) {
    return _notificationsCollectionRef
        .doc(notification.receiver)
        .collection("userNotifications")
        .add(notification.toMap());
  }

  Stream<List<model.Notification>> getNotificationsStream(
      String userId) async* {
    try {
      final notificationsQuerySnapshot = _notificationsCollectionRef
          .doc(userId)
          .collection("userNotifications")
          .orderBy("createdAt", descending: true)
          .snapshots();
      yield* notificationsQuerySnapshot.map((notificationsQuerySnapshot) {
        final notifications = notificationsQuerySnapshot.docs
            .map((notificationDoc) =>
                model.Notification.fromMap(notificationDoc.data()))
            .toList();
        return notifications;
      });
    } catch (e) {
      debugPrint("getNotificationsStream Error: $e");
      yield [];
    }
  }

  Future<String?> uploadPhoto(String path) async {
    try {
      final file = File(path);
      final fileRef = _storageRef.child("images/${file.path.split("/").last}");
      final uploadTask = fileRef.putFile(file);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint("uploadPhoto Error: $e");
    }
    return null;
  }
}
