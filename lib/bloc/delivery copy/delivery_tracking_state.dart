import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DeliveryTrackingStatus { initial, success, error, loading, started }

enum DeliveryTrackingErrorType { notFound, unknown }

extension DeliveryTrackingStatusX on DeliveryTrackingStatus {
  bool get isInitial => this == DeliveryTrackingStatus.initial;
  bool get isSuccess => this == DeliveryTrackingStatus.success;
  bool get isError => this == DeliveryTrackingStatus.error;
  bool get isLoading => this == DeliveryTrackingStatus.loading;
  bool get isStarted => this == DeliveryTrackingStatus.started;
}

extension DeliveryTrackingErrorTypeX on DeliveryTrackingErrorType {
  bool get isNotFound => this == DeliveryTrackingErrorType.notFound;
  bool get isUnknown => this == DeliveryTrackingErrorType.unknown;
}

class DeliveryTrackingState extends Equatable {
  final DeliveryTrackingStatus status;
  final Map<String, Marker> markers;
  final Polyline? polyline;
  final Delivery? delivery;
  final LatLng? location;
  final DeliveryTrackingErrorType errorType;

  DeliveryTrackingState({
    this.status = DeliveryTrackingStatus.initial,
    Map<String, Marker>? markers,
    Polyline? polyline,
    Delivery? delivery,
    LatLng? location,
    DeliveryTrackingErrorType? errorType,
  })  : markers = markers ?? <String, Marker>{},
        polyline = polyline,
        delivery = delivery,
        location = location,
        errorType = errorType ?? DeliveryTrackingErrorType.unknown;

  DeliveryTrackingState copyWith({
    bool? isReadyMapDelivery,
    Map<String, Marker>? markers,
    Polyline? polyline,
    Delivery? delivery,
    DeliveryTrackingStatus? status,
    LatLng? location,
    DeliveryTrackingErrorType? errorType,
  }) =>
      DeliveryTrackingState(
        markers: markers ?? this.markers,
        polyline: polyline ?? this.polyline,
        delivery: delivery ?? this.delivery,
        status: status ?? this.status,
        location: location ?? this.location,
        errorType: errorType ?? this.errorType,
      );

  @override
  List<Object?> get props => [status, markers, polyline, delivery, location];

  Map<String, dynamic> toJson() {
    return {
      'markers': markers.entries
          .map((entry) => {
                'id': entry.key,
                'position': {
                  'latitude': entry.value.position.latitude,
                  'longitude': entry.value.position.longitude,
                },
              })
          .toList(),
      'polyline': polyline != null
          ? polyline?.points
              .map((point) => {
                    'latitude': point.latitude,
                    'longitude': point.longitude,
                  })
              .toList()
          : null,
      'delivery': delivery != null ? delivery?.toJson() : null,
      'status': status.toString(),
      'location': location != null
          ? {
              'latitude': location?.latitude,
              'longitude': location?.longitude,
            }
          : null,
      'errorType': errorType.toString(),
    };
  }
}
