import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextFieldAtom extends StatelessWidget {
  final String name;
  final String placeholder;
  final Color? placeholderColor;
  final bool? displayPlaceholder;
  final bool isPassword;
  final void Function(String?)? onChanged;
  final TextEditingController? controller;
  final List<FormFieldValidator<String>>? validators;
  final bool? isEnabled;
  final InputDecoration? decoration;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;

  const TextFieldAtom({
    super.key,
    required this.name,
    required this.placeholder,
    this.displayPlaceholder = false,
    this.isPassword = false,
    this.placeholderColor,
    this.onChanged,
    required this.controller,
    this.validators,
    this.isEnabled = true,
    this.decoration,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.01),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: FormBuilderTextField(
        initialValue: initialValue,
        readOnly: isEnabled != null ? !isEnabled! : false,
        controller: controller,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: isPassword,
        name: name,
        validator: FormBuilderValidators.compose(validators ?? []),
        style: isEnabled! ? null : const TextStyle(color: Colors.grey, fontSize: 12),
        decoration: decoration ??
            InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              labelText: true == displayPlaceholder ? placeholder : null,
              labelStyle: TextStyle(
                color: placeholderColor,
                fontSize: 12,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
      ),
    );
  }
}
