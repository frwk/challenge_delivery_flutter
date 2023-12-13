import 'dart:convert';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/complaint.dart';

class ComplaintService {
  Future<List<Complaint>> get(int userId) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}/complaints/user/$userId'),
          headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return List<Complaint>.from(
          jsonDecode(response.body).map((x) => Complaint.fromJson(x)));
    } catch (e) {
      rethrow;
    }
  }

  Future<Complaint> markAsResolved(int complaintId) async {
    try {
      final cookie = await secureStorage.readCookie();
      final response = await http.patch(
          Uri.parse(
              '${dotenv.env['API_URL']}/complaints/$complaintId/resolved'),
          headers: {'Accept': 'application/json', 'Cookie': cookie!});
      if (response.body.isEmpty) throw Exception('Erreur lors de la connexion');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
      return Complaint.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}

final complaintService = ComplaintService();
