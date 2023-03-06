import 'package:flutter/material.dart';

class TimelineCell extends StatefulWidget {
  final int hour;
  final int day;
  const TimelineCell({super.key, required this.day, required this.hour});

  @override
  State<TimelineCell> createState() => _TimelineCellState();
}

class _TimelineCellState extends State<TimelineCell> {
  int? _hour;

  final _fontSize = 12;

  Border? _firstRowCellBorder;
  Border? _otherBorder;

  @override
  void initState() {
    super.initState();
    _hour = widget.hour;
  }

  @override
  void didUpdateWidget(covariant TimelineCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hour = widget.hour;
  }

  @override
  Widget build(BuildContext context) {
    _firstRowCellBorder ??= Border(
      top: BorderSide(color: Theme.of(context).shadowColor),
      left: BorderSide(color: Theme.of(context).shadowColor),
      bottom: BorderSide(color: Theme.of(context).shadowColor),
    );
    _otherBorder ??= Border(
      left: BorderSide(color: Theme.of(context).shadowColor),
      bottom: BorderSide(color: Theme.of(context).shadowColor),
    );
    return Visibility(
      visible: _hour != null && _hour != 0,
      child: Container(
        transform: Matrix4.translationValues(0, -_fontSize / 2 - 3, 0),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _fontSize.toDouble() + 2,
                child: Text(
                  "${(_hour == 12 ? 12 : _hour! % 12).toString()} ${_hour! < 12 ? "AM" : "PM"}",
                  style: TextStyle(
                    fontSize: _fontSize.toDouble(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
