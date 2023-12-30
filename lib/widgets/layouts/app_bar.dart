import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function()? onBackArrowClicked;

  const MyAppBar({super.key, required this.title, this.onBackArrowClicked});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.black,
        onPressed: () => onBackArrowClicked != null ? onBackArrowClicked!() : Navigator.pop(context),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
      titleSpacing: 10,
      centerTitle: true,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
