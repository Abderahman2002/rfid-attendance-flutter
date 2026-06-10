import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  bool isLoading       = false;
  final AuthService authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController  = TextEditingController();

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Veuillez remplir tous les champs")));
      return;
    }
    setState(() => isLoading = true);
    final result = await authService.login(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (result['success'] == true) {
      final String role  = result['role']  ?? '';
      final String token = result['token'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role',  role);
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else if (role == 'teacher') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => TeacherDashboard(token: token)));
      } else {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => StudentDashboard(token: token)));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(result['message'] ?? "Identifiants incorrects")));
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0039CB), Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.wifi_tethering_rounded,
                        color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text("Système de Présence RFID",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text("Gestion intelligente de présence universitaire",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14,
                          color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 40),

                  // ── Carte formulaire ──
                  Container(
                    width: 420,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2),
                            blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Connexion",
                            style: TextStyle(fontSize: 24,
                                fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                        const SizedBox(height: 6),
                        Text("Entrez vos identifiants",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        const SizedBox(height: 28),

                        // ── Username ──
                        const Text("Nom d'utilisateur",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: "Entrez votre username",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Color(0xFF0039CB)),
                            filled: true, fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0039CB), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Password ──
                        const Text("Mot de passe",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Entrez votre mot de passe",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Color(0xFF0039CB)),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword),
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade500)),
                            filled: true, fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0039CB), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Bouton ──
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0039CB),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text("Se connecter",
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),


                  const SizedBox(height: 24),
                  Text("© 2026 Système RFID",
                      style: TextStyle(fontSize: 12,
                          color: Colors.white.withOpacity(0.5))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w700, fontSize: 13)),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7),
            fontSize: 11)),
      ]),
    );
  }
}