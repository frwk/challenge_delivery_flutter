import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LocationService {
  static Future<Position> determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<dynamic> getAddressFromLatLng(String latitude, String longitude) async {
    try {
      final response = await http
          .get(Uri.parse("https://api-adresse.data.gouv.fr/reverse/?lon=$longitude&lat=$latitude"), headers: {'Accept': 'application/json'});
      final result = jsonDecode(response.body)['features'][0]['properties']['label'];

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      } else {
        return result;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getAddress(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse('https://api-adresse.data.gouv.fr/reverse/?lon=$longitude&lat=$latitude'));
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      final data = jsonDecode(response.body);

      if (data['features'] == null || data['features'].isEmpty) {
        throw Exception('Aucune adresse trouvée pour les coordonnées : $latitude, $longitude');
      }
      return data['features'][0]['properties']['label'];
    } catch (e) {
      developer.log(e.toString(), name: 'GET ADDRESS');
      rethrow;
    }
  }
}

final locationService = LocationService();
