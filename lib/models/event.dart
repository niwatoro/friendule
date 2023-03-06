class Event {
  final String dateString;
  final List<bool> isOccupiedList;

  Event({
    required this.dateString,
    required this.isOccupiedList,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      dateString: map["dateString"],
      isOccupiedList: List<bool>.from(map["isOccupiedList"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "dateString": dateString,
      "isOccupiedList": isOccupiedList,
    };
  }

  DateTime getDateTime() {
    return DateTime.parse(dateString);
  }
}
