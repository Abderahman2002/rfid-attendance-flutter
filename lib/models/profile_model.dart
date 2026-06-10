import 'subject_model.dart';

class ProfileModel {

  final int id;

  final String fullName;

  final String username;

  final String email;

  final String role;

  // =====================================
  // TEACHER
  // =====================================

  final List<SubjectModel> subjects;

  // =====================================
  // STUDENT
  // =====================================

  final String matricule;

  final String speciality;

  // =====================================
  // CONSTRUCTOR
  // =====================================

  ProfileModel({

    required this.id,

    required this.fullName,

    required this.username,

    required this.email,

    required this.role,

    required this.subjects,

    required this.matricule,

    required this.speciality,
  });

  // =====================================
  // FROM JSON
  // =====================================

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ProfileModel(

      id: json["id"] ?? 0,

      fullName:
          json["full_name"] ?? "",

      username:
          json["username"] ?? "",

      email:
          json["email"] ?? "",

      role:
          json["role"] ?? "",

      // =================================
      // TEACHER DATA
      // =================================

      subjects:

          (json["subjects"] as List?)

              ?.map(

                (subject) =>

                    SubjectModel.fromJson(
                        subject),
              )

              .toList()

          ?? [],

      // =================================
      // STUDENT DATA
      // =================================

      matricule:
          json["matricule"] ?? "",

      speciality:
          json["speciality"] ?? "",
    );
  }
}