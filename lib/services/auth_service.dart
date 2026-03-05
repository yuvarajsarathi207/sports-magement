import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hackoftrading/utils/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  
  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String mobile,
    required String role, // 'organization' or 'player'
  }) async {
    final response = await http.post(
      Uri.parse('https://keepplaying.in/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "name": username,
        "email": email,
        "password": password,
        "mobile": mobile,
        "role": role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await AppPreferences.setCustom('userDetails', response.body);
      debugPrint("User Created: ${response.body}");
      return true;
    } else {
      debugPrint("Error: ${response.body}");
      return false;
    }
  }

  /// Returns response body JSON string on success, null on failure.
  static Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('https://keepplaying.in/api/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.body;
      debugPrint("User Logged In: $body");
      // await AppPreferences.setCustom('userDetails', body);
      return body;
    } else {
      debugPrint("Error: ${response.body}");
      return null;
    }
  }

  static void logout() {
    AppPreferences.clear();
  }
}
