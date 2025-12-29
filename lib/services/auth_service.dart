import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // In-memory storage for demo (replace with actual storage/shared_preferences)
  static UserModel? _currentUser;
  
  static UserModel? get currentUser => _currentUser;
  static bool get isAuthenticated => _currentUser != null;
  
  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required String mobile,
    required String role, // 'organization' or 'player'
  }) async {
    final response = await http.post(
      Uri.parse('https://fakestoreapi.com/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": 0,
        "username": username,
        "email": email,
        "password": password,
        "mobile": mobile,
        "role": role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // For demo, create user model
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        mobile: mobile,
        username: username,
        role: role == 'organization' ? UserRole.organization : UserRole.player,
      );
      print("User Created: ${response.body}");
      return true;
    } else {
      print("Error: ${response.body}");
      return false;
    }
  }

  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/users'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // For demo, create a mock user
      // In real app, parse response and get actual user data
      final role =(email == "org@gmail.com") ?UserRole.organization:UserRole.player;
      _currentUser = UserModel(
        id: '1',
        email: email,
        mobile: '1234567890',
        username: email.split('@')[0],
        role: role,
      );
      print("User Logged In: ${response.body}");
      return true;
    } else {
      print("Error: ${response.body}");
      return false;
    }
  }
  
  static void logout() {
    _currentUser = null;
  }
}
