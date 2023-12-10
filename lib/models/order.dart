import 'package:challenge_delivery_flutter/models/address.dart';
import 'package:challenge_delivery_flutter/models/user.dart';

class Order {
  final int id;
  // final String reference;
  // final String status;
  final Address departureAddress;
  final Address arrivalAddress;
  final String packageType;
  final String packageWeight;
  // final User client;
  // final User deliveryMan;
  // final String date;
  // final String total;

  const Order({
    required this.id,
    // required this.reference,
    // required this.status,
    // required this.date,
    // required this.total,
    required this.departureAddress,
    required this.arrivalAddress,
    required this.packageType,
    required this.packageWeight,
    // required this.client,
    // required this.deliveryMan,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      id: json["id"] ?? 0,
      departureAddress: json["departureAddress"] ?? '',
      arrivalAddress: json["arrivalAddress"] ?? '',
      packageType: json["packageType"] ?? '',
      packageWeight: json["packageWeight"] ?? '');
}