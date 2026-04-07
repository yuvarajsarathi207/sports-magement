import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hackoftrading/utils/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const String _baseUrl = "https://keepplaying.in/api";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  /// Register User
  static Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String mobile,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/register"),
        headers: _headers,
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
        debugPrint("✅ User Registered Successfully");
        return response.body;
      }

      debugPrint("❌ Register Failed: ${response.body}");
      // Return body so UI can show validation error messages.
      return response.body;
    } catch (e) {
      debugPrint("❌ Register Exception: $e");
      return null;
    }
  }

  /// Login User
  static Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: _headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        debugPrint("✅ User Login Success");
        return body;
      }

      debugPrint("❌ Login Failed: ${response.body}");
      // Return body so UI can show validation error messages.
      return response.body;
    } catch (e) {
      debugPrint("❌ Login Exception: $e");
      return null;
    }
  }

  /// Get Organizer Tournaments
  static Future<List<dynamic>?> getOrganizerTournaments() async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.get(
        Uri.parse("$_baseUrl/organizer/tournaments"),
        headers: {
          ..._headers,
          "Accept": "*/*",
          "Authorization": "Bearer ${token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        debugPrint("✅ Tournaments Fetched Successfully");

        if (decoded is List) {
          return decoded;
        }

        return decoded['data']; // if API wraps response
      }

      debugPrint("❌ Tournament Fetch Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("❌ Tournament Exception: $e");
      return null;
    }
  }

  /// Get Player Tournaments
  static Future<List<dynamic>?> getPlayerTournaments() async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.get(
        Uri.parse("$_baseUrl/player/tournaments"),
        headers: {
          ..._headers,
          "Accept": "*/*",
          "Authorization": "Bearer ${token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        debugPrint("✅ Tournaments Fetched Successfully");

        if (decoded is List) {
          return decoded;
        }

        return decoded['data']; // if API wraps response
      }

      debugPrint("❌ Tournament Fetch Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("❌ Tournament Exception: $e");
      return null;
    }
  }

  /// Organizer Dashboard
  /// GET /organizer/dashboard
  /// Response: { "tournaments": [...], "stats": {...} }
  static Future<Map<String, dynamic>?> getOrganizerDashboard() async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.get(
        Uri.parse("$_baseUrl/organizer/dashboard"),
        headers: {
          ..._headers,
          "Accept": "application/json",
          "Authorization": "Bearer ${token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return null;
      }

      debugPrint("❌ Organizer Dashboard Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("❌ Organizer Dashboard Exception: $e");
      return null;
    }
  }

  /// Player Dashboard
  /// GET /player/dashboard
  /// Response: { "subscriptions": [...], "interests": [...] }
  static Future<Map<String, dynamic>?> getPlayerDashboard() async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.get(
        Uri.parse("$_baseUrl/player/dashboard"),
        headers: {
          ..._headers,
          "Accept": "*/*",
          "Authorization": "Bearer ${token ?? ''}",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return null;
      }

      debugPrint("❌ Player Dashboard Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("❌ Player Dashboard Exception: $e");
      return null;
    }
  }

  /// Mark tournament as interested for player.
  static Future<bool> markTournamentInterest(int tournamentId) async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.post(
        Uri.parse("$_baseUrl/player/tournaments/$tournamentId/interest"),
        headers: {"Accept": "*/*", "Authorization": "Bearer ${token ?? ''}"},
        body: "",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Interest marked for tournament $tournamentId");
        return true;
      }

      debugPrint("❌ Mark Interest Failed: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("❌ Mark Interest Exception: $e");
      return false;
    }
  }

  /// Create Tournament (draft). Returns created tournament data including id, or null on failure.
  static Future<Map<String, dynamic>?> createTournament({
    required int sportsCategoryId,
    required String teamName,
    required String location,
    required String locationDetails,
    required String startDate,
    required String winningDate,
    required int slotCount,
    required String template,
    required String rules,
    required int entryFee,
    required String priceDetails,
    required String ballType,
  }) async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.post(
        Uri.parse("$_baseUrl/organizer/tournaments"),
        headers: {
          ..._headers,
          "Accept": "*/*",
          "Authorization": "Bearer ${token ?? ''}",
        },
        body: jsonEncode({
          "sports_category_id": sportsCategoryId,
          "team_name": teamName,
          "location": location,
          "location_details": locationDetails,
          "start_date": startDate,
          "winning_date": winningDate,
          "slot_count": slotCount,
          "template": template,
          "rules": rules,
          "entry_fee": entryFee,
          "price_details": priceDetails,
          "ball_type": ballType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Tournament Created");
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>? ?? decoded;
        }
        return null;
      }

      debugPrint("❌ Create Tournament Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("❌ Create Tournament Exception: $e");
      return null;
    }
  }

  /// Publish a tournament by id.
  static Future<bool> publishTournament(int tournamentId) async {
    try {
      final token = await AppPreferences.getString('token');

      final response = await http.post(
        Uri.parse("$_baseUrl/organizer/tournaments/$tournamentId/publish"),
        headers: {"Accept": "*/*", "Authorization": "Bearer ${token ?? ''}"},
        body: "",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Tournament Published");
        return true;
      }

      debugPrint("❌ Publish Tournament Failed: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("❌ Publish Tournament Exception: $e");
      return false;
    }
  }

  /// Logout
  static Future<void> logout() async {
    await AppPreferences.clear();
    debugPrint("👋 User Logged Out");
  }
}
