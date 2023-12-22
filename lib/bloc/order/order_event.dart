part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class OrderAddressEvent extends OrderEvent {
  final String pickupAddress;
  final String dropoffAddress;
  final String packageType;
  final String packageWeight;

  OrderAddressEvent(this.pickupAddress, this.dropoffAddress, this.packageType, this.packageWeight);
}

class OrderConfirmedEvent extends OrderEvent {
  final Order order;
  final int clientId;

  OrderConfirmedEvent(this.order, this.clientId);
}
