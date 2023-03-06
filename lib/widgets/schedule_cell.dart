import 'package:flutter/material.dart';

class ScheduleCell extends StatefulWidget {
  final int hour;
  final bool isOccupied;
  final bool? isOccupiedByUser;
  final void Function() setOccupied;
  final bool isRightMost;
  const ScheduleCell(
      {super.key,
      required this.hour,
      required this.isOccupied,
      this.isOccupiedByUser,
      required this.setOccupied,
      this.isRightMost = false});

  @override
  State<ScheduleCell> createState() => _ScheduleCellState();
}

class _ScheduleCellState extends State<ScheduleCell> {
  int? _hour;
  bool? _isOccupied;
  bool? _isOccupiedByUser;
  void Function()? _setOccupied;
  bool? _isRightMost;

  @override
  void initState() {
    super.initState();
    _hour = widget.hour;
    _isOccupied = widget.isOccupied;
    _isOccupiedByUser = widget.isOccupiedByUser;
    _setOccupied = widget.setOccupied;
    _isRightMost = widget.isRightMost;
  }

  @override
  void didUpdateWidget(covariant ScheduleCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hour = widget.hour;
    _isOccupied = widget.isOccupied;
    _isOccupiedByUser = widget.isOccupiedByUser;
    _setOccupied = widget.setOccupied;
    _isRightMost = widget.isRightMost;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _hour != null && _isOccupied != null,
      child: GestureDetector(
        onTap: _setOccupied,
        child: Container(
          decoration: BoxDecoration(
              color: _isOccupied ?? false
                  ? Colors.blue
                  : _isOccupiedByUser ?? false
                      ? Colors.orange
                      : Colors.transparent,
              border: Border(
                top: BorderSide(
                    color: _hour == 0
                        ? Theme.of(context).shadowColor
                        : Colors.transparent),
                right: BorderSide(
                    color: _isRightMost ?? false
                        ? Theme.of(context).shadowColor
                        : Colors.transparent),
                left: BorderSide(color: Theme.of(context).shadowColor),
                bottom: BorderSide(color: Theme.of(context).shadowColor),
              )),
        ),
      ),
    );
  }
}
