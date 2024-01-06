import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMap extends StatelessWidget {
  final Delivery delivery;

  const DeliveryMap({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final DeliveryTrackingBloc deliveryTrackingBloc = BlocProvider.of<DeliveryTrackingBloc>(context);
    final user = BlocProvider.of<AuthBloc>(context).state.user;

    return BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(builder: (context, state) {
      bool isCourier = user?.role == RoleEnum.courier.name;
      return isCourier && state.location != null || user?.role == RoleEnum.client.name
          ? GoogleMap(
              initialCameraPosition: getInitialCameraPosition(state.polyline!),
              zoomControlsEnabled: true,
              myLocationEnabled: isCourier,
              myLocationButtonEnabled: isCourier,
              onMapCreated: deliveryTrackingBloc.initMap,
              markers: state.markers.values.toSet(),
              polylines: state.polyline != null ? {state.polyline!} : {},
            )
          : const Center(
              child: CircularProgressIndicator(),
            );
    });
  }
}

getInitialCameraPosition(Polyline polyline) {
  LatLngBounds bounds = getBounds(polyline.points);
  LatLng center = LatLng(
    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
    (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
  );
  return CameraPosition(target: center, zoom: 14);
}

LatLngBounds getBounds(List<LatLng> points) {
  double x0 = points[0].latitude;
  double x1 = points[0].latitude;
  double y0 = points[0].longitude;
  double y1 = points[0].longitude;

  for (var point in points.skip(1)) {
    if (point.latitude < x0) x0 = point.latitude;
    if (point.latitude > x1) x1 = point.latitude;
    if (point.longitude < y0) y0 = point.longitude;
    if (point.longitude > y1) y1 = point.longitude;
  }

  return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
}
