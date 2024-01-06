import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryTrackingReceivedMessage {
  final String type;
  final dynamic data;

  DeliveryTrackingReceivedMessage({required this.type, required this.data});

  factory DeliveryTrackingReceivedMessage.fromJson(Map<String, dynamic> json) {
    return DeliveryTrackingReceivedMessage(
      type: json['type'],
      data: json['data'],
    );
  }
}

class DeliveryTrackingSendMessage {
  final String type;
  final int courierId;
  final Object coordinates;

  DeliveryTrackingSendMessage({
    required this.type,
    required this.courierId,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'courierId': courierId,
        'coordinates': coordinates,
      };
}

class DeliveryTrackingReceivedData {
  final String? deliveryStatus;
  final LatLng? coordinates;

  DeliveryTrackingReceivedData({
    required this.deliveryStatus,
    required this.coordinates,
  });

  factory DeliveryTrackingReceivedData.fromJson(Map<String, dynamic> json) {
    var coordinatesList = json['coordinates'] as List?;
    LatLng? coordinates;
    if (coordinatesList != null && coordinatesList.length == 2) {
      coordinates = LatLng(coordinatesList[0], coordinatesList[1]);
    }
    return DeliveryTrackingReceivedData(
      deliveryStatus: json['deliveryStatus'] as String?,
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() => {
        'deliveryStatus': deliveryStatus,
        'coordinates': coordinates != null ? [coordinates!.latitude, coordinates!.longitude] : null,
      };
}
