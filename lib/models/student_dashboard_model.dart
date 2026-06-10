class StudentDashboardModel {

  final Student student;

  final List<AttendanceItem>
      recentAttendance;

  StudentDashboardModel({

    required this.student,

    required this.recentAttendance,
  });

  factory StudentDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return StudentDashboardModel(

      student: Student.fromJson(
        json["student"] ?? {},
      ),

      recentAttendance:

          json["recent_attendance"] != null

              ? (json["recent_attendance"]
                      as List)

                  .map(

                    (item) =>

                        AttendanceItem
                            .fromJson(item),
                  )

                  .toList()

              : [],
    );
  }
}

// =====================================
// STUDENT
// =====================================

class Student {

  final String fullName;

  final String matricule;

  Student({

    required this.fullName,

    required this.matricule,
  });

  factory Student.fromJson(
    Map<String, dynamic> json,
  ) {

    return Student(

      fullName:

          json["full_name"]
                  ?.toString() ??

              "",

      matricule:

          json["matricule"]
                  ?.toString() ??

              "",
    );
  }
}

// =====================================
// ATTENDANCE ITEM
// =====================================

class AttendanceItem {

  final int id;

  final String subject;

  final String teacher;

  final String classroom;

  final String date;

  final String startTime;

  final String endTime;

  final String status;

  AttendanceItem({

    required this.id,

    required this.subject,

    required this.teacher,

    required this.classroom,

    required this.date,

    required this.startTime,

    required this.endTime,

    required this.status,
  });

  factory AttendanceItem.fromJson(
    Map<String, dynamic> json,
  ) {

    return AttendanceItem(

      id: json["id"] ?? 0,

      subject:

          json["subject"]
                  ?.toString() ??

              "",

      teacher:

          json["teacher"]
                  ?.toString() ??

              "",

      classroom:

          json["classroom"]
                  ?.toString() ??

              "",

      date:

          json["date"]
                  ?.toString() ??

              "",

      startTime:

          json["start_time"]
                  ?.toString() ??

              "",

      endTime:

          json["end_time"]
                  ?.toString() ??

              "",

      status:

          json["status"]
                  ?.toString() ??

              "",
    );
  }
}