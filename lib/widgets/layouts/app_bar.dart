import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function()? onBackArrowClicked;
  final bool hasBackArrow;
  final List<Widget>? actions;

  const MyAppBar({super.key, required this.title, this.onBackArrowClicked, this.hasBackArrow = true, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 2,
      leading: hasBackArrow
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => onBackArrowClicked != null ? onBackArrowClicked!() : Navigator.pop(context),
            )
          : null,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
      titleSpacing: 10,
      centerTitle: true,
      automaticallyImplyLeading: hasBackArrow,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
