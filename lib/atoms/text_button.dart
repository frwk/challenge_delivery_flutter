import 'package:flutter/material.dart';

class TextButtonAtom extends StatefulWidget {
  String label;
  Color labelColor;
  String? redirectTo;

  TextButtonAtom({super.key, required this.label, required this.labelColor, this.redirectTo});

  @override
  State<TextButtonAtom> createState() => _TextButtonAtomState();
}

class _TextButtonAtomState extends State<TextButtonAtom> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, widget.redirectTo!);
      },
      child: Text(
        widget.label,
        style:TextStyle(
          color: widget.labelColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
