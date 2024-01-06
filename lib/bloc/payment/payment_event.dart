part of 'payment_bloc.dart';

@immutable
abstract class PaymentEvent {}

class PaymentInitial extends PaymentEvent {}
class PaymentIntentEvent extends PaymentEvent {
  final int amount;
  final String currency;

  PaymentIntentEvent(this.amount, this.currency);
}