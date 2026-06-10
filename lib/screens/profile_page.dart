import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({super.key, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool         loading = true;
  ProfileModel? profile;
  String       error   = "";

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiService.getProfile(widget.token);
      if (!mounted) return;
      setState(() { profile = data; loading = false; error = ""; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Déconnexion",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Déconnecter",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0039CB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
          ],
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0039CB),
        foregroundColor: Colors.white,
        title: const Text("Mon Profil",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(error, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16)),
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [

                    // ── Header ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0039CB), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0039CB).withOpacity(0.3),
                              blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Text(
                            profile!.fullName.isNotEmpty
                                ? profile!.fullName[0].toUpperCase() : "?",
                            style: const TextStyle(fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0039CB)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(profile!.fullName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            profile!.role == "student" ? "Étudiant"
                                : profile!.role == "teacher" ? "Professeur"
                                    : "Administrateur",
                            style: const TextStyle(color: Colors.white,
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── Informations ──
                    _infoCard(Icons.person, "Nom d'utilisateur", profile!.username),
                    _infoCard(Icons.email, "Email",
                        profile!.email.isNotEmpty ? profile!.email : "Non renseigné"),

                    // ── Étudiant ──
                    if (profile!.role == "student") ...[
                      _infoCard(Icons.badge, "Matricule", profile!.matricule),
                      _infoCard(Icons.school, "Spécialité", profile!.speciality),
                    ],

                    // ── Professeur ──
                    if (profile!.role == "teacher")
                      _infoCard(Icons.menu_book, "Matières",
                          profile!.subjects.isNotEmpty
                              ? profile!.subjects.join(" • ")
                              : "Aucune matière"),

                    const SizedBox(height: 24),

                    // ── Bouton déconnexion ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Se déconnecter",
                            style: TextStyle(color: Colors.white,
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ]),
                ),
    );
  }
}
