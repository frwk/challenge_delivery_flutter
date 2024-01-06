import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/user.dart';

class Delivery {
  final int? id;
  final String? status;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String? pickupAddress;
  final String? dropoffAddress;
  final DateTime? pickupDate;
  final DateTime? dropoffDate;
  final String? confirmationCode;
  final int? notation;
  final User? client;
  final Courier? courier;
  final int? courierId;
  final int? distance;
  final int? distanceToPickup;
  final DateTime? createdAt;

  Delivery({
    this.id,
    this.status,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupDate,
    this.dropoffDate,
    this.confirmationCode,
    this.notation,
    this.client,
    this.courier,
    this.courierId,
    this.distance,
    this.distanceToPickup,
    this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
      id: json["id"] ?? 0,
      status: json["status"] ?? '',
      pickupLatitude: json["pickupLatitude"] is String ? double.tryParse(json["pickupLatitude"]) : json["pickupLatitude"],
      pickupLongitude: json["pickupLongitude"] is String ? double.tryParse(json["pickupLongitude"]) : json["pickupLongitude"],
      dropoffLatitude: json["dropoffLatitude"] is String ? double.tryParse(json["dropoffLatitude"]) : json["dropoffLatitude"],
      dropoffLongitude: json["dropoffLongitude"] is String ? double.tryParse(json["dropoffLongitude"]) : json["dropoffLongitude"],
      pickupAddress: json["pickupAddress"] ?? '',
      dropoffAddress: json["dropoffAddress"] ?? '',
      pickupDate: DateTime.tryParse(json["pickupDate"] ?? ''),
      dropoffDate: DateTime.tryParse(json["dropoffDate"] ?? ''),
      confirmationCode: json["confirmationCode"],
      notation: json["notation"],
      client: json["client"] != null ? User.fromJson(json["client"]) : null,
      courier: json["courier"] != null ? Courier.fromJson(json["courier"]) : null,
      courierId: json["courierId"],
      distance: json["distance"],
      distanceToPickup: json["distanceToPickup"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ''));

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "pickupLatitude": pickupLatitude,
        "pickupLongitude": pickupLongitude,
        "dropoffLatitude": dropoffLatitude,
        "dropoffLongitude": dropoffLongitude,
        "pickupAddress": pickupAddress,
        "dropoffAddress": dropoffAddress,
        "pickupDate": pickupDate?.toIso8601String(),
        "dropoffDate": dropoffDate?.toIso8601String(),
        "confirmationCode": confirmationCode,
        "notation": notation,
        "courierId": courierId,
        "client": client?.toJson(),
        "courier": courier?.toJson(),
        "distance": distance,
      };

  Delivery copyWith(
      {int? id,
      String? status,
      double? pickupLatitude,
      double? pickupLongitude,
      double? dropoffLatitude,
      double? dropoffLongitude,
      DateTime? pickupDate,
      DateTime? dropoffDate,
      String? pickupAddress,
      String? dropoffAddress,
      String? confirmationCode,
      int? notation,
      User? client,
      Courier? courier,
      int? Function()? courierId,
      int? distance,
      int? distanceToPickup,
      DateTime? createdAt}) {
    return Delivery(
      id: id ?? this.id,
      status: status ?? this.status,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupDate: pickupDate ?? this.pickupDate,
      dropoffDate: dropoffDate ?? this.dropoffDate,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      notation: notation ?? this.notation,
      client: client ?? this.client,
      courier: courier ?? this.courier,
      courierId: courierId != null ? courierId() : this.courierId,
      distance: distance ?? this.distance,
      distanceToPickup: distanceToPickup ?? this.distanceToPickup,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
