class SubjectModel {

  final int id;

  final String name;

  // =====================================
  // CONSTRUCTOR
  // =====================================

  SubjectModel({

    required this.id,

    required this.name,
  });

  // =====================================
  // FROM JSON
  // =====================================

  factory SubjectModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SubjectModel(

      id: json["id"] ?? 0,

      name: json["name"] ?? "",
    );
  }

  // =====================================
  // TO STRING
  // =====================================

  @override
  String toString() {

    return name;
  }
}