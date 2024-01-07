import 'package:flutter/material.dart';

ThemeData lightMode() {
  const colorSchemePrimary = Color.fromRGBO(255, 171, 64, 1);
  const colorSchemeSecondary = Color.fromRGBO(113, 155, 193, 1);
  Color colorSchemeInversePrimary = Colors.grey.shade700;

  return ThemeData(
    fontFamily: 'Poppins',
    listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: colorSchemeInversePrimary),
    ),
    textTheme: const TextTheme(
      titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400),
      bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600),
    ),
    colorScheme: ColorScheme.light(
      background: Colors.grey.shade100,
      primary: colorSchemePrimary,
      secondary: colorSchemeSecondary,
      inversePrimary: colorSchemeInversePrimary,
    ),
  );
}
