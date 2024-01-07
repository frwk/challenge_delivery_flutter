import 'package:challenge_delivery_flutter/models/courier.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? notificationToken;
  final Courier? courier;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.role,
      required this.notificationToken,
      this.courier});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"] ?? 0,
      firstName: json["firstName"] ?? '',
      lastName: json["lastName"] ?? '',
      email: json["email"] ?? '',
      role: json["role"] ?? '',
      notificationToken: json["notificationToken"],
      courier: json['courier'] != null ? Courier.fromJson(json['courier']) : null);

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "role": role,
        "notificationToken": notificationToken,
        "courier": courier?.toJson(),
      };

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? notificationToken,
    Function? courier,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      notificationToken: notificationToken ?? this.notificationToken,
      courier: courier != null ? courier() : this.courier,
    );
  }
}
