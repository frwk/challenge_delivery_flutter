import 'package:flutter/material.dart';

enum ErrorMessageTypeEnum {
  generic,
  noResult,
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final ErrorMessageTypeEnum? type;

  ErrorMessage({required this.message, this.type = ErrorMessageTypeEnum.generic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'Oups! Une erreur est survenue.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
