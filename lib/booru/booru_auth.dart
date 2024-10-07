// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class BooruAuth {
  // Danbooru
  //login=your_username&api_key=your_api_key
  //request.Headers["Cookie"] = "user_id=" + Auth.UserId + ";pass_hash=" + Auth.PasswordHash;

  final String provider;
  late String username;
  late String password;
  late String? userId;
  late String? apiKey;

  /// [convertPassword] = true irá converter a senha para hash
  BooruAuth({this.username = '', this.password = '', this.userId, this.apiKey, required this.provider});

  BooruAuth.fromJson(Map? map) :
        username = map?['username'] ?? '',
        password = map?['password'] ?? '',
        provider = map?['provider'] ?? '',
        userId = map?['userId'] ?? '',
        apiKey = map?['apiKey'] ?? '';

  static Map<String, BooruAuth> fromJsonMap(Map? map) {
    Map<String, BooruAuth> items = {};
    map?.forEach((key, value) {
      items[key] = BooruAuth.fromJson(value);
    });
    return items;
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'provider': provider,
    'userId': userId,
    'apiKey': apiKey,
  };


  String get passwordHash {
    var bytes1 = utf8.encode(password);
    var digest1 = sha1.convert(bytes1);
    if (kDebugMode) {
      print("Digest as hex string: $digest1");
    }

    return '$digest1';
    // return 'So-I-Heard-You-Like-Mupkids-?-- $digest1 --';
  }
}