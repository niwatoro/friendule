import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:friendule/services/firestore.dart";

import "../models/user.dart";
import "../services/authentication.dart";

class AddFollowingPage extends StatefulWidget {
  const AddFollowingPage({super.key});

  @override
  State<AddFollowingPage> createState() => _AddFollowingPageState();
}

class _AddFollowingPageState extends State<AddFollowingPage> {
  final TextEditingController _searchController = TextEditingController();
  QuerySnapshot? querySnapshot;
  final _userId = AuthenticationService().getCurrentUserId()!;
  final _firestoreService = FirestoreService();

  void _searchUsers(String searchText) async {
    final searchResult = await _firestoreService.searchUsers(searchText);
    setState(() {
      querySnapshot = searchResult;
    });
  }

  void _addFollowing(String followingId) async {
    _firestoreService.addFollowing(followingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.followed)));
  }

  void _removeFollowing(String followingId) {
    _firestoreService.removeFollowing(followingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.unfollowed)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.search_user),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  hintText: "Search for users",
                  prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchUsers(value);
                } else {
                  setState(() {
                    querySnapshot = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          querySnapshot != null
              ? StreamBuilder<User?>(
                  stream: FirestoreService().getUserStream(_userId),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    if (user == null) {
                      return const SizedBox.shrink();
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: querySnapshot!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = querySnapshot!.docs[index];

                          if (doc["userId"] == _userId) {
                            return const SizedBox.shrink();
                          }

                          final isFollowing = user.followings
                              .contains(querySnapshot!.docs[index].id);
                          return ListTile(
                            leading: doc["photoUrl"] == null
                                ? const CircleAvatar(
                                    child: Text(
                                    "No\nData",
                                    style: TextStyle(fontSize: 10),
                                  ))
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(doc["photoUrl"])),
                            title: Text(doc["name"]),
                            subtitle: Text(doc["profile"]),
                            trailing: isFollowing
                                ? IconButton(
                                    onPressed: () {
                                      _removeFollowing(doc.id);
                                    },
                                    icon: const Icon(Icons.remove))
                                : IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _addFollowing(doc.id);
                                    }),
                          );
                        },
                      ),
                    );
                  })
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
