import 'package:flutter/material.dart';

import '../atoms/label_atom.dart';
import '../atoms/textfield_atom.dart';

class InputComponent extends StatelessWidget {
  final String? label;
  final String name;
  final Color? labelColor;
  final double? labelSize;
  final String placeholder;
  final bool? displayPlaceholder;
  final bool obscureText;
  final void Function(String?)? onChanged;
  final TextEditingController? controller;
  final List<FormFieldValidator<String>>? validators;
  final bool isEnabled;
  final InputDecoration? decoration;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;
  final String? errorText;

  const InputComponent({
    super.key,
    this.label,
    required this.name,
    required this.placeholder,
    this.displayPlaceholder = false,
    this.obscureText = false,
    this.labelColor = Colors.black,
    this.labelSize,
    this.onChanged,
    this.controller,
    this.validators,
    this.isEnabled = true,
    this.decoration,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) LabelAtom(label: label!, labelColor: labelColor, labelSize: labelSize),
            TextFieldAtom(
                name: name,
                placeholder: placeholder,
                displayPlaceholder: displayPlaceholder,
                obscureText: obscureText,
                onChanged: onChanged,
                controller: controller,
                validators: validators,
                isEnabled: isEnabled,
                decoration: decoration,
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                initialValue: initialValue,
                errorText: errorText)
          ],
        ),
      ),
    );
  }
}
