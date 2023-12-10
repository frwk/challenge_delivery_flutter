part of 'order_bloc.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState {}
class OrderLoadingState extends OrderState {}
class OrderSuccessState extends OrderState {}
class OrderFailureState extends OrderState {
  final error;
  OrderFailureState(this.error);
}
