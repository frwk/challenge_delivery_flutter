import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
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

    return BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(builder: (context, state) {
      return state.location != null
          ? GoogleMap(
              initialCameraPosition: CameraPosition(target: state.location!, zoom: 17.5),
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
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
