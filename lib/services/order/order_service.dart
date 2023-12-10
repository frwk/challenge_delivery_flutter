import 'dart:convert';
import 'dart:io';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/order.dart';

class OrderService {
  Future<Order> post(String departureAddress, String arrivalAddress, String packageType, String packageWeight)
  async
  {
    try {
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/orders'),
          headers: {'Accept': 'application/json'}, body: {'departureAddress': departureAddress, 'arrivalAddress': arrivalAddress, 'packageType': packageType, 'packageWeight': packageWeight});
      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      String? cookie = response.headers['set-cookie'];
      if (cookie == null) {
        throw Exception('Erreur lors de la connexion');
      }
      await secureStorage.deleteSecureStorage();
      await secureStorage.persistCookie(cookie);
      return Order.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}

final orderService = OrderService();