import 'dart:convert';

import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/themes/maps_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as developer;

class DeliveryTrackingBloc extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  late GoogleMapController _mapController;
  late StreamSubscription<Position> _positionSubscription;
  late IO.Socket _socket;
  late String pickupAddress;
  late String dropoffAddress;
  late User client;

  DeliveryTrackingBloc() : super(DeliveryTrackingState()) {
    on<StartDeliveryTracking>(_onStartDeliveryTracking);
    on<StopDeliveryTracking>(_onStopDeliveryTracking);
    on<ChangeLocationEvent>(_onChangeLocation);
    on<UpdateDeliveryStatusEvent>(_onUpdateDeliveryStatus);
  }

  Future<void> _onStartDeliveryTracking(StartDeliveryTracking event, Emitter<DeliveryTrackingState> emit) async {
    emit(state.copyWith(status: DeliveryTrackingStatus.loading));
    try {
      Position currentPosition = await Geolocator.getCurrentPosition();
      Delivery delivery = await orderService.getCurrentCourierDelivery(event.courier);

      pickupAddress = await locationService.getAddress(delivery.pickupLatitude!, delivery.pickupLongitude!);
      dropoffAddress = await locationService.getAddress(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
      client = delivery.client!;

      initialLocation();
      initSocketDelivery();

      emit(state.copyWith(
        delivery: delivery,
        status: DeliveryTrackingStatus.started,
        markers: await _getMarkersForDelivery(delivery),
        polyline: await _getPolylineForDelivery(delivery, LatLng(currentPosition.latitude, currentPosition.longitude)),
        location: LatLng(event.courier.latitude!, event.courier.longitude!),
      ));
    } catch (e) {
      if (e is NotFoundException) {
        emit(state.copyWith(status: DeliveryTrackingStatus.error, errorType: DeliveryTrackingErrorType.notFound));
      } else {
        emit(state.copyWith(status: DeliveryTrackingStatus.error));
      }
      return;
    }
  }

  void moveCamareLocation(LatLng location) {
    final cameraUpdate = CameraUpdate.newLatLng(location);
    _mapController.animateCamera(cameraUpdate);
  }

  Future<void> _onStopDeliveryTracking(DeliveryTrackingEvent event, Emitter<DeliveryTrackingState> emit) async {
    _positionSubscription.cancel();
    _mapController.dispose();
    _socket.disconnect();
  }

  @override
  Future<void> close() {
    _positionSubscription.cancel();
    _mapController.dispose();
    _socket.disconnect();
    return super.close();
  }

  Future<void> initMap(GoogleMapController controller) async {
    _mapController = controller;
    _mapController.setMapStyle(jsonEncode(mapsTheme));
  }

  Future<void> _onChangeLocation(ChangeLocationEvent event, Emitter<DeliveryTrackingState> emit) async {
    emit(state.copyWith(location: event.location));
  }

  Future<void> _onUpdateDeliveryStatus(UpdateDeliveryStatusEvent event, Emitter<DeliveryTrackingState> emit) async {
    emit(state.copyWith(status: DeliveryTrackingStatus.loading));
    try {
      final updatedDelivery = await orderService.updateDelivery(state.delivery!.copyWith(
        status: event.status.name,
        pickupDate: DateTime.now(),
        courierId: () => event.status.name == DeliveryStatusEnum.pending.name ? null : state.delivery!.courierId,
      ));
      if (updatedDelivery.status == DeliveryStatusEnum.delivered.name) {
        emit(state.copyWith(delivery: updatedDelivery, status: DeliveryTrackingStatus.success));
      } else if (updatedDelivery.status == DeliveryStatusEnum.pending.name) {
        emit(state.copyWith(delivery: updatedDelivery, status: DeliveryTrackingStatus.success));
      } else {
        emit(state.copyWith(
          delivery: updatedDelivery,
          status: DeliveryTrackingStatus.started,
          markers: await _getMarkersForDelivery(updatedDelivery),
          polyline: await _getPolylineForDelivery(updatedDelivery, state.location!),
        ));
      }
    } catch (e) {
      developer.log(e.toString(), name: 'UpdateDeliveryStatusEventError');
      emit(state.copyWith(status: DeliveryTrackingStatus.error));
      return;
    }
  }

  void initialLocation() {
    _positionSubscription = Geolocator.getPositionStream().listen((Position position) {
      add(ChangeLocationEvent(LatLng(position.latitude, position.longitude)));
    });
  }

  void initSocketDelivery() {
    _socket = IO.io("${dotenv.env['API_URL']}/deliveries/tracking", {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.connect();
  }

  Future<Map<String, Marker>> _getMarkersForDelivery(Delivery delivery) async {
    LatLng position;
    if (delivery.status == DeliveryStatusEnum.accepted.name) {
      position = LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!);
    } else if (delivery.status == DeliveryStatusEnum.picked_up.name) {
      position = LatLng(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
    } else {
      return {};
    }
    return {
      'markerDestination': Marker(
        markerId: const MarkerId('markerDestination'),
        position: position,
      )
    };
  }

  Future<Polyline> _getPolylineForDelivery(Delivery delivery, LatLng currentLocation) async {
    final polylinePoints = PolylinePoints();
    PointLatLng startPoint;
    PointLatLng endPoint;
    startPoint = PointLatLng(currentLocation.latitude, currentLocation.longitude);
    if (delivery.status == DeliveryStatusEnum.accepted.name) {
      endPoint = PointLatLng(delivery.pickupLatitude!, delivery.pickupLongitude!);
    } else if (delivery.status == DeliveryStatusEnum.picked_up.name) {
      endPoint = PointLatLng(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
    } else {
      return const Polyline(
        polylineId: PolylineId('deliveryRoute'),
        color: Colors.blue,
        points: [],
        width: 5,
      );
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['MAPS_ACCESS_TOKEN']!,
      startPoint,
      endPoint,
    );
    if (result.status == 'OK' && result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      return Polyline(
        polylineId: const PolylineId('deliveryRoute'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      );
    } else {
      return const Polyline(
        polylineId: PolylineId('deliveryRoute'),
        color: Colors.blue,
        points: [],
        width: 5,
      );
    }
  }
}
