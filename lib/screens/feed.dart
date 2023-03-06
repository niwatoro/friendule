import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friendule/services/authentication.dart';
import 'package:friendule/services/firestore.dart';
import 'package:friendule/widgets/feed_header.dart';
import 'package:friendule/widgets/schedule_cell.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../widgets/schedule_timeline.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final _firestoreService = FirestoreService();
  final _userId = AuthenticationService().getCurrentUserId();

  final int _headerHeight = 60;

  final _now = DateTime.now();
  late DateTime _displayedDate;

  int _followingIndex = 0;
  List<String> _displayedFollowings = [];

  @override
  void initState() {
    super.initState();
    _displayedDate = DateTime(_now.year, _now.month, _now.day);
  }

  void _displayDayBefore() {
    setState(() {
      _displayedDate = _displayedDate.subtract(const Duration(days: 1));
    });
  }

  void _displayNextDay() {
    setState(() {
      _displayedDate = _displayedDate.add(const Duration(days: 1));
    });
  }

  void _displayBeforeFollowings(List<String> followings) {
    setState(() {
      final followingIndex = max(0, _followingIndex - 7);
      _displayedFollowings = followings.sublist(
          followingIndex, min(followingIndex + 7, followings.length));
      _followingIndex = followingIndex;
    });
  }

  void _displayNextFollowings(List<String> followings) {
    setState(() {
      final followingIndex = min(_followingIndex + 7, followings.length - 1);
      _displayedFollowings = followings.sublist(
          followingIndex, min(followingIndex + 7, followings.length));
      _followingIndex = followingIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<String>>(
          stream: _firestoreService.getFollowingsStream(_userId!),
          builder: (context, snapshot) {
            final followings = snapshot.data ?? [];
            _displayedFollowings = followings.sublist(_followingIndex);
            return Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: _displayDayBefore,
                              icon: const Icon(Icons.chevron_left_sharp)),
                          TextButton(
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: _displayedDate,
                                      firstDate: DateTime(2022),
                                      lastDate: DateTime(2032))
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    _displayedDate = value;
                                  });
                                }
                              });
                            },
                            child: Text(DateFormat.MEd().format(_displayedDate),
                                style: const TextStyle(fontSize: 20)),
                          ),
                          IconButton(
                              onPressed: _displayNextDay,
                              icon: const Icon(Icons.chevron_right_sharp)),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                            height: _headerHeight.toDouble(),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Theme.of(context).shadowColor))),
                              child:
                                  const Center(child: Icon(Icons.swipe_sharp)),
                            ))),
                    ...List.generate(7, (index) {
                      final isMyProfile = index == 0;
                      return Expanded(
                          child: FeedHeaderCell(
                              isMyProfile: isMyProfile,
                              userId: isMyProfile
                                  ? _userId
                                  : index > _displayedFollowings.length
                                      ? null
                                      : _displayedFollowings[index - 1],
                              headerHeight: _headerHeight));
                    })
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dx > 0) {
                          _displayBeforeFollowings(followings);
                        } else if (details.velocity.pixelsPerSecond.dx < 0) {
                          _displayNextFollowings(followings);
                        }
                      },
                      child: SizedBox(
                        height: 1000,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 8,
                                child: Column(
                                  children: List.generate(
                                      24,
                                      (index) => Expanded(
                                            child: TimelineCell(
                                                day: 0, hour: index),
                                          )),
                                )),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 8,
                              child: Column(
                                  children: List.generate(24, (index) {
                                return Expanded(
                                  child: StreamBuilder<Event>(
                                      stream: _firestoreService.getEventStream(
                                          _userId!, _displayedDate),
                                      builder: (context, snapshot) {
                                        return ScheduleCell(
                                          hour: index % 24,
                                          isOccupied:
                                              snapshot.data?.isOccupiedList[
                                                      index % 24] ??
                                                  false,
                                          setOccupied: () {},
                                          isRightMost:
                                              _displayedFollowings.isEmpty,
                                        );
                                      }),
                                );
                              })),
                            ),
                            Expanded(
                              child: Row(
                                children: List.generate(6, (userIndex) {
                                  return Expanded(
                                    child: Column(
                                      children: List.generate(24, (hour) {
                                        return Expanded(
                                          child: userIndex >=
                                                  _displayedFollowings.length
                                              ? Container()
                                              : StreamBuilder<Event>(
                                                  stream: _firestoreService
                                                      .getEventStream(
                                                          _displayedFollowings[
                                                              userIndex],
                                                          _displayedDate),
                                                  builder: (context, snapshot) {
                                                    return GestureDetector(
                                                      onLongPress: () {
                                                        _firestoreService.showSignalDialog(
                                                            context: context,
                                                            to: _displayedFollowings[
                                                                userIndex],
                                                            date: DateTime(
                                                                _displayedDate
                                                                    .year,
                                                                _displayedDate
                                                                    .month,
                                                                _displayedDate
                                                                    .day,
                                                                hour));
                                                      },
                                                      child: ScheduleCell(
                                                          hour: hour,
                                                          isOccupied: false,
                                                          isOccupiedByUser: snapshot
                                                                      .data
                                                                      ?.isOccupiedList[
                                                                  hour] ??
                                                              false,
                                                          setOccupied: () {},
                                                          isRightMost: userIndex ==
                                                              _displayedFollowings
                                                                      .length -
                                                                  1),
                                                    );
                                                  }),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
