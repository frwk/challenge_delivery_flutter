import 'dart:convert';

import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/helpers/markers.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/init_socket.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/delivery_tracking.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
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
import 'package:web_socket_channel/web_socket_channel.dart';

class DeliveryTrackingBloc extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  late GoogleMapController _mapController;
  late StreamSubscription<Position> _positionSubscription;
  late User client;
  late User authUser;
  late WebSocketChannel _channel;
  late StreamController<String> _streamController;
  late BitmapDescriptor customCourierIcon;
  late BitmapDescriptor customDestinationIcon;
  late BitmapDescriptor customStartIcon;

  DeliveryTrackingBloc() : super(DeliveryTrackingState()) {
    on<StartDeliveryTracking>(_onStartDeliveryTracking);
    on<StopDeliveryTracking>(_onStopDeliveryTracking);
    on<ChangeLocationEvent>(_onChangeLocation);
    on<UpdateDeliveryStatusEvent>(_onUpdateDeliveryStatus);
    on<MessageReceivedEvent>(_onMessageReceived);
  }

  Future<void> _onStartDeliveryTracking(StartDeliveryTracking event, Emitter<DeliveryTrackingState> emit) async {
    emit(state.copyWith(status: DeliveryTrackingStatus.loading));
    try {
      authUser = event.user;
      customCourierIcon = await getMarkerIcon(MarkerType.courier);
      customDestinationIcon = await getMarkerIcon(MarkerType.destination);
      customStartIcon = await getMarkerIcon(MarkerType.start);
      if (authUser.role == RoleEnum.client.name) {
        if (event.delivery == null) {
          throw NotFoundException('Delivery not found');
        }
        initSocketDelivery(event.delivery!);
        emit(state.copyWith(
          delivery: event.delivery!,
          status: DeliveryTrackingStatus.started,
          markers: await _getMarkersForDelivery(event.delivery!),
          polyline: await _getPolylineForDelivery(
              event.delivery!,
              event.delivery!.courier == null
                  ? LatLng(event.delivery!.pickupLatitude!, event.delivery!.pickupLongitude!)
                  : LatLng(event.delivery!.courier!.latitude!, event.delivery!.courier!.longitude!)),
        ));
      } else {
        Delivery delivery = await orderService.getCurrentCourierDelivery(event.user.courier!);
        Position currentPosition = await Geolocator.getCurrentPosition();
        client = delivery.client!;

        initSocketDelivery(delivery);
        initialLocation();

        emit(state.copyWith(
          delivery: delivery,
          status: DeliveryTrackingStatus.started,
          markers: await _getMarkersForDelivery(delivery),
          polyline: await _getPolylineForDelivery(delivery, LatLng(currentPosition.latitude, currentPosition.longitude)),
          location: LatLng(currentPosition!.latitude!, currentPosition!.longitude!),
        ));
      }
    } catch (e) {
      developer.log(e.toString(), name: 'StartDeliveryTrackingError');
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

  Future<void> _onStopDeliveryTracking(StopDeliveryTracking event, Emitter<DeliveryTrackingState> emit) async {
    if (authUser.role == RoleEnum.courier.name) _positionSubscription.cancel();
    _mapController.dispose();
    _channel.sink.close();
  }

  @override
  Future<void> close() {
    if (authUser.role == RoleEnum.courier.name) _positionSubscription.cancel();
    _mapController.dispose();
    _channel.sink.close();
    return super.close();
  }

  Future<void> initMap(GoogleMapController controller) async {
    _mapController = controller;
    // _mapController.setMapStyle(jsonEncode(themeMaps));
  }

  Future<void> _onChangeLocation(ChangeLocationEvent event, Emitter<DeliveryTrackingState> emit) async {
    try {
      _channel.sink
          .add(jsonEncode(DeliveryTrackingSendMessage(type: 'location', courierId: authUser.courier!.id, coordinates: event.location.toJson())));
      if (authUser.role == RoleEnum.courier.name) {
        emit(state.copyWith(
          location: event.location,
          polyline: await _getPolylineForDelivery(state.delivery!, event.location),
        ));
      }
    } catch (e) {
      developer.log(e.toString(), name: 'ChangeLocationEventError');
      return;
    }
  }

  Future<void> _onUpdateDeliveryStatus(UpdateDeliveryStatusEvent event, Emitter<DeliveryTrackingState> emit) async {
    emit(state.copyWith(status: DeliveryTrackingStatus.loading));
    try {
      Delivery newDelivery = state.delivery!.copyWith(
        status: event.status.name,
        courierId: () => event.status.name == DeliveryStatusEnum.pending.name ? null : state.delivery!.courierId,
      );
      if (event.status == DeliveryStatusEnum.picked_up) {
        newDelivery = newDelivery.copyWith(pickupDate: DateTime.now());
      } else if (event.status == DeliveryStatusEnum.delivered) {
        newDelivery = newDelivery.copyWith(dropoffDate: DateTime.now());
      }
      final updatedDelivery = await orderService.updateDelivery(newDelivery);
      if ([DeliveryStatusEnum.delivered.name, DeliveryStatusEnum.pending.name, DeliveryStatusEnum.cancelled.name].contains(updatedDelivery.status)) {
        emit(state.copyWith(delivery: updatedDelivery, status: DeliveryTrackingStatus.success));
      } else {
        LatLng currentPosition;
        if (authUser.role == RoleEnum.courier.name) {
          var getPosition = await Geolocator.getCurrentPosition();
          currentPosition = LatLng(getPosition!.latitude!, getPosition!.longitude!);
        } else {
          currentPosition = LatLng(state.delivery!.courier!.latitude!, state.delivery!.courier!.longitude!);
        }
        emit(state.copyWith(
          delivery: updatedDelivery,
          status: DeliveryTrackingStatus.started,
          markers: await _getMarkersForDelivery(updatedDelivery),
          polyline: await _getPolylineForDelivery(updatedDelivery, currentPosition),
        ));
      }
    } catch (e) {
      developer.log(e.toString(), name: 'UpdateDeliveryStatusEventError');
      emit(state.copyWith(status: DeliveryTrackingStatus.error));
      return;
    }
  }

  void initialLocation() {
    const LocationSettings locationSettings = LocationSettings(
      distanceFilter: 50,
    );
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      add(ChangeLocationEvent(LatLng(position.latitude, position.longitude)));
    });
  }

  void initSocketDelivery(Delivery delivery) async {
    final cookie = await secureStorage.readCookie();
    final token = cookie.toString().split(';')[0].split('=')[1];
    developer.log('${dotenv.env['API_URL']!.replaceAll('http', 'ws')}/delivery-tracking/${delivery.id}?token=$token', name: 'token');
    _channel = WebSocketChannel.connect(
      Uri.parse(
        '${dotenv.env['API_URL']!.replaceAll('http', 'ws')}/ws/delivery-tracking/${delivery.id}?token=$token',
      ),
    );
    _streamController = StreamController<String>.broadcast();
    _channel.stream.listen(
      (data) {
        _streamController.add(data);
        final response = DeliveryTrackingReceivedMessage.fromJson(jsonDecode(data));
        add(MessageReceivedEvent(response));
      },
      onDone: () {
        _streamController.close();
      },
      onError: (error) {
        _streamController.addError(error);
      },
    );
    await _channel.ready;
  }

  Future<void> _onMessageReceived(MessageReceivedEvent event, Emitter<DeliveryTrackingState> emit) async {
    try {
      if (event.message.type == 'deliveryUpdate') {
        Delivery delivery = Delivery.fromJson(event.message.data);
        developer.log(jsonEncode(delivery), name: 'DeliveryTrackingBlocDelivery');

        if ([DeliveryStatusEnum.delivered.name, DeliveryStatusEnum.pending.name, DeliveryStatusEnum.cancelled.name].contains(delivery.status)) {
          emit(state.copyWith(delivery: delivery, status: DeliveryTrackingStatus.success));
        } else {
          emit(state.copyWith(
            delivery: delivery,
            status: DeliveryTrackingStatus.started,
            markers: await _getMarkersForDelivery(delivery),
            polyline: await _getPolylineForDelivery(delivery, LatLng(delivery.courier!.latitude!, delivery.courier!.longitude!)),
          ));
        }
      } else if (event.message.type == 'location') {
        DeliveryTrackingReceivedData locationMessage = DeliveryTrackingReceivedData.fromJson(event.message.data);
        Delivery delivery = state.delivery!.copyWith(
          courier: state.delivery!.courier!.copyWith(
            latitude: locationMessage.coordinates?.latitude,
            longitude: locationMessage.coordinates?.longitude,
          ),
        );
        emit(state.copyWith(
          delivery: delivery,
          status: DeliveryTrackingStatus.started,
          markers: await _getMarkersForDelivery(delivery),
          polyline: await _getPolylineForDelivery(delivery, locationMessage.coordinates!),
        ));
      }
    } catch (e) {
      developer.log('error: ${e.toString()}', name: 'DeliveryTrackingBlocOnMessageReceived');
    }
  }

  Future<Map<String, Marker>> _getMarkersForDelivery(Delivery delivery) async {
    LatLng position;
    Map<String, Marker> markers = {};
    if (delivery.status == DeliveryStatusEnum.pending.name) {
      position = LatLng(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
      markers['markerDropoff'] = Marker(
        markerId: const MarkerId('markerDropoff'),
        position: position,
        icon: customDestinationIcon,
      );
      LatLng pickupPosition = LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!);
      markers['markerPickup'] = Marker(
        markerId: const MarkerId('markerPickup'),
        position: pickupPosition,
        icon: customStartIcon,
      );
    } else if (delivery.status == DeliveryStatusEnum.accepted.name) {
      position = LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!);
      markers['markerDestination'] = Marker(
        markerId: const MarkerId('markerDestination'),
        position: position,
        icon: customDestinationIcon,
      );
    } else if (delivery.status == DeliveryStatusEnum.picked_up.name) {
      position = LatLng(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
      markers['markerDestination'] = Marker(
        markerId: const MarkerId('markerDestination'),
        position: position,
        icon: customDestinationIcon,
      );
    }
    if (delivery.courier != null && authUser.role == RoleEnum.client.name) {
      markers['markerCourier'] = Marker(
        markerId: const MarkerId('markerCourier'),
        position: LatLng(delivery.courier!.latitude!, delivery.courier!.longitude!),
        icon: customCourierIcon,
        anchor: Offset(0.5, 0.5),
      );
    }

    return markers;
  }

  Future<Polyline> _getPolylineForDelivery(Delivery delivery, LatLng currentLocation) async {
    final polylinePoints = PolylinePoints();
    PointLatLng startPoint;
    PointLatLng endPoint;
    startPoint = PointLatLng(currentLocation.latitude, currentLocation.longitude);
    if (delivery.status == DeliveryStatusEnum.pending.name) {
      endPoint = PointLatLng(delivery.dropoffLatitude!, delivery.dropoffLongitude!);
    } else if (delivery.status == DeliveryStatusEnum.accepted.name) {
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
      dotenv.env['GOOGLE_API_KEY']!,
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
