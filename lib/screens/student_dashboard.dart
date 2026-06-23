import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../models/student_dashboard_model.dart';
import '../utils/pdf_download.dart';
import 'profile_page.dart';
import 'student_history.dart';

class StudentDashboard extends StatefulWidget {
  final String token;
  const StudentDashboard({super.key, required this.token});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  bool   loading = true;
  String error   = "";
  Map<String, dynamic> student       = {};
  List<AttendanceItem> attendanceList = [];

  static const Color _blue = Color(0xFF0039CB);
  static const Color _bg   = Color(0xFFF0F4FF);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _historyKey = GlobalKey();
  int _selectedIndex = 0;

  Future<void> fetchDashboard() async {
    try {
      final data = await ApiService.getStudentDashboard(widget.token);
      if (!mounted) return;
      setState(() {
        student = {
          "full_name": data.student.fullName,
          "matricule": data.student.matricule,
        };
        attendanceList = data.recentAttendance;
        loading = false;
        error   = "";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> downloadPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.blue,
            content: Text("Génération du PDF...")));
      
      // ✅ URL corrigée — utilise ApiService.baseUrl
      final url = "${ApiService.baseUrl}/student/report/pdf/";
      print("PDF URL: $url");
      print("TOKEN: ${widget.token}");
      
      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      
      print("PDF STATUS: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        await downloadPdfBytes(res.bodyBytes, "rapport_presence.pdf");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green,
              content: Text("PDF téléchargé ✅")));
      } else {
        throw Exception("Erreur ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,
            content: Text("Erreur PDF: $e")));
    }
  }

  @override
  void initState() { super.initState(); fetchDashboard(); }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get presentCount =>
      attendanceList.where((i) => i.status.toLowerCase() == "present").length;
  int get absentCount =>
      attendanceList.where((i) => i.status.toLowerCase() == "absent").length;
  double get attendanceRate =>
      attendanceList.isEmpty ? 0 : presentCount / attendanceList.length;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        title: const Text("Tableau de Bord Étudiant",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: downloadPdf,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text("Rapport PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProfilePage(token: widget.token))),
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error,
                  style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: fetchDashboard,
                  child: isDesktop ? _buildDesktop() : _buildMobile(),
                ),
    );
  }

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 260,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildStudentCardSidebar(),
              const SizedBox(height: 24),
              _sidebarItem(Icons.dashboard, "Tableau de Bord",
                _selectedIndex == 0, onTap: () {
                  setState(() => _selectedIndex = 0);
                  _scrollController.animateTo(0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
                }),
              _sidebarItem(Icons.history, "Historique",
                _selectedIndex == 1, onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StudentHistory(token: widget.token)));
                }),
              _sidebarItem(Icons.picture_as_pdf, "Rapport PDF",
                _selectedIndex == 3, onTap: () => downloadPdf()),
              _sidebarItem(Icons.person_outline, "Profil",
                _selectedIndex == 2, onTap: () =>
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProfilePage(token: widget.token)))),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _statCardDesktop("Présences", presentCount.toString(),
                        Icons.check_circle, Colors.green, const Color(0xFFDCFCE7)),
                    _statCardDesktop("Absences", absentCount.toString(),
                        Icons.cancel, Colors.red, const Color(0xFFFEE2E2)),
                    _statCardDesktop("Total séances", attendanceList.length.toString(),
                        Icons.calendar_today, _blue, const Color(0xFFDBEAFE)),
                    _statCardDesktop("Taux présence",
                        "${(attendanceRate * 100).toStringAsFixed(0)}%",
                        Icons.bar_chart,
                        attendanceRate >= 0.75 ? Colors.green
                            : attendanceRate >= 0.5 ? Colors.orange : Colors.red,
                        const Color(0xFFDCFCE7)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAttendanceRate(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton.icon(
                            onPressed: downloadPdf,
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: const Text("Télécharger PDF",
                                style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8, offset: const Offset(0,3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Résumé rapide",
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827))),
                              const SizedBox(height: 16),
                              _resumeRow("✅ Présences", "$presentCount", Colors.green),
                              const SizedBox(height: 10),
                              _resumeRow("❌ Absences", "$absentCount", Colors.red),
                              const SizedBox(height: 10),
                              _resumeRow("📚 Total séances", "${attendanceList.length}", const Color(0xFF0039CB)),
                              const SizedBox(height: 10),
                              _resumeRow("📊 Taux", "${(attendanceRate * 100).toStringAsFixed(0)}%",
                                  attendanceRate >= 0.75 ? Colors.green
                                      : attendanceRate >= 0.5 ? Colors.orange : Colors.red),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0039CB).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0039CB).withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("💡 Conseil",
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0039CB))),
                              const SizedBox(height: 10),
                              Text(
                                attendanceRate >= 0.75
                                    ? "🎉 Excellent ! Votre taux de présence est très bon. Continuez ainsi !"
                                    : attendanceRate >= 0.5
                                        ? "⚠️ Attention ! Votre taux est en dessous de 75%. Essayez d'améliorer votre présence."
                                        : "❌ Votre taux de présence est critique. Consultez votre responsable.",
                                style: const TextStyle(fontSize: 12,
                                    color: Color(0xFF374151), height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(width: 20),
                    Expanded(child: _buildHistorySection()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentCard(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProfilePage(token: widget.token))),
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                label: const Text("Mon Profil",
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0039CB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: downloadPdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                label: const Text("Rapport PDF",
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _statCard("Présences", presentCount.toString(),
                Icons.check_circle, Colors.green, const Color(0xFFDCFCE7))),
            const SizedBox(width: 14),
            Expanded(child: _statCard("Absences", absentCount.toString(),
                Icons.cancel, Colors.red, const Color(0xFFFEE2E2))),
          ]),
          const SizedBox(height: 14),
          _statCard("Total des séances", attendanceList.length.toString(),
              Icons.calendar_today, _blue, const Color(0xFFDBEAFE),
              fullWidth: true),
          const SizedBox(height: 20),
          _buildAttendanceRate(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildHistorySection({bool limitItems = false}) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final displayList = (limitItems || isDesktop)
        ? attendanceList.take(5).toList()
        : attendanceList;
    return Column(
      key: _historyKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Historique des Présences",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          if (attendanceList.length > 5)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StudentHistory(token: widget.token))),
              child: const Text("Voir tout →",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF0039CB))),
            ),
        ]),
        const SizedBox(height: 12),
        if (attendanceList.isEmpty)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("Aucun historique de présence",
                style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)))),
          )
        else
          ListView.builder(
            itemCount: displayList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _buildHistoryCard(displayList[index]),
          ),
        if (attendanceList.length > 5) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StudentHistory(token: widget.token))),
              icon: const Icon(Icons.history, size: 18),
              label: Text("Voir tout l'historique (${attendanceList.length} séances)"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0039CB),
                side: const BorderSide(color: Color(0xFF0039CB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStudentCardSidebar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, Color(0xFF1565C0)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.school, color: Colors.white, size: 28)),
        const SizedBox(height: 10),
        Text(student["full_name"] ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white,
                fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text("Matricule : ${student["matricule"] ?? ""}",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ]),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool active,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: active ? _blue : const Color(0xFF9CA3AF)),
      title: Text(label, style: TextStyle(
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? _blue : const Color(0xFF374151),
          fontSize: 14)),
      tileColor: active ? const Color(0xFFDBEAFE) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, Color(0xFF1565C0)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.school, color: Colors.white, size: 32)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(student["full_name"] ?? "",
              style: const TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text("Matricule : ${student["matricule"] ?? ""}",
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: const Text("Étudiant",
                style: TextStyle(color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.w600))),
        ])),
      ]),
    );
  }

  Widget _statCardDesktop(String title, String value, IconData icon,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: bgColor,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 26,
            fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12,
            color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon,
      Color color, Color bgColor, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(width: 48, height: 48,
            decoration: BoxDecoration(color: bgColor,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 26)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 28,
              fontWeight: FontWeight.w800, color: color)),
          Text(title, style: const TextStyle(fontSize: 13,
              color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildAttendanceRate() {
    final rate    = (attendanceRate * 100).toStringAsFixed(0);
    final absence = (100 - attendanceRate * 100).toStringAsFixed(0);
    final color   = attendanceRate >= 0.75 ? Colors.green
        : attendanceRate >= 0.5 ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Taux de présence",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("$rate%", style: TextStyle(fontSize: 32,
              fontWeight: FontWeight.w800, color: color)),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("$presentCount présents",
                style: const TextStyle(fontSize: 12,
                    color: Colors.green, fontWeight: FontWeight.w600)),
            Text("$absentCount absents",
                style: const TextStyle(fontSize: 12,
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: attendanceRate, minHeight: 12,
              backgroundColor: Colors.grey.shade200, color: color)),
        const SizedBox(height: 12),
        Row(children: [
          _dot(Colors.green, "Présent $rate%"),
          const Spacer(),
          _dot(Colors.red, "Absent $absence%"),
        ]),
      ]),
    );
  }

  Widget _dot(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600,
          fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildHistoryCard(AttendanceItem a) {
    final isPresent = a.status.toLowerCase() == "present";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
          width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            color: isPresent ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(isPresent ? Icons.check_circle : Icons.cancel,
              color: isPresent ? Colors.green : Colors.red, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(a.subject, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 3),
          Text("👤 ${a.teacher}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text("📍 Salle ${a.classroom}  •  📅 ${a.date}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPresent ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8)),
          child: Text(isPresent ? "PRÉSENT" : "ABSENT",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
              color: isPresent ? Colors.green.shade700 : Colors.red.shade700))),
      ]),
    );
  }

  Widget _resumeRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}