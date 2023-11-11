import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:flutter/material.dart';

void showSnackMessage(BuildContext context, String message, MessageTypeEnum type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: type == MessageTypeEnum.error ? Colors.red : Colors.green,
    ),
  );
}
