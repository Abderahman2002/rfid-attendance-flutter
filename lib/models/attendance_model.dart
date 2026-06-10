class AttendanceModel {

  final int id;

  final String student;

  final String subject;

  final String teacher;

  final String classroom;

  final String date;

  final String startTime;

  final String endTime;

  final String status;

  AttendanceModel({

    required this.id,

    required this.student,

    required this.subject,

    required this.teacher,

    required this.classroom,

    required this.date,

    required this.startTime,

    required this.endTime,

    required this.status,
  });

  // =====================================
  // FROM JSON
  // =====================================

  factory AttendanceModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return AttendanceModel(

      id: json["id"] ?? 0,

      student:
          json["student"] ?? "",

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

      status:
          json["status"] ?? "",
    );
  }

  // =====================================
  // TO JSON
  // =====================================

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "student": student,

      "subject": subject,

      "teacher": teacher,

      "classroom": classroom,

      "date": date,

      "start_time": startTime,

      "end_time": endTime,

      "status": status,
    };
  }
}