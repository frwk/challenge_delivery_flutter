import 'package:flutter/material.dart';

class LandingTitleAtom extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Color? subtitleColor;

  const LandingTitleAtom({
    super.key,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: titleColor ?? Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
        subtitle != null && subtitle!.isNotEmpty
            ? Text(subtitle!, style: TextStyle(color: subtitleColor ?? Colors.black, fontSize: 28, fontWeight: FontWeight.bold))
            : const SizedBox.shrink(),
      ],
    );
  }
}
