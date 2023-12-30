import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DeliveryTrackingEvent {}

class StartDeliveryTracking extends DeliveryTrackingEvent {
  final Courier courier;
  StartDeliveryTracking(this.courier);
}

class StopDeliveryTracking extends DeliveryTrackingEvent {
  StopDeliveryTracking();
}

class ChangeLocationEvent extends DeliveryTrackingEvent {
  final LatLng location;
  ChangeLocationEvent(this.location);
}

class UpdateDeliveryStatusEvent extends DeliveryTrackingEvent {
  final DeliveryStatusEnum status;
  UpdateDeliveryStatusEvent(this.status);
}
