import 'package:flutter/material.dart';

void modalLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Theme.of(context).primaryColor.withOpacity(0.5),
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: const SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Connexion en cours...'),
          ],
        ),
      ),
    ),
  );
}
