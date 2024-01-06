part of 'payment_bloc.dart';

@immutable
class PaymentState {}

class PaymentInitialState extends PaymentState {}
class PaymentLoadingState extends PaymentState {}
class PaymentSuccessState extends PaymentState {}
class PaymentFailureState extends PaymentState {
  final error;
  PaymentFailureState(this.error);
}
