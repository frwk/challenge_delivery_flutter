import 'package:challenge_delivery_flutter/models/courier.dart';

class Delivery {
  final int id;
  final String createdAt;
  final Courier courier;

  const Delivery({
    required this.id,
    required this.createdAt,
    required this.courier,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      createdAt: json['createdAt'] as String,
      courier: Courier.fromJson(json['courier'] as Map<String, dynamic>),
    );
  }
}
