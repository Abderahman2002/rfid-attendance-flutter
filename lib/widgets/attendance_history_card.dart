import 'package:flutter/material.dart';

class AttendanceHistoryCard extends StatelessWidget {

  final Map attendance;

  const AttendanceHistoryCard({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {

    final bool isPresent =
        attendance["status"]
                .toString()
                .toLowerCase() ==
            "present";

    final Color statusColor =
        isPresent
            ? Colors.green
            : Colors.red;

    return Container(

      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(
              0.04,
            ),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =====================================
          // STATUS ICON
          // =====================================

          Container(

            width: 58,
            height: 58,

            decoration: BoxDecoration(

              color:
                  statusColor.withOpacity(
                0.12,
              ),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Icon(

              isPresent
                  ? Icons.check_circle
                  : Icons.cancel,

              color: statusColor,

              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // =====================================
          // CONTENT
          // =====================================

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =====================================
                // HEADER
                // =====================================

                Row(

                  children: [

                    Expanded(

                      child: Text(

                        attendance["subject"] ?? "",

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,

                          color:
                              Color(
                            0xFF1A1A1A,
                          ),
                        ),
                      ),
                    ),

                    Container(

                      padding:
                          const EdgeInsets.symmetric(

                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(

                        color: statusColor,

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),

                      child: Text(

                        isPresent
                            ? "PRESENT"
                            : "ABSENT",

                        style:
                            const TextStyle(

                          color: Colors.white,

                          fontSize: 11,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =====================================
                // TEACHER
                // =====================================

                Row(

                  children: [

                    Icon(

                      Icons.person_outline,

                      color:
                          Colors.grey.shade600,

                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(

                      child: Text(

                        attendance["teacher"] ?? "",

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style: TextStyle(

                          color:
                              Colors.grey.shade800,

                          fontSize: 14,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // =====================================
                // CLASSROOM + DATE
                // =====================================

                Row(

                  children: [

                    Icon(

                      Icons.location_on_outlined,

                      color:
                          Colors.grey.shade600,

                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Text(

                      attendance["classroom"] ?? "",

                      style: TextStyle(

                        color:
                            Colors.grey.shade800,

                        fontSize: 14,

                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    Icon(

                      Icons.calendar_today_outlined,

                      color:
                          Colors.grey.shade500,

                      size: 16,
                    ),

                    const SizedBox(width: 6),

                    Text(

                      attendance["date"] ?? "",

                      style: TextStyle(

                        color:
                            Colors.grey.shade600,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}