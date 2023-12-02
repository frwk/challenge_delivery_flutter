import 'package:flutter/material.dart';

class LabelAtom extends StatelessWidget {

  final String label;
  final Color? labelColor;
  final double? labelSize;

  const LabelAtom({
    super.key,
    required this.label,
    this.labelColor,
    this.labelSize = 14
  });

  @override
  Widget build(BuildContext context) {
    return Text(
     label,
      style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w500,
          fontSize: labelSize
      ),
    );
  }
}
