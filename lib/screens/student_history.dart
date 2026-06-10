import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student_dashboard_model.dart';
 
class StudentHistory extends StatefulWidget {
  final String token;
  const StudentHistory({super.key, required this.token});
 
  @override
  State<StudentHistory> createState() => _StudentHistoryState();
}
 
class _StudentHistoryState extends State<StudentHistory> {
 
  bool   loading = true;
  String error   = "";
  List<AttendanceItem> allList      = [];
  List<AttendanceItem> filteredList = [];
  String _filter = "Tous"; // Tous | Présent | Absent
 
  static const Color _blue = Color(0xFF0039CB);
 
  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }
 
  Future<void> _fetchHistory() async {
    try {
      final data = await ApiService.getStudentDashboard(widget.token);
      if (!mounted) return;
      setState(() {
        allList      = data.recentAttendance;
        filteredList = data.recentAttendance;
        loading      = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
    }
  }
 
  void _applyFilter(String filter) {
    setState(() {
      _filter = filter;
      if (filter == "Tous") {
        filteredList = allList;
      } else if (filter == "Présent") {
        filteredList = allList
            .where((i) => i.status.toLowerCase() == "present").toList();
      } else {
        filteredList = allList
            .where((i) => i.status.toLowerCase() == "absent").toList();
      }
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final presentCount = allList.where((i) => i.status.toLowerCase() == "present").length;
    final absentCount  = allList.where((i) => i.status.toLowerCase() == "absent").length;
 
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        title: const Text("Historique des Présences",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error,
                  style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  child: Column(
                    children: [
                      // ── Stats rapides ──
                      Container(
                        color: _blue,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(children: [
                          Expanded(child: _quickStat(
                            "${allList.length}", "Total", Colors.white, Colors.white.withOpacity(0.2))),
                          const SizedBox(width: 12),
                          Expanded(child: _quickStat(
                            "$presentCount", "Présences", Colors.green.shade300, const Color(0xFF16A34A).withOpacity(0.2))),
                          const SizedBox(width: 12),
                          Expanded(child: _quickStat(
                            "$absentCount", "Absences", Colors.red.shade300, Colors.red.withOpacity(0.2))),
                        ]),
                      ),
 
                      // ── Filtres ──
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(children: [
                          _filterBtn("Tous", Icons.list),
                          const SizedBox(width: 10),
                          _filterBtn("Présent", Icons.check_circle),
                          const SizedBox(width: 10),
                          _filterBtn("Absent", Icons.cancel),
                        ]),
                      ),
 
                      // ── Liste ──
                      Expanded(
                        child: filteredList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, size: 64,
                                        color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text("Aucun résultat pour $_filter",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF9CA3AF))),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) =>
                                    _buildCard(filteredList[index]),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
 
  Widget _quickStat(String value, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.w800, color: textColor)),
        Text(label, style: TextStyle(fontSize: 12,
            color: textColor.withOpacity(0.8))),
      ]),
    );
  }
 
  Widget _filterBtn(String label, IconData icon) {
    final isActive = _filter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _applyFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _blue : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16,
                color: isActive ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF374151))),
          ]),
        ),
      ),
    );
  }
 
  Widget _buildCard(AttendanceItem a) {
    final isPresent = a.status.toLowerCase() == "present";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
          width: 1),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isPresent
                ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(
            isPresent ? Icons.check_circle : Icons.cancel,
            color: isPresent ? Colors.green : Colors.red, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            color: isPresent
                ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8)),
          child: Text(
            isPresent ? "PRÉSENT" : "ABSENT",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
              color: isPresent
                  ? Colors.green.shade700 : Colors.red.shade700))),
      ]),
    );
  }
}