part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class OrderAddressEvent extends OrderEvent {
  final String pickupAddress;
  final String dropoffAddress;

  OrderAddressEvent(this.pickupAddress, this.dropoffAddress);
}

class OrderConfirmedEvent extends OrderEvent {
  final Order order;
  final int clientId;

  OrderConfirmedEvent(this.order, this.clientId);
}

class OrderCanceledEvent extends OrderEvent {}