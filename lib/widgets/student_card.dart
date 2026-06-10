import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {

  final Map student;

  const StudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [

            Color(0xFF1565C0),

            Color(0xFF42A5F5),
          ],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(30),

        boxShadow: [

          BoxShadow(

            color:
                Colors.blue.withOpacity(0.18),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =====================================
          // TOP ROW
          // =====================================

          Row(

            children: [

              // =====================================
              // AVATAR
              // =====================================

              Container(

                width: 72,

                height: 72,

                decoration: BoxDecoration(

                  color:
                      Colors.white.withOpacity(0.18),

                  border: Border.all(

                    color:
                        Colors.white.withOpacity(0.25),

                    width: 2,
                  ),

                  shape: BoxShape.circle,
                ),

                child: const Icon(

                  Icons.school_rounded,

                  color: Colors.white,

                  size: 34,
                ),
              ),

              const Spacer(),

              // =====================================
              // STATUS
              // =====================================

              Container(

                padding:
                    const EdgeInsets.symmetric(

                  horizontal: 14,

                  vertical: 8,
                ),

                decoration: BoxDecoration(

                  color:
                      Colors.white.withOpacity(0.15),

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: const Row(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Icon(

                      Icons.verified,

                      color: Colors.white,

                      size: 18,
                    ),

                    SizedBox(width: 6),

                    Text(

                      "ACTIVE",

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

          const SizedBox(height: 24),

          // =====================================
          // WELCOME
          // =====================================

          Text(

            "Welcome Back 👋",

            style: TextStyle(

              color:
                  Colors.white.withOpacity(0.85),

              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          // =====================================
          // NAME
          // =====================================

          Text(

            student["full_name"] ?? "",

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

          const SizedBox(height: 18),

          // =====================================
          // MATRICULE CARD
          // =====================================

          Container(

            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(

              horizontal: 18,

              vertical: 16,
            ),

            decoration: BoxDecoration(

              color:
                  Colors.white.withOpacity(0.14),

              borderRadius:
                  BorderRadius.circular(22),
            ),

            child: Row(

              children: [

                Container(

                  padding:
                      const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color:
                        Colors.white.withOpacity(0.18),

                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: const Icon(

                    Icons.badge_rounded,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        "Student ID",

                        style: TextStyle(

                          color: Colors.white
                              .withOpacity(0.7),

                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(

                        student["matricule"] ?? "",

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 17,

                          fontWeight:
                              FontWeight.bold,
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