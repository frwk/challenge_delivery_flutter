
import 'package:flutter/material.dart';

import '../atoms/label_atom.dart';
import '../atoms/textfield_atom.dart';

class InputComponent extends StatelessWidget {

  final String label;
  final String name;
  final Color? labelColor;
  final double? labelSize;
  final String placeholder;
  final bool? displayPlaceholder;
  final bool password;
  final void Function(String?)? onChanged;
  final TextEditingController? controller;
  final List<FormFieldValidator<String>>? validators;


  const InputComponent({
    super.key,
    required this.label,
    required this.name,
    required this.placeholder,
    this.displayPlaceholder = false,
    this.password = false,
    this.labelColor = Colors.black,
    this.labelSize,
    this.onChanged,
    this.controller,
    this.validators,
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
            TextFieldAtom(name: name, placeholder: placeholder, displayPlaceholder: displayPlaceholder ,isPassword: password, onChanged: onChanged, controller:  controller, validators: validators)
          ],
        ),
      ),
    );
  }
}
