import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // =====================================
  // BASE URL
  // =====================================

  static const String baseUrl =
      "http://127.0.0.1:8000/api";

  // =====================================
  // STORAGE KEYS
  // =====================================

  static const String tokenKey =
      "token";

  static const String roleKey =
      "role";

  // =====================================
  // LOGIN
  // =====================================

  Future<Map<String, dynamic>> login({

    required String username,

    required String password,

  }) async {

    try {

      final response = await http.post(

        Uri.parse(
          "$baseUrl/token/",
        ),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "username": username,

          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
print("DJANGO RESPONSE = $data");

      // =====================================
      // SUCCESS
      // =====================================

      if (response.statusCode == 200) {

        final String token =
            data["access"];

        final String role =
            data["role"];

        final prefs =
            await SharedPreferences
                .getInstance();

        await prefs.setString(
          tokenKey,
          token,
        );

        await prefs.setString(
          roleKey,
          role,
        );

        return {

          "success": true,

          "token": token,

          "role": role,
        };
      }

      // =====================================
      // LOGIN FAILED
      // =====================================

      return {

        "success": false,

        "message":
            data["detail"] ??
                "Login failed",
      };

    } catch (e) {

      return {

        "success": false,

        "message":
            "Connection error",
      };
    }
  }

  // =====================================
  // GET TOKEN
  // =====================================

  static Future<String?> getToken()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      tokenKey,
    );
  }

  // =====================================
  // GET ROLE
  // =====================================

  static Future<String?> getRole()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      roleKey,
    );
  }

  // =====================================
  // LOGOUT
  // =====================================

  static Future<void> logout()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();
  }
}