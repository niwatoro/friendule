import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendule/models/user.dart';

class Signal {
  final User sender;
  final String receiverId;
  final DateTime date;
  final String message;

  Signal({
    required this.sender,
    required this.receiverId,
    required this.date,
    required this.message,
  });

  factory Signal.fromMap(Map<String, dynamic> map) {
    return Signal(
      sender: map["sender"],
      receiverId: map["receiverId"],
      date: (map["date"] as Timestamp).toDate(),
      message: map["message"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "receiverId": receiverId,
      "date": date,
      "message": message,
    };
  }
}
