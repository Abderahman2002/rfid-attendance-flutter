import 'package:flutter/material.dart';

class TeacherCard extends StatelessWidget {

  final Map teacher;

  final bool isLive;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [

            Color(0xFF0039CB),
            Color(0xFF2979FF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [

          BoxShadow(

            color: Colors.blue
                .withOpacity(0.25),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(

        children: [

          // AVATAR

          Container(

            width: 80,
            height: 80,

            decoration: BoxDecoration(

              color:
                  Colors.white.withOpacity(0.18),

              shape: BoxShape.circle,
            ),

            child: const Icon(

              Icons.person,

              color: Colors.white,

              size: 42,
            ),
          ),

          const SizedBox(width: 20),

          // INFO

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  teacher["full_name"] ?? "",

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 26,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(

                  teacher["subjects"] != null

                      ? (teacher["subjects"] as List)

                          .map(
                            (subject) =>
                                subject["name"]
                                    .toString(),
                          )

                          .join(" • ")

                      : "",

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 15,

                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                if (isLive)

                  Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.green,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Row(

                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        Icon(

                          Icons.circle,

                          color: Colors.white,

                          size: 10,
                        ),

                        SizedBox(width: 8),

                        Text(

                          "LIVE SESSION",

                          style: TextStyle(

                            color: Colors.white,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}