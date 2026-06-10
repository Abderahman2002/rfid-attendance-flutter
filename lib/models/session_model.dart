import 'attendance_model.dart';

class SessionModel {

  final int id;

  final String subject;

  final String teacher;

  final String classroom;

  final String date;

  final String startTime;

  final String endTime;

  final bool isActive;

  final int studentsCount;

  final int presentCount;

  final int absentCount;

  final List<AttendanceModel>
      attendances;

  SessionModel({

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

  // =====================================
  // FROM JSON
  // =====================================

  factory SessionModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SessionModel(

      id: json["id"] ?? 0,

      subject:
          json["subject"] ?? "",

      teacher:
          json["teacher"] ?? "",

      classroom:
          json["classroom"] ?? "",

      date:
          json["date"] ?? "",

      startTime:
          json["start_time"] ?? "",

      endTime:
          json["end_time"] ?? "",

      isActive:
          json["is_active"] ?? false,

      studentsCount:
          json["students_count"] ?? 0,

      presentCount:
          json["present_count"] ?? 0,

      absentCount:
          json["absent_count"] ?? 0,

      attendances:

          (json["attendances"] as List?)

              ?.map(

                (attendance) =>

                    AttendanceModel
                        .fromJson(
                            attendance),
              )

              .toList()

              ?? [],
    );
  }

  // =====================================
  // TO JSON
  // =====================================

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "subject": subject,

      "teacher": teacher,

      "classroom": classroom,

      "date": date,

      "start_time": startTime,

      "end_time": endTime,

      "is_active": isActive,

      "students_count":
          studentsCount,

      "present_count":
          presentCount,

      "absent_count":
          absentCount,

      "attendances":

          attendances.map(

            (attendance) =>

                attendance.toJson(),
          ).toList(),
    };
  }
}