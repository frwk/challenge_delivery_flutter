import 'package:flutter/material.dart';

class LabelAtom extends StatelessWidget {

  final String label;
  const LabelAtom({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
     label,
      style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500
      ),
    );
  }
}
