import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {

  final String subject;
  final String room;
  final String time;
  final String status;
  final Color statusColor;

  const SessionCard({
    super.key,
    required this.subject,
    required this.room,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: const [

          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),

      child: Row(

        children: [

          // ================= TIME =================

          Container(

            width: 95,

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color: const Color(0xFFF3F6FD),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Text(
              time,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // ================= INFO =================

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  subject,

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  room,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(

                    color:
                        statusColor.withOpacity(0.15),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    status,

                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
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