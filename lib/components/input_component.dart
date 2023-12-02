
import 'package:flutter/material.dart';

import '../atoms/label_atom.dart';
import '../atoms/textfield_atom.dart';

class InputComponent extends StatelessWidget {

  final String label;
  final Color? labelColor;
  final double? labelSize;
  final String placeholder;
  final bool password;
  final String Function(String?)? validator;


  const InputComponent({
    super.key,
    required this.label,
    required this.placeholder,
    this.password = false,
    this.labelColor = Colors.black,
    this.labelSize,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:16.0),
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelAtom(label: label, labelColor: labelColor, labelSize: labelSize),
            TextFieldAtom(placeholder: placeholder, isPassword: password)
          ],
        ),
      ),
    );
  }
}
