import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:flutter/material.dart';


part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<OrderAddressEvent>(_onOrderAddressEvent);
  }

  Future<void> _onOrderAddressEvent(OrderAddressEvent event, Emitter<OrderState> emit) async {
    try {

      emit(OrderLoadingState());
      print(event);
      
      final data = await orderService.post(event.departureAddress, event.arrivalAddress, event.packageType, event.packageWeight);
      await Future.delayed(const Duration(milliseconds: 850));
      // emit(OrderSuccessState());
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }
}
