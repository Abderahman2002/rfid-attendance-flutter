import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {

  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: const Color(0xFFEFF4FF),

        borderRadius: BorderRadius.circular(20),
      ),

      child: const Row(

        children: [

          Icon(
            Icons.notifications,
            color: Colors.blue,
            size: 30,
          ),

          SizedBox(width: 15),

          Expanded(

            child: Text(
              "Pensez à être présent à toutes vos séances.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
            size: 18,
          ),
        ],
      ),
    );
  }
}