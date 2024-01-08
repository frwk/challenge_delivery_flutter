import 'dart:convert';
import 'dart:io';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  Future<User> getUserById(int id) async {
    final cookie = await secureStorage.readCookie();
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/users/$id'), headers: {'Accept': 'application/json', 'Cookie': cookie!});
    return User.fromJson(jsonDecode(response.body));
  }

  Future<User> registerClient(String firstname, String lastname, String email, String password) async {
    try {
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/auth/signup'),
          body: {'firstName': firstname, 'lastName': lastname, 'email': email, 'password': password});
      if (response.statusCode != 201) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Courier> registerCourier(String firstname, String lastname, String email, String password, String vehicle) async {
    try {
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/couriers'),
        headers: headers,
        body: jsonEncode({
          'vehicle': vehicle,
          'user': {'firstName': firstname, 'lastName': lastname, 'email': email, 'password': password}
        }),
      );
      if (response.statusCode != 201) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Courier.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final cookie = await secureStorage.readCookie();
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cookieHeader: cookie!};
      print('user: ${jsonEncode(user.toJson())}');
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/me'),
        headers: headers,
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updatePassword(int id, String password) async {
    try {
      final cookie = await secureStorage.readCookie();
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cookieHeader: cookie!};
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/me'),
        headers: headers,
        body: jsonEncode({'password': password}),
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Courier> updateCourier(Courier courier) async {
    try {
      final cookie = await secureStorage.readCookie();
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cookieHeader: cookie!};
      Map<String, dynamic> courierJson = courier.toJson();
      courierJson.remove('id');
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/couriers/${courier.id}'),
        headers: headers,
        body: jsonEncode(courierJson),
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Courier.fromJson(jsonDecode(response.body));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> verifyPassword(int id, String password) async {
    try {
      final cookie = await secureStorage.readCookie();
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.cookieHeader: cookie!};

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/$id/verify-password'),
        headers: headers,
        body: {'password': password},
      );
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        return false;
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final userService = UserService();
