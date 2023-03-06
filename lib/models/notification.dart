import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String sender;
  final String receiver;
  final String title;
  final String body;
  final DateTime createdAt;

  Notification({
    required this.sender,
    required this.receiver,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      sender: map["sender"],
      receiver: map["receiver"],
      title: map["title"],
      body: map["body"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "receiver": receiver,
      "title": title,
      "body": body,
      "createdAt": createdAt,
    };
  }
}
