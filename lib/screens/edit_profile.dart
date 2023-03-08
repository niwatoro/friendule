import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:friendule/widgets/profile_photo.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../services/authentication.dart';
import '../services/firestore.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _firestore = FirestoreService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    final user =
        await _firestore.getUser(AuthenticationService().getCurrentUserId()!);
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit_profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _firestore.updateUser(_user!);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: _user == null
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhotoUploader(
                      photoUrl: _user!.photoUrl,
                      setPhoto: (String path) async {
                        final storagePath = await _firestore.uploadPhoto(path);
                        if (storagePath == null) {
                          return;
                        }
                        setState(() {
                          _user = User(
                              userId: _user!.userId,
                              username: _user!.username,
                              name: _user!.name,
                              photoUrl: storagePath,
                              followers: _user!.followers,
                              followings: _user!.followings,
                              blockUsers: _user!.blockUsers,
                              profile: _user!.profile,
                              token: _user!.token);
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _user?.name ?? "",
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.display_name),
                      onChanged: (value) {
                        setState(() {
                          _user = User(
                              userId: _user!.userId,
                              username: _user!.username,
                              name: value,
                              photoUrl: _user!.photoUrl,
                              followers: _user!.followers,
                              followings: _user!.followings,
                              blockUsers: _user!.blockUsers,
                              profile: _user!.profile,
                              token: _user!.token);
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _user?.username ?? "",
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.username),
                      onChanged: (value) {
                        setState(() {
                          _user = User(
                              userId: _user!.userId,
                              username: value,
                              name: _user!.name,
                              photoUrl: _user!.photoUrl,
                              followers: _user!.followers,
                              followings: _user!.followings,
                              blockUsers: _user!.blockUsers,
                              profile: _user!.profile,
                              token: _user!.token);
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _user?.profile ?? "",
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.profile),
                      onChanged: (value) {
                        setState(() {
                          _user = User(
                              userId: _user!.userId,
                              username: _user!.username,
                              name: _user!.name,
                              photoUrl: _user!.photoUrl,
                              followers: _user!.followers,
                              followings: _user!.followings,
                              blockUsers: _user!.blockUsers,
                              profile: value,
                              token: _user!.token);
                        });
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class PhotoUploader extends StatelessWidget {
  final String? photoUrl;
  final void Function(String) setPhoto;
  const PhotoUploader({
    super.key,
    required this.photoUrl,
    required this.setPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;
        setPhoto(image.path);
      },
      child: Stack(
        children: [
          Center(
            child: ProfilePhoto(
              photoUrl: photoUrl,
              opacity: 0.7,
            ),
          ),
          const Center(
            child: SizedBox.square(
                dimension: 100,
                child: Icon(Icons.add_a_photo, size: 50, color: Colors.white)),
          )
        ],
      ),
    );
  }
}
