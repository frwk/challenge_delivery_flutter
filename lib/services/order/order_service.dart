import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/exceptions/unauthorized_exception.dart';
import 'package:challenge_delivery_flutter/helpers/format_string.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'dart:io';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/interfaces/client_stats.dart';
import 'package:challenge_delivery_flutter/interfaces/courier_stats.dart';
import 'package:challenge_delivery_flutter/interfaces/user_stats.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import '../../bloc/order/order_bloc.dart';
import '../../models/order.dart';

class OrderService {
  late Emitter<OrderState> emit;

  Future<Order> getOrderInfos(String vehicle, String urgency, String pickupAddress, String dropoffAddress) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/users/deliveries/total'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Cookie': cookie!},
          body: jsonEncode(
              {'vehicle': vehicle, 'urgency': FormatString.capitalize(urgency), 'pickupAddress': pickupAddress, 'dropoffAddress': dropoffAddress}));

      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw UnauthorizedException('Vous n\'êtes pas autorisé à effectuer cette action');
        }
        if (response.statusCode == 404) {
          throw NotFoundException('Adresse introuvable');
        }
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Order.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log(e.toString(), name: 'GET ORDER INFOS');
      rethrow;
    }
  }

  Future<Order> post(String pickupAddress, String dropoffAddress, String vehicle, String urgency, int clientId) async {
    try {
      final cookie = await secureStorage.readCookie();
      developer.log('COOKIE: $cookie', name: 'COOKIE');
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/deliveries/new'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Cookie': cookie!},
        body: jsonEncode({
          'pickupAddress': pickupAddress,
          'dropoffAddress': dropoffAddress,
          'vehicle': vehicle,
          'urgency': FormatString.capitalize(urgency),
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

  Future<List<Delivery>> getCourierDeliveries(Courier courier) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/couriers/${courier.id}/deliveries'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Delivery.fromJson(e)).toList();
    } catch (e) {
      developer.log(e.toString(), name: 'GET USER DELIVERIES');
      rethrow;
    }
  }

  Future<List<Delivery>> getNearbyDeliveries(Courier courier) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/couriers/${courier.id}/deliveries/pending'),
          headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Delivery.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CourierStats> getCourierStats(Courier courier) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http
          .get(Uri.parse('${dotenv.env['API_URL']}/couriers/${courier.id}/stats'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return CourierStats.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log(e.toString(), name: 'GET COURIER STATS');
      rethrow;
    }
  }

  Future<ClientStats> getUserStats(User user) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/users/${user.id}/stats'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
      developer.log('response: ${response.body}', name: 'GET USER STATS');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return ClientStats.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log(e.toString(), name: 'GET USER STATS');
      rethrow;
    }
  }

  Future<Delivery> updateDelivery(Delivery delivery) async {
    try {
      final cookie = await secureStorage.readCookie();
      developer.log(jsonEncode(delivery.toJson()), name: 'UPDATE DELIVERY');
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/deliveries/${delivery.id}'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cookieHeader: cookie!},
        body: jsonEncode(delivery.toJson()),
      );
      if (response.statusCode != 200) {
        developer.log('EXCEPTION API', name: 'UPDATE DELIVERY');
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Delivery.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log(e.toString(), name: 'UPDATE DELIVERY');
      rethrow;
    }
  }

  Future<Delivery> getCurrentCourierDelivery(Courier courier) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/couriers/${courier.id}/deliveries/current'),
          headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw NotFoundException(jsonDecode(response.body)['message']);
      }
      return Delivery.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log(e.toString(), name: 'GET CURRENT COURIER DELIVERY');
      rethrow;
    }
  }

  Future<Delivery?> getDelivery(int id) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/deliveries/$id'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Delivery.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}

final orderService = OrderService();
