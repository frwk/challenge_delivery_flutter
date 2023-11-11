import 'package:challenge_delivery_flutter/models/user.dart';

class Courier {
  final int id;
  final String status;
  final User user;

  Courier({
    required this.id,
    required this.status,
    required this.user,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["id"] ?? 0,
        status: json["status"] ?? '',
        user: User.fromJson(json["user"]),
      );
}
