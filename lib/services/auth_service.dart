import 'dart:convert';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/auth/login'),
          headers: {'Accept': 'application/json'}, body: {'email': email, 'password': password});
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
      print('user: ${jsonDecode(response.body)}');
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('fesse');
      print('e: $e');
      rethrow;
    }
  }

  Future<User> isAuth() async {
    try {
      final cookie = await secureStorage.readCookie();
      if (cookie == null) {
        throw Exception('Aucun cookie trouvé');
      }
      final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/auth/check'), headers: {'Accept': 'application/json', 'Cookie': cookie});
      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}

final authService = AuthService();
