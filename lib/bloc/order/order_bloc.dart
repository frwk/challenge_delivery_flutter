import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:flutter/material.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<OrderAddressEvent>(_onOrderAddressEvent);
    on<OrderConfirmedEvent>(_onOrderConfirmedEvent);
  }

  Future<void> _onOrderAddressEvent(OrderAddressEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      final order = Order(
          pickupAddress: event.pickupAddress,
          dropoffAddress: event.dropoffAddress,
          packageType: event.packageType,
          packageWeight: event.packageWeight);

      await Future.delayed(const Duration(milliseconds: 850));
      emit(OrderAddressSuccessState(order));
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onOrderConfirmedEvent(OrderConfirmedEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      final order = await orderService.post(
          event.order.pickupAddress, event.order.dropoffAddress, event.order.packageType, event.order.packageWeight, event.clientId);
      print(order);
      emit(OrderConfirmedState());
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }
}
