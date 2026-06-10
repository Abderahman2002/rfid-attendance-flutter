// =============================================
// lib/models/dashboard_stats.dart
// =============================================

// ── Stats globales ────────────────────────────
class DashboardStats {
  final int students;
  final int teachers;
  final int classrooms;
  final int sessions;
  final double attendanceRate;
  final int totalAttendance;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final List<TeacherStat> teachersStats;

  DashboardStats({
    required this.students,
    required this.teachers,
    required this.classrooms,
    required this.sessions,
    required this.attendanceRate,
    required this.totalAttendance,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.teachersStats,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      students:        json['students']          ?? 0,
      teachers:        json['teachers']          ?? 0,
      classrooms:      json['classrooms']        ?? 0,
      sessions:        json['sessions']          ?? 0,
      attendanceRate:  (json['attendance_rate']  ?? 0).toDouble(),
      totalAttendance: json['total_attendance']  ?? 0,
      presentCount:    json['present_count']     ?? 0,
      absentCount:     json['absent_count']      ?? 0,
      lateCount:       json['late_count']        ?? 0,
      teachersStats: (json['teachers_stats'] as List<dynamic>? ?? [])
          .map((e) => TeacherStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Stats par professeur ──────────────────────
class TeacherStat {
  final int    id;
  final String fullName;
  final int    sessionsCount;
  final double attendanceRate;
  final List<String> subjects;

  TeacherStat({
    required this.id,
    required this.fullName,
    required this.sessionsCount,
    required this.attendanceRate,
    required this.subjects,
  });

  factory TeacherStat.fromJson(Map<String, dynamic> json) {
    return TeacherStat(
      id:             json['id']               ?? 0,
      fullName:       json['full_name']        ?? '',
      sessionsCount:  json['sessions_count']   ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0).toDouble(),
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

// ── Étudiant (liste admin) ────────────────────
class StudentUser {
  final int    id;
  final String fullName;
  final String matricule;
  final String speciality;

  StudentUser({
    required this.id,
    required this.fullName,
    required this.matricule,
    required this.speciality,
  });

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      id:         json['id']         ?? 0,
      fullName:   json['full_name']  ?? '',
      matricule:  json['matricule']  ?? '',
      speciality: json['speciality'] ?? '',
    );
  }
}

// ── Taux de présence par étudiant ─────────────
class StudentAttendanceStat {
  final int    id;
  final String fullName;
  final String matricule;
  final String speciality;
  final int    total;
  final int    present;
  final int    absent;
  final int    late;
  final double rate;

  StudentAttendanceStat({
    required this.id,
    required this.fullName,
    required this.matricule,
    required this.speciality,
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.rate,
  });

  factory StudentAttendanceStat.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceStat(
      id:         json['id']         ?? 0,
      fullName:   json['full_name']  ?? '',
      matricule:  json['matricule']  ?? '',
      speciality: json['speciality'] ?? '',
      total:      json['total']      ?? 0,
      present:    json['present']    ?? 0,
      absent:     json['absent']     ?? 0,
      late:       json['late']       ?? 0,
      rate:       (json['rate']      ?? 0).toDouble(),
    );
  }
}

// ── Session ───────────────────────────────────
class SessionInfo {
  final int    id;
  final String subject;
  final String teacher;
  final String classroom;
  final String date;
  final String startTime;
  final String endTime;
  final bool   isActive;
  final int    studentsCount;
  final int    presentCount;
  final int    absentCount;
  final List<AttendanceInfo> attendances;

  SessionInfo({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.classroom,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.studentsCount,
    required this.presentCount,
    required this.absentCount,
    required this.attendances,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      id:            json['id']             ?? 0,
      subject:       json['subject']        ?? '',
      teacher:       json['teacher']        ?? '',
      classroom:     json['classroom']      ?? '',
      date:          json['date']           ?? '',
      startTime:     json['start_time']     ?? '',
      endTime:       json['end_time']       ?? '',
      isActive:      json['is_active']      ?? false,
      studentsCount: json['students_count'] ?? 0,
      presentCount:  json['present_count']  ?? 0,
      absentCount:   json['absent_count']   ?? 0,
      attendances: (json['attendances'] as List<dynamic>? ?? [])
          .map((e) => AttendanceInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Présence individuelle ─────────────────────
class AttendanceInfo {
  final String student;
  final String status;

  AttendanceInfo({required this.student, required this.status});

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      student: json['student'] ?? '',
      status:  json['status']  ?? 'absent',
    );
  }
}
