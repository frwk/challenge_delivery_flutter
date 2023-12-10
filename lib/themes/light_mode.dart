import 'package:flutter/material.dart';

ThemeData lightMode() {
  return ThemeData(
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
      headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
    ),
    colorScheme: ColorScheme.light(
      background: Colors.white,
      primary: Colors.white,
      secondary: Colors.grey.shade400,
      inversePrimary: Colors.grey.shade700,
    ),
  );
}