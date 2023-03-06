import 'package:flutter/material.dart';

class TransparentAppBar extends StatelessWidget with PreferredSizeWidget {
  final AppBar appBar;
  final Widget? title;
  const TransparentAppBar({super.key, required this.appBar, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: title,
    );
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
