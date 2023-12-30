import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final secureStorage = const FlutterSecureStorage();

  Future<void> persistCookie(String cookie) async {
    await secureStorage.write(key: 'cookie', value: cookie);
  }

  Future<String?> readCookie() async {
    return await secureStorage.read(key: 'cookie');
  }

  Future<void> deleteSecureStorage() async {
    await secureStorage.deleteAll();
  }

  Future<List<String>> getRefusedDeliveries() async {
    final jsonString = await secureStorage.read(key: 'refused_deliveries');
    if (jsonString == null) return [];
    return List<String>.from(json.decode(jsonString));
  }

  void refuseDelivery(String deliveryId) async {
    final currentRefused = await getRefusedDeliveries();
    if (!currentRefused.contains(deliveryId)) {
      currentRefused.add(deliveryId);
      await secureStorage.write(key: 'refused_deliveries', value: json.encode(currentRefused));
    }
  }

  Future<void> delete(String key) async {
    await secureStorage.delete(key: key);
  }
}

final secureStorage = SecureStorage();
