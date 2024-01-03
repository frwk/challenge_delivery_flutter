import 'package:challenge_delivery_flutter/models/delivery.dart';

class Complaint {
  final int? id;
  final int? userId;
  final int? deliveryId;
  final String? createdAt;
  final String? status;
  final Delivery? delivery;

  const Complaint({
    this.id,
    this.userId,
    this.deliveryId,
    this.createdAt,
    this.status,
    this.delivery,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      userId: json['userId'],
      deliveryId: json['deliveryId'],
      createdAt: json['createdAt'],
      status: json['status'],
      delivery: json["delivery"] != null ? Delivery.fromJson(json["delivery"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deliveryId': deliveryId,
      'createdAt': createdAt,
      'status': status,
      'delivery': delivery?.toJson(),
    };
  }
}
