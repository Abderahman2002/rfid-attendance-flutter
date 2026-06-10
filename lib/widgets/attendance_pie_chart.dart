import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class AttendancePieChart extends StatelessWidget {

  final int present;

  final int absent;

  const AttendancePieChart({

    super.key,

    required this.present,

    required this.absent,
  });

  @override
  Widget build(BuildContext context) {

    final total = present + absent;

    final presentPercent =

        total == 0

            ? 0.0

            : (present / total) * 100;

    final absentPercent =

        total == 0

            ? 0.0

            : (absent / total) * 100;

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(

            "Attendance Analytics",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(

            height: 220,

            child: PieChart(

              PieChartData(

                centerSpaceRadius: 50,

                sectionsSpace: 4,

                sections: [

                  PieChartSectionData(

                    value: present.toDouble(),

                    color: Colors.green,

                    radius: 70,

                    title:
                        "${presentPercent.toStringAsFixed(0)}%",

                    titleStyle: const TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  PieChartSectionData(

                    value: absent.toDouble(),

                    color: Colors.red,

                    radius: 70,

                    title:
                        "${absentPercent.toStringAsFixed(0)}%",

                    titleStyle: const TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(

            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,

            children: [

              Row(

                children: [

                  Container(

                    width: 16,

                    height: 16,

                    decoration: const BoxDecoration(

                      color: Colors.green,

                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(

                    "Present ($present)",

                    style: const TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Row(

                children: [

                  Container(

                    width: 16,

                    height: 16,

                    decoration: const BoxDecoration(

                      color: Colors.red,

                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(

                    "Absent ($absent)",

                    style: const TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}