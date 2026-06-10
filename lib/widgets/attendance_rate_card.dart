import 'package:flutter/material.dart';

class AttendanceRateCard extends StatelessWidget {

  final int present;

  final int total;

  const AttendanceRateCard({
    super.key,
    required this.present,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {

    final double rate =

        total == 0

            ? 0

            : present / total;

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(0.05),

            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(

            "Attendance Rate",

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(

            borderRadius:
                BorderRadius.circular(20),

            child: LinearProgressIndicator(

              value: rate,

              minHeight: 14,

              backgroundColor:
                  Colors.grey.shade300,

              color: Colors.green,
            ),
          ),

          const SizedBox(height: 15),

          Text(

            "${(rate * 100).toStringAsFixed(0)}% Present",

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}