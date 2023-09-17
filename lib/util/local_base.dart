import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import 'package:path/path.dart';




class LocalRepo {
  Future<String?> getToken() async {
    final storage = new FlutterSecureStorage();
    String? value = await storage.read(key: 'token');
    return value;
  }

  Future<void> setToken(String token) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
  }

  Future<void> deleteToken() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: 'token');
  }

   
}
