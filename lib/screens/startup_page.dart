import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 1200),
      checkLogin,
    );
  }

  // =============================================
  // CHECK LOGIN — efface tout et force login
  // =============================================
  Future<void> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    // ── Efface l'ancien token ──
    await prefs.clear();

    if (!mounted) return;

    // ── Toujours aller au login ──
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  // =============================================
  // UI
  // =============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0047FF), Color(0xFF2962FF)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color:      const Color(0xFF0047FF).withOpacity(0.25),
                    blurRadius: 22,
                    offset:     const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: Colors.white,
                size:  80,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "RFID Attendance",
              style: TextStyle(
                fontSize:   30,
                fontWeight: FontWeight.bold,
                color:      Color(0xFF1A237E),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Smart University System",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 40),

            const SizedBox(
              width:  28,
              height: 28,
              child:  CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
