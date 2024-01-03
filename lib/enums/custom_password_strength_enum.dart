import 'package:flutter/material.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

enum CustomPasswordStrength implements PasswordStrengthItem {
  alreadyExposed,
  weak,
  medium,
  strong,
  secure;

  @override
  Color get statusColor {
    switch (this) {
      case CustomPasswordStrength.alreadyExposed:
        return const Color.fromARGB(255, 158, 15, 5);
      case CustomPasswordStrength.weak:
        return Colors.red;
      case CustomPasswordStrength.medium:
        return Colors.orange;
      case CustomPasswordStrength.strong:
        return Colors.green;
      case CustomPasswordStrength.secure:
        return const Color(0xFF0B6C0E);
      default:
        return Colors.red;
    }
  }

  @override
  double get widthPerc {
    switch (this) {
      case CustomPasswordStrength.alreadyExposed:
        return 0.075;
      case CustomPasswordStrength.weak:
        return 0.15;
      case CustomPasswordStrength.medium:
        return 0.4;
      case CustomPasswordStrength.strong:
        return 0.75;
      case CustomPasswordStrength.secure:
        return 1.0;
    }
  }

  @override
  Widget? get statusWidget {
    switch (this) {
      case CustomPasswordStrength.alreadyExposed:
        return Row(
          children: [const Text('Trop commun'), const SizedBox(width: 5), Icon(Icons.error, color: statusColor)],
        );
      case CustomPasswordStrength.weak:
        return const Text('Faible');
      case CustomPasswordStrength.medium:
        return const Text('Moyen');
      case CustomPasswordStrength.strong:
        return const Text('Fort');
      case CustomPasswordStrength.secure:
        return Row(
          children: [const Text('Sécurisé'), const SizedBox(width: 5), Icon(Icons.check_circle, color: statusColor)],
        );
      default:
        return null;
    }
  }

  static CustomPasswordStrength? calculate({required String text}) {
    if (text.isEmpty) {
      return null;
    }

    if (commonDictionary[text] == true) {
      return CustomPasswordStrength.alreadyExposed;
    }

    if (text.length < 8) {
      return CustomPasswordStrength.weak;
    }

    var counter = 0;
    if (text.contains(RegExp(r'[a-z]'))) counter++;
    if (text.contains(RegExp(r'[A-Z]'))) counter++;
    if (text.contains(RegExp(r'[0-9]'))) counter++;
    if (text.contains(RegExp(r'[!@#\$%&*()?£\-_=]'))) counter++;

    switch (counter) {
      case 1:
        return CustomPasswordStrength.weak;
      case 2:
        return CustomPasswordStrength.medium;
      case 3:
        return CustomPasswordStrength.strong;
      case 4:
        return CustomPasswordStrength.secure;
      default:
        return CustomPasswordStrength.weak;
    }
  }

  static String get instructions {
    return 'Entrez un mot de passe qui contient:\n\n'
        '• Au moins 8 caractères\n'
        '• Au moins 1 lettre minuscule\n'
        '• Au moins 1 lettre majuscule\n'
        '• Au moins 1 chiffre\n'
        '• Au moins 1 caractère spécial';
  }
}
