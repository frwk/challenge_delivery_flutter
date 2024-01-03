import 'package:challenge_delivery_flutter/models/user.dart';

class Courier {
  final int id;
  final String status;
  final double? latitude;
  final double? longitude;
  final User? user;

  Courier({
    required this.id,
    required this.status,
    this.latitude,
    this.longitude,
    this.user,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["id"] ?? 0,
        status: json["status"] ?? '',
        latitude: double.tryParse(json["latitude"] ?? ''),
        longitude: double.tryParse(json["longitude"] ?? ''),
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "latitude": latitude,
        "longitude": longitude,
        "user": user?.toJson(),
      };

  Courier copyWith({int? id, String? status, double? latitude, double? longitude, Function? user}) {
    return Courier(
      id: id ?? this.id,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      user: user != null ? user() : this.user,
    );
  }
}
