import 'package:challenge_delivery_flutter/models/user.dart';

class Courier {
  final int id;
  final String status;
  final double? latitude;
  final double? longitude;
  final User? user;
  final String? vehicle;

  Courier({
    required this.id,
    required this.status,
    this.latitude,
    this.longitude,
    this.user,
    this.vehicle,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["id"] ?? 0,
        status: json["status"] ?? '',
        latitude: double.tryParse(json["latitude"] ?? ''),
        longitude: double.tryParse(json["longitude"] ?? ''),
        vehicle: json["vehicle"] ?? '',
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "latitude": latitude,
        "longitude": longitude,
        "vehicle": vehicle,
        "user": user?.toJson(),
      };

  Courier copyWith({int? id, String? status, double? latitude, double? longitude, String? vehicle, Function? user}) {
    return Courier(
      id: id ?? this.id,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      vehicle: vehicle ?? this.vehicle,
      user: user != null ? user() : this.user,
    );
  }
}
