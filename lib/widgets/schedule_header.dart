import 'package:flutter/material.dart';

class ScheduleHeader extends StatelessWidget {
  final DateTime firstDayOfWeek;
  final DateTime now;
  final List<String> days;

  const ScheduleHeader({
    super.key,
    required this.firstDayOfWeek,
    required this.now,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).shadowColor)),
      ),
      child: Row(
        children: List.generate(8, (index) {
          if (index == 0) {
            return const Expanded(
              child: Center(
                child: Icon(Icons.swipe_sharp),
              ),
            );
          }
          final displayedDate = firstDayOfWeek.add(Duration(days: index - 1));
          final isToday = now.year == displayedDate.year &&
              now.month == displayedDate.month &&
              now.day == displayedDate.day;
          return Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    days[index - 1],
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? Colors.blue : Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              displayedDate.day.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: isToday
                                      ? Colors.white
                                      : index == 1
                                          ? Colors.red
                                          : index == 7
                                              ? Colors.blue
                                              : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
