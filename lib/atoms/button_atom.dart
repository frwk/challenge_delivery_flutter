import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class ButtonAtom extends StatelessWidget {
  final String data;
  final String? redirectTo;
  final Color? color;
  final void Function()? onTap;
  final ButtonSize? buttonSize;
  final IconData? icon;

  const ButtonAtom({
    super.key,
    required this.data,
    this.redirectTo,
    this.onTap,
    this.color,
    this.buttonSize,
    this.icon,
  });

  Map<String, dynamic> _getButtonProperties() {
    switch (buttonSize) {
      case ButtonSize.small:
        return {'padding': const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 'fontSize': 14.0};
      case ButtonSize.medium:
        return {'padding': const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 'fontSize': 16.0};
      case ButtonSize.large:
        return {'padding': const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 'fontSize': 18.0};
      default:
        return {'padding': const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 'fontSize': 16.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    var properties = _getButtonProperties();

    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Center(
        child: icon != null
            ? ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, color: Colors.white),
                label: Text(
                  data,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: properties['fontSize'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color ?? Colors.orangeAccent.shade200,
                  padding: properties['padding'],
                ),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color ?? Colors.orangeAccent.shade200,
                  padding: properties['padding'],
                ),
                child: Text(
                  data,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: properties['fontSize'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
