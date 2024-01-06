import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/delivery_tracking.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DeliveryTrackingEvent {}

class StartDeliveryTracking extends DeliveryTrackingEvent {
  final User user;
  final Delivery? delivery;
  StartDeliveryTracking({required this.user, this.delivery});
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

class MessageReceivedEvent extends DeliveryTrackingEvent {
  final DeliveryTrackingReceivedMessage message;
  MessageReceivedEvent(this.message);
}
