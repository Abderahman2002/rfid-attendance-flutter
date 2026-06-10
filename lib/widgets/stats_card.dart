import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {

  final IconData icon;

  final Color color;

  final String number;

  final String title;

  const StatsCard({
    super.key,
    required this.icon,
    required this.color,
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      height: 180,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color:
                Colors.grey.withOpacity(0.08),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          CircleAvatar(

            radius: 24,

            backgroundColor:
                color.withOpacity(0.15),

            child: Icon(

              icon,

              color: color,

              size: 28,
            ),
          ),

          const Spacer(),

          Text(

            number,

            style: const TextStyle(

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(

            title,

            style: TextStyle(

              fontSize: 15,

              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}