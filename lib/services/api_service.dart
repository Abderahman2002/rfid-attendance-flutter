import 'dart:convert';
 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
import '../models/profile_model.dart';
import '../models/student_dashboard_model.dart';
 
class ApiService {
 
  static const String baseUrl =
      "http://192.168.0.123:8000/api";
 
  static Map<String, String> headers(String token) {
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }
 
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/token/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
 
      final data = jsonDecode(response.body);
      print("DJANGO RESPONSE = $data");
 
      if (response.statusCode == 200) {
        final String token = data["access"] ?? "";
        final String role  = data["role"]   ?? "";
 
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("role",  role);
 
        print("✅ Token sauvegardé");
        print("✅ Role: $role");
 
        return {
          "success": true,
          "token":   token,
          "refresh": data["refresh"] ?? "",
          "role":    role,
        };
      }
 
      return {
        "success": false,
        "message": data["detail"] ?? "Login failed",
      };
 
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
 
  static Future<Map<String, dynamic>> getTeacherDashboard(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/teacher/dashboard/"),
      headers: headers(token),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Dashboard error");
  }
 
  static Future<StudentDashboardModel> getStudentDashboard(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/student/dashboard/"),
      headers: headers(token),
    );
    if (response.statusCode == 200) {
      return StudentDashboardModel.fromJson(jsonDecode(response.body));
    }
    throw Exception("Student dashboard error");
  }
 
  static Future<List<dynamic>> getClassrooms(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/classrooms/"),
      headers: headers(token),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Classrooms error");
  }
 
  static Future<Map<String, dynamic>> startSession(
    String token, int subjectId, int classroomId,
    String startTime, String endTime,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teacher/start-session/"),
      headers: headers(token),
      body: jsonEncode({
        "subject_id":   subjectId,
        "classroom_id": classroomId,
        "start_time":   startTime,
        "end_time":     endTime,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? "Start session failed");
  }
 
  static Future<Map<String, dynamic>> endSession(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teacher/end-session/"),
      headers: headers(token),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? "End session failed");
  }
 
  static Future<Map<String, dynamic>> scanAttendance(
    String token, String rfidCard,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/scan/"),
      headers: headers(token),
      body: jsonEncode({"rfid_card": rfidCard}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw Exception(data["error"] ?? "Scan failed");
  }
 
  static Future<List> getTeacherSchedule(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/teacher/my-schedule/"),
      headers: headers(token),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["schedule"] ?? [];
    }
    throw Exception("Schedule error");
  }
 
  static Future<ProfileModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/"),
      headers: headers(token),
    );
    if (response.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(response.body));
    }
    throw Exception("Profile error");
  }
}