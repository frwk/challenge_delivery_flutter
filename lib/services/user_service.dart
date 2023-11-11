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
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/users'),
          body: {'firstName': firstname, 'lastName': lastname, 'email': email, 'password': password});
      if (response.statusCode != 201) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Courier> registerCourier(String firstname, String lastname, String email, String password) async {
    try {
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/couriers'),
        headers: headers,
        body: jsonEncode({
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
}

final userService = UserService();
