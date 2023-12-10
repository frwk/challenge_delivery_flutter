part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class OrderAddressEvent extends OrderEvent {
  final String departureAddress;
  final String arrivalAddress;
  final String packageType;
  final String packageWeight;

  OrderAddressEvent(
      this.departureAddress,
      this.arrivalAddress,
      this.packageType,
      this.packageWeight
      );
}