import 'package:flutter/material.dart';
import 'package:friendule/constants.dart';
import 'package:friendule/services/authentication.dart';
import 'package:friendule/services/firestore.dart';

import '../models/event.dart';
import '../widgets/schedule_cell.dart';
import '../widgets/schedule_header.dart';
import '../widgets/schedule_timeline.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({super.key});

  @override
  State<MySchedule> createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  final _firestoreService = FirestoreService();
  final _userId = AuthenticationService().getCurrentUserId()!;

  final int _cellHeight = 40;
  final int _headerHeight = 60;

  List<String>? _days;
  List<String>? _months;
  final _now = DateTime.now();
  late DateTime _firstDayOfWeek;

  Map<String, List<bool>> _isOccupiedMap = {};
  List<List<bool>> _isOccupiedListByDay = [];

  @override
  void initState() {
    super.initState();
    _firstDayOfWeek =
        DateTime(_now.year, _now.month, _now.day).subtract(Duration(
      days: _now.weekday % 7,
    ));
  }

  void _displayNextWeek() {
    setState(() {
      _firstDayOfWeek = _firstDayOfWeek.add(const Duration(days: 7));
    });
  }

  void _displayLastWeek() {
    setState(() {
      _firstDayOfWeek = _firstDayOfWeek.subtract(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    _days ??= days(context);
    _months ??= months(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: _displayLastWeek,
                  icon: const Icon(Icons.chevron_left_sharp)),
              Text(
                _months![_firstDayOfWeek.month - 1],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              IconButton(
                  onPressed: _displayNextWeek,
                  icon: const Icon(Icons.chevron_right_sharp)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: _headerHeight.toDouble(),
                child: ScheduleHeader(
                  days: _days!,
                  firstDayOfWeek: _firstDayOfWeek,
                  now: _now,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Event>>(
                    stream: _firestoreService.getEventsStream(
                        _userId,
                        _firstDayOfWeek,
                        _firstDayOfWeek.add(const Duration(days: 8))),
                    builder: (context, snapshot) {
                      final events = snapshot.data;
                      if (events != null) {
                        _isOccupiedMap = {
                          for (var e in events) e.dateString: e.isOccupiedList
                        };
                        _isOccupiedListByDay = List.generate(
                            7, (index) => List.generate(24, (index) => false));
                      }
                      for (int i = 0; i < 7; i++) {
                        final date = _firstDayOfWeek.add(Duration(days: i));
                        final dateString = _firestoreService.getEventId(date);
                        if (_isOccupiedMap.keys.contains(dateString)) {
                          _isOccupiedListByDay[i] = _isOccupiedMap[dateString]!;
                        } else {
                          _firestoreService.addEvent(
                              _userId,
                              Event.fromMap({
                                "dateString": dateString,
                                "date": date,
                                "isOccupiedList":
                                    List.generate(24, (index) => false)
                              }));
                        }
                      }
                      return GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.velocity.pixelsPerSecond.dx > 0) {
                            _displayLastWeek();
                          } else if (details.velocity.pixelsPerSecond.dx < 0) {
                            _displayNextWeek();
                          }
                        },
                        child: GridView.count(
                            childAspectRatio:
                                (MediaQuery.of(context).size.width / 8) /
                                    _cellHeight,
                            crossAxisCount: 8,
                            children: List.generate(8 * 24, (index) {
                              final int hour = index ~/ 8;
                              final int day = index % 8;
                              if (day == 0) {
                                return TimelineCell(
                                  day: day,
                                  hour: hour,
                                );
                              }
                              final DateTime date =
                                  _firstDayOfWeek.add(Duration(days: day - 1));
                              final bool isOccupied =
                                  day == 0 || _isOccupiedListByDay.length < 7
                                      ? false
                                      : _isOccupiedListByDay[day - 1][hour];
                              return ScheduleCell(
                                hour: hour,
                                isOccupied: isOccupied,
                                setOccupied: () {
                                  setState(() {
                                    _firestoreService.updateEvent(
                                      _userId,
                                      Event.fromMap({
                                        "dateString":
                                            _firestoreService.getEventId(date),
                                        "isOccupiedList":
                                            _isOccupiedListByDay[day - 1]
                                              ..[hour] = !isOccupied,
                                      }),
                                    );
                                  });
                                },
                                isRightMost: day == 7,
                              );
                            })),
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
