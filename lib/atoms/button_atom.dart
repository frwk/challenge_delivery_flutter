import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:flutter/material.dart';

class ButtonAtom extends StatelessWidget {
  final String data;
  final String? redirectTo;
  final void Function()? onTap;

  const ButtonAtom({super.key, required this.data, this.redirectTo, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:18.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            fixedSize: const Size(400, 50),
          ),
          child: Text(
              data,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )
          ),
        ),
      ),
    );
  }
}
