import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_stats.dart';

class AdminService {

  static const String _base = "http://192.168.0.123:8000/api";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    if (token.isEmpty) token = prefs.getString('access_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type':  'application/json',
    };
  }

  static Future<DashboardStats> getDashboardStats() async {
    final res = await http.get(Uri.parse('$_base/admin/dashboard/'), headers: await _headers());
    if (res.statusCode == 200) return DashboardStats.fromJson(jsonDecode(res.body));
    throw Exception('Erreur dashboard: ${res.statusCode}');
  }

  static Future<List<StudentUser>> getStudents() async {
    final res = await http.get(Uri.parse('$_base/students/'), headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => StudentUser.fromJson(e)).toList();
    }
    throw Exception('Erreur étudiants: ${res.statusCode}');
  }

  static Future<List<StudentAttendanceStat>> getStudentsStats() async {
    final res = await http.get(Uri.parse('$_base/admin/students-stats/'), headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => StudentAttendanceStat.fromJson(e)).toList();
    }
    throw Exception('Erreur stats: ${res.statusCode}');
  }

  static Future<List<SessionInfo>> getSessions() async {
    final res = await http.get(Uri.parse('$_base/admin/sessions/'), headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => SessionInfo.fromJson(e)).toList();
    }
    throw Exception('Erreur sessions: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(Uri.parse('$_base/profile/'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur profil: ${res.statusCode}');
  }

  static Future<Uint8List> downloadAttendancePdf() async {
    final res = await http.get(Uri.parse('$_base/admin/report/pdf/'), headers: await _headers());
    if (res.statusCode == 200) return res.bodyBytes;
    throw Exception('Erreur PDF: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> filterByDate({String? dateDebut, String? dateFin}) async {
    String url = '$_base/admin/filter/';
    final params = <String>[];
    if (dateDebut != null) params.add('date_debut=$dateDebut');
    if (dateFin   != null) params.add('date_fin=$dateFin');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur filtre: ${res.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getStatsBySubject() async {
    final res = await http.get(Uri.parse('$_base/admin/stats-by-subject/'), headers: await _headers());
    if (res.statusCode == 200) return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Erreur stats matières: ${res.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getStatsBySpeciality() async {
    final res = await http.get(Uri.parse('$_base/admin/stats-by-speciality/'), headers: await _headers());
    if (res.statusCode == 200) return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Erreur stats spécialités: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> addStudent({
    required String fullName, required String username,
    required String password, required String matricule, required String speciality,
  }) async {
    final res = await http.post(Uri.parse('$_base/admin/add-student/'),
      headers: await _headers(),
      body: jsonEncode({'full_name': fullName, 'username': username,
        'password': password, 'matricule': matricule, 'speciality': speciality}));
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Erreur ajout étudiant');
  }

  static Future<Map<String, dynamic>> addTeacher({
    required String fullName, required String username,
    required String password, required String subject,
  }) async {
    final res = await http.post(Uri.parse('$_base/admin/add-teacher/'),
      headers: await _headers(),
      body: jsonEncode({'full_name': fullName, 'username': username,
        'password': password, 'subject': subject}));
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Erreur ajout professeur');
  }

  static Future<List<Map<String, dynamic>>> getSchedules() async {
    final res = await http.get(Uri.parse('$_base/admin/schedules/'), headers: await _headers());
    if (res.statusCode == 200) return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Erreur planning: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> addSchedule({
    required String username, required String day,
    required String startTime, required String endTime, required String classroom,
  }) async {
    final res = await http.post(Uri.parse('$_base/admin/add-schedule/'),
      headers: await _headers(),
      body: jsonEncode({'username': username, 'day': day,
        'start_time': startTime, 'end_time': endTime, 'classroom': classroom}));
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Erreur ajout planning');
  }

  static Future<void> deleteSchedule({required String username, required dynamic scheduleId}) async {
    final res = await http.delete(Uri.parse('$_base/admin/delete-schedule/'),
      headers: await _headers(),
      body: jsonEncode({'username': username, 'schedule_id': scheduleId}));
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error'] ?? 'Erreur suppression');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
