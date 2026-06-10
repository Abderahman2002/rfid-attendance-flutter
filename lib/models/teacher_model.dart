class TeacherModel {

  final int id;

  final String fullName;

  TeacherModel({

    required this.id,

    required this.fullName,
  });

  // =====================================
  // FROM JSON
  // =====================================

  factory TeacherModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return TeacherModel(

      id: json["id"] ?? 0,

      fullName:
          json["full_name"] ?? "",
    );
  }

  // =====================================
  // TO JSON
  // =====================================

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "full_name": fullName,
    };
  }
}