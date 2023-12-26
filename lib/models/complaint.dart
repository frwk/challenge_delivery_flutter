import 'package:challenge_delivery_flutter/models/delivery.dart';

class Complaint {
  final int id;
  final String createdAt;
  final String status;
  final Delivery delivery;

  const Complaint({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.delivery,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as int,
      createdAt: json['createdAt'] as String,
      status: json['status'] as String,
      delivery: Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
    );
  }
}
