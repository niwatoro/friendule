import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/user_detail_page.dart';
import '../services/firestore.dart';

class FeedHeaderCell extends StatelessWidget {
  final int headerHeight;
  final String? userId;
  final bool isMyProfile;
  const FeedHeaderCell({
    super.key,
    required this.headerHeight,
    required this.userId,
    required this.isMyProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: headerHeight.toDouble(),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).shadowColor))),
        child: userId == null
            ? Container()
            : Visibility(
                visible: userId != null,
                child: FutureBuilder<User?>(
                    future: FirestoreService().getUser(userId!),
                    builder: (context, snapshot) {
                      final photoUrl = snapshot.data?.photoUrl;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDetailPage(
                                        userId: userId!,
                                        isMyProfile: isMyProfile,
                                      )));
                        },
                        child: Center(
                            child: Column(
                          children: [
                            Text(
                              snapshot.data?.name ?? "No Data",
                              style: const TextStyle(
                                  fontSize: 10,
                                  overflow: TextOverflow.ellipsis),
                              maxLines: 1,
                            ),
                            Expanded(
                              child: photoUrl == null
                                  ? const CircleAvatar(
                                      child: Text(
                                        "No\nData",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(photoUrl),
                                    ),
                            )
                          ],
                        )),
                      );
                    }),
              ),
      ),
    );
  }
}
