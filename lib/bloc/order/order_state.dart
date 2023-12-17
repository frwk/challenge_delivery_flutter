part of 'order_bloc.dart';

@immutable
class OrderState {
  final Order? order;

  const OrderState({this.order});

  OrderState copyWith({Order? order}) => OrderState(order: order ?? this.order);
}

class OrderInitial extends OrderState {}
class OrderLoadingState extends OrderState {}
class OrderSuccessState extends OrderState {}
class OrderAddressSuccessState extends OrderState {
const OrderAddressSuccessState(Order? order) : super(order: order);
}
class OrderConfirmedState extends OrderState {}
class OrderFailureState extends OrderState {
  final error;
  const OrderFailureState(this.error);
}
