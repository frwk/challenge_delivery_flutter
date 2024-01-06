import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/services/payment/stripe_payment_service.dart';
import 'package:meta/meta.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitialState()) {
    on<PaymentIntentEvent>(_onPaymentIntentEvent);
  }

  Future<void> _onPaymentIntentEvent(PaymentIntentEvent event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoadingState());
      await paymentService.stripeMakePayment(event.amount, event.currency);
      // var amount = paymentService.calculateAmount(event.amount);
      // print('l20');
      // print(amount);
      // await paymentService.createPaymentIntent(amount, "EUR");
    } catch (e) {
      emit(PaymentFailureState(e.toString()));
    }
  }
}
