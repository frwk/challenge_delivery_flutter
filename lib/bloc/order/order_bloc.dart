import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:flutter/material.dart';
part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<OrderInitialEvent>(_onOrderInitialEvent);
    on<OrderAddressEvent>(_onOrderAddressEvent);
    on<OrderConfirmedEvent>(_onOrderConfirmedEvent);
    on<OrderCanceledEvent>(_onOrderCanceledEvent);
    on<OrderGetDeliveryTotal>(_onOrderGetDeliveryTotal);
  }

  void _onOrderInitialEvent(OrderInitialEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderInitial());
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onOrderAddressEvent(OrderAddressEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());

      var orderWithTotal = await orderService.calculateDeliveryTotal(
          event.vehicle,
          event.urgency,
      );

      final order = Order(
        pickupAddress: event.pickupAddress,
        dropoffAddress: event.dropoffAddress,
        vehicle: event.vehicle,
        urgency: event.urgency,
        total: orderWithTotal.total,
      );

      print(order);

      await Future.delayed(const Duration(milliseconds: 850));
      emit(OrderAddressSuccessState(order));
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onOrderConfirmedEvent(OrderConfirmedEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      await orderService.post(event.order.pickupAddress, event.order.dropoffAddress, event.order.vehicle, event.order.urgency,  event.clientId);
      emit(OrderConfirmedState());
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onOrderCanceledEvent(OrderCanceledEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoadingState());
      await Future.delayed(const Duration(milliseconds: 850));
      emit(const OrderFailureState('Votre commande a été annulée'));
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }

  Future<void> _onOrderGetDeliveryTotal(OrderGetDeliveryTotal event, Emitter<OrderState> emit) async {
    try {
      print('Je suis dans order delivery total event');
      print(event);
      // emit(OrderLoadingState());
      await Future.delayed(const Duration(milliseconds: 850));
      // emit(OrderGetDeliveryTotalState());
    } catch (e) {
      emit(OrderFailureState(e.toString()));
    }
  }
}
