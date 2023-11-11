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
}

final secureStorage = SecureStorage();
