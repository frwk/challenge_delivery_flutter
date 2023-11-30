import 'package:flutter/material.dart';

class LandingTitleAtom extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;

  const LandingTitleAtom({
    super.key,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: TextStyle(
                color: titleColor,
                fontSize: 28,
                fontWeight: FontWeight.bold
            )),
        Text(
            subtitle,
            style: TextStyle(
                color: subtitleColor,
                fontSize: 28,
                fontWeight: FontWeight.bold
            )),
      ],
    );
  }
}
