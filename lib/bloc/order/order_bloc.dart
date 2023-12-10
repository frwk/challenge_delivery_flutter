import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
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
      final order = Order(
          departureAddress: event.departureAddress,
          arrivalAddress: event.arrivalAddress,
          packageType: event.packageType,
          packageWeight: event.packageWeight
      );
      print(order);

      // final data = await orderService.post(event.departureAddress, event.arrivalAddress, event.packageType, event.packageWeight);
      await Future.delayed(const Duration(milliseconds: 850));
      emit(OrderAddressSuccessState(order));
      print(state);
      // emit(state.copyWith(order: order));
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }
}
