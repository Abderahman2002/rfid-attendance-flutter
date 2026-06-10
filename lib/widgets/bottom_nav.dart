import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          navItem(Icons.home, "Accueil", true),

          navItem(Icons.calendar_month, "Sessions", false),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0057FF),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.wifi_tethering,
              color: Colors.white,
              size: 32,
            ),
          ),

          navItem(Icons.people, "Étudiants", false),

          navItem(Icons.person, "Profil", false),
        ],
      ),
    );
  }

  Widget navItem(
    IconData icon,
    String title,
    bool active,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Icon(
          icon,
          color: active
              ? const Color(0xFF0057FF)
              : Colors.grey,
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            color: active
                ? const Color(0xFF0057FF)
                : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}