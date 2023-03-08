import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final double opacity;
  const ProfilePhoto({
    super.key,
    required this.photoUrl,
    this.size = 100,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: photoUrl == null
          ? const CircleAvatar(child: Text("No Data"))
          : CircleAvatar(
              backgroundColor: Colors.black,
              child: ClipOval(
                child: Opacity(
                  opacity: opacity,
                  child: SizedBox.square(
                    dimension: size,
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
