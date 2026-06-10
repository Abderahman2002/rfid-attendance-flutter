import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {

  final String subject;
  final String date;
  final String status;
  final bool isPresent;

  const HistoryCard({
    super.key,
    required this.subject,
    required this.date,
    required this.status,
    required this.isPresent,
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

          CircleAvatar(

            radius: 24,

            backgroundColor:
                isPresent
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),

            child: Icon(

              isPresent
                  ? Icons.check
                  : Icons.close,

              color:
                  isPresent
                      ? Colors.green
                      : Colors.red,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  subject,

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  date,

                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            status,

            style: TextStyle(
              color:
                  isPresent
                      ? Colors.green
                      : Colors.red,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}