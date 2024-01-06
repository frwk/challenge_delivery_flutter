part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class OrderInitialEvent extends OrderEvent {
  final Order? order;
  OrderInitialEvent(this.order);
}

class OrderAddressEvent extends OrderEvent {
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicle;
  final String urgency;

  OrderAddressEvent(this.pickupAddress, this.dropoffAddress, this.vehicle, this.urgency);
}

class OrderConfirmedEvent extends OrderEvent {
  final Order order;
  final int clientId;

  OrderConfirmedEvent(this.order, this.clientId);
}

class OrderCanceledEvent extends OrderEvent {}

class OrderGetDeliveryTotal extends OrderEvent {}
