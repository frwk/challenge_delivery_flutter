import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerType { start, destination, courier }

Future<BitmapDescriptor> getMarkerIcon(
  MarkerType type,
) async {
  switch (type) {
    case MarkerType.start:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(192, 192)), 'assets/img/markers/start2.png');
    case MarkerType.destination:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(192, 192)), 'assets/img/markers/destination.png');
    case MarkerType.courier:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(256, 169)), 'assets/img/markers/courier.png');
  }
}
