import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerType { start, destination, courier }

Future<BitmapDescriptor> getMarkerIcon(
  MarkerType type,
) async {
  switch (type) {
    case MarkerType.start:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(150, 150)), 'assets/img/markers/start150.png');
    case MarkerType.destination:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(150, 150)), 'assets/img/markers/destination150.png');
    case MarkerType.courier:
      return await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(150, 99)), 'assets/img/markers/courier150.png');
  }
}
