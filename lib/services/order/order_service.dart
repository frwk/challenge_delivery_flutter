import 'dart:convert';
import 'package:challenge_delivery_flutter/exceptions/unauthorized_exception.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import '../../models/order.dart';

class OrderService {
  Future<Order> post(String pickupAddress, String dropoffAddress, int clientId) async {
    try {
      final cookie = await secureStorage.readCookie();
      developer.log('COOKIE: $cookie', name: 'COOKIE');
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/deliveries/new'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode({
          'pickupAddress': pickupAddress,
          'dropoffAddress': dropoffAddress,
          'clientId': clientId,
        }),
      );
      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 201) {
        if (response.statusCode == 403) {
          throw UnauthorizedException('Vous n\'êtes pas autorisé à effectuer cette action');
        }
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Order.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Delivery>> getUserDeliveries(User user) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/users/${user.id}/deliveries'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Delivery.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final orderService = OrderService();
