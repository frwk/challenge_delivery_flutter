import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextFieldAtom extends StatelessWidget {
  final String placeholder;
  final Color? placeholderColor;
  final bool isPassword;

  const TextFieldAtom({
    super.key,
    required this.placeholder,
    this.isPassword = false,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: FormBuilderTextField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: isPassword,
        name: placeholder,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          labelText: placeholder,
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
