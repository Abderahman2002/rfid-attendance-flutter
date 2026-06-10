import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String token;
  const TeacherDashboard({super.key, required this.token});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {

  static const Color _blue  = Color(0xFF0039CB);
  static const Color _bg    = Color(0xFFF0F4FF);
  static const Color _white = Colors.white;

  bool   _loading = true;
  String _error   = "";
  Timer? _timer;

  Map<String, dynamic>       _teacher  = {};
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _schedule = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
    // Auto-refresh toutes les 5 secondes
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_activeSession != null) _loadAll(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final dash     = await ApiService.getTeacherDashboard(widget.token);
      final schedule = await ApiService.getTeacherSchedule(widget.token);
      final profile  = await ApiService.getProfile(widget.token);
      if (mounted) setState(() {
        _teacher  = {
          ...((dash['teacher'] as Map<String, dynamic>?) ?? {}),
          'email':    profile.email,
          'username': profile.username,
        };
        _sessions = (dash['sessions'] as List? ?? []).cast<Map<String, dynamic>>();
        _schedule = schedule.cast<Map<String, dynamic>>();
        _loading  = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Session active ──
  Map<String, dynamic>? get _activeSession =>
      _sessions.where((s) => s['is_active'] == true).isNotEmpty
          ? _sessions.firstWhere((s) => s['is_active'] == true)
          : null;

  // ── Stats calculées ──
  int get _totalSessions => _sessions.length;
  int get _totalPresent  => _sessions.fold(0, (s, e) => s + ((e['present_count'] ?? 0) as int));
  int get _totalAbsent   => _sessions.fold(0, (s, e) => s + ((e['absent_count'] ?? 0) as int));

  Future<void> _startSession(Map<String, dynamic> slot) async {
    try {
      _showSnack('Lancement du cours...', _blue);
      // Cherche subject_id depuis _teacher
      final subjects = (_teacher['subjects'] as List? ?? []);
      final subjectName = slot['subject'] ?? '';
      int subjectId = 1;
      for (final s in subjects) {
        if (s['name'] == subjectName) {
          subjectId = s['id'] ?? 1;
          break;
        }
      }
      // Cherche classroom_id depuis l'API classrooms
      final classrooms = await ApiService.getClassrooms(widget.token);
      final classroomName = slot['classroom'] ?? '';
      int classroomId = 1;
      for (final c in classrooms) {
        if (c['name'] == classroomName || c['room_number'] == classroomName) {
          classroomId = c['id'] ?? 1;
          break;
        }
      }
      final result = await ApiService.startSession(
        widget.token,
        subjectId,
        classroomId,
        slot['start_time'] ?? '08:00',
        slot['end_time']   ?? '10:00',
      );
      // ── Envoie WebHook au scanner NFC ──
      try {
        await http.post(
          Uri.parse('http://192.168.0.124:5000/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'event':    'session_started',
            'username': _teacher['username'] ?? '',
            'token':    widget.token,
            'teacher':  _teacher['full_name'] ?? '',
            'subject':  slot['subject'] ?? '',
            'session_id': result['session_id'],
          }),
        );
        print('✅ WebHook envoyé au scanner NFC');
      } catch (e) {
        print('⚠️ WebHook erreur: $e');
      }
      _showSnack('✅ Cours lancé !', Colors.green);
      _loadAll();
    } catch (e) {
      _showSnack('Erreur: $e', Colors.red);
    }
  }

  Future<void> _stopSession() async {
    try {
      _showSnack('Arrêt du cours...', Colors.orange);
      await ApiService.endSession(widget.token);
      // ── Envoie WebHook stop au scanner NFC ──
      try {
        await http.post(
          Uri.parse('http://192.168.0.124:5000/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'event':    'session_ended',
            'username': _teacher['username'] ?? '',
            'token':    widget.token,
            'teacher':  _teacher['full_name'] ?? '',
          }),
        );
      } catch (e) {
        print('⚠️ WebHook stop erreur: $e');
      }
      _showSnack('✅ Cours terminé !', const Color(0xFF16A34A));
      _loadAll();
    } catch (e) {
      _showSnack('Erreur: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    }
  }

  bool _canStartNow(Map<String, dynamic> slot) {
    try {
      final now    = TimeOfDay.now();
      final parts  = (slot['start_time'] as String).split(':');
      final start  = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final totalNow   = now.hour * 60 + now.minute;
      final totalStart = start.hour * 60 + start.minute;
      return (totalNow >= totalStart - 15) && (totalNow <= totalStart + 120);
    } catch (_) { return true; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0039CB)))
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : Column(children: [
                  _buildHeader(),
                  _buildTabs(),
                  Expanded(child: TabBarView(
                    controller: _tabController,
                    children: [_buildDashboard(), _buildSchedule()],
                  )),
                ]),
    );
  }

  Widget _buildHeader() {
    final subjects = (_teacher['subjects'] as List? ?? []);
    final subject  = subjects.isNotEmpty ? subjects[0]['name'] ?? '' : '';
    return Container(
      color: _blue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 16),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: _white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.person, color: _white, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_teacher['full_name'] ?? 'Professeur',
              style: const TextStyle(color: _white,
                  fontSize: 18, fontWeight: FontWeight.w800)),
          Text(subject,
              style: TextStyle(color: _white.withOpacity(0.8), fontSize: 13)),
        ])),
        IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => _TeacherProfilePage(
                  token: widget.token,
                  teacher: _teacher,
                  totalSessions: _totalSessions,
                  totalPresent: _totalPresent,
                  totalAbsent: _totalAbsent,
                ))),
            icon: const Icon(Icons.person_outline, color: _white)),
        IconButton(onPressed: _logout,
            icon: const Icon(Icons.logout, color: _white)),
      ]),
    );
  }

  void _showProfile() {
    final subjects = (_teacher['subjects'] as List? ?? []);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4))),
          Container(width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0039CB), Color(0xFF1565C0)]),
              borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.person, color: Colors.white, size: 40)),
          const SizedBox(height: 16),
          Text(_teacher['full_name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(_teacher['email'] ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10)),
            child: const Text('Professeur',
                style: TextStyle(color: Color(0xFF0039CB),
                    fontWeight: FontWeight.w700, fontSize: 13))),
          const SizedBox(height: 20),
          ...subjects.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.book_outlined, color: Color(0xFF0039CB)),
              const SizedBox(width: 12),
              Text(s['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ]))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); _logout(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Se déconnecter',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)))),
          const SizedBox(height: 8),
        ])),
      )));
  }

  Widget _profileStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ]),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: _blue,
      child: TabBar(
        controller: _tabController,
        labelColor: _white,
        unselectedLabelColor: _white.withOpacity(0.6),
        indicatorColor: _white,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Tableau de Bord'),
          Tab(text: 'Mon Planning'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final active   = _activeSession;
    final sessions = _sessions.take(10).toList();

    return RefreshIndicator(
      onRefresh: _loadAll, color: _blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Cours actif ──
          if (active != null) ...[
            _buildActiveSessionCard(active),
            const SizedBox(height: 20),
          ],

          // ── Stats ──
          Row(children: [
            Expanded(child: _statCard('Sessions', '$_totalSessions',
                Icons.calendar_today, _blue, const Color(0xFFDBEAFE))),
            const SizedBox(width: 14),
            Expanded(child: _statCard('Présences', '$_totalPresent',
                Icons.check_circle, Colors.green, const Color(0xFFDCFCE7))),
            const SizedBox(width: 14),
            Expanded(child: _statCard('Absences', '$_totalAbsent',
                Icons.cancel, Colors.red, const Color(0xFFFEE2E2))),
          ]),
          const SizedBox(height: 24),

          // ── Sessions récentes ──
          const Text('Sessions récentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 14),
          if (sessions.isEmpty)
            Container(padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Aucune session',
                  style: TextStyle(color: Color(0xFF9CA3AF)))))
          else
            ...sessions.map((s) => _sessionCard(s)),
        ]),
      ),
    );
  }

  Widget _buildActiveSessionCard(Map<String, dynamic> active) {
    final present = active['present_count'] ?? 0;
    final absent  = active['absent_count'] ?? 0;
    final total   = active['students_count'] ?? 0;
    final attendances = (active['attendances'] as List? ?? []);
    bool _showList = false;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
              blurRadius: 12, offset: const Offset(0,4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(active['subject'] ?? '',
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Text('EN COURS',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 12))),
              ]),
              const SizedBox(height: 8),
              _buildTimeStatus(active),
              const SizedBox(height: 12),
              _infoRow(Icons.person_outline, active['teacher'] ?? ''),
              const SizedBox(height: 6),
              _infoRow(Icons.location_on_outlined, active['classroom'] ?? ''),
              const SizedBox(height: 6),
              _infoRow(Icons.calendar_today_outlined, active['date'] ?? ''),
              const SizedBox(height: 6),
              _infoRow(Icons.access_time,
                  '${active['start_time']?.toString().substring(0,5)} → ${active['end_time']?.toString().substring(0,5)}'),
              const SizedBox(height: 16),
              // ── Present / Absent cards ──
              Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    Text('$present', style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800, color: Colors.green)),
                    const Text('Present', style: TextStyle(
                        fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600)),
                  ]))),
                const SizedBox(width: 12),
                Expanded(child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text('$absent', style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800, color: Colors.red)),
                    const Text('Absent', style: TextStyle(
                        fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600)),
                  ]))),
              ]),
              const SizedBox(height: 12),
              // ── Attendance List toggle ──
              GestureDetector(
                onTap: () => setState(() => _showList = !_showList),
                child: Row(children: [
                  const Icon(Icons.people_outline, color: Color(0xFF0039CB), size: 20),
                  const SizedBox(width: 8),
                  const Text('Attendance List',
                      style: TextStyle(color: Color(0xFF0039CB),
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const Spacer(),
                  Icon(_showList ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF0039CB)),
                ])),
              if (_showList) ...[
                const SizedBox(height: 10),
                ...attendances.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(a['status'] == 'present' ? Icons.check_circle : Icons.cancel,
                        color: a['status'] == 'present' ? Colors.green : Colors.red,
                        size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a['student'] ?? '',
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a['status'] == 'present'
                            ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        a['status'] == 'present' ? 'Présent' : 'Absent',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: a['status'] == 'present' ? Colors.green : Colors.red))),
                  ]))),
              ],
              const SizedBox(height: 16),
              // ── Terminer ──
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _stopSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.stop_circle, color: Colors.white),
                  label: const Text('Terminer le cours',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)))),
            ]),
          ),
        ]),
      ));
  }

  Widget _buildTimeStatus(Map<String, dynamic> active) {
    try {
      final endParts = (active['end_time'] as String).substring(0,5).split(':');
      final endHour  = int.parse(endParts[0]);
      final endMin   = int.parse(endParts[1]);
      final now      = TimeOfDay.now();
      final endTotal = endHour * 60 + endMin;
      final nowTotal = now.hour * 60 + now.minute;
      final diff     = endTotal - nowTotal;

      if (diff <= 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade200)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.timer_off, color: Colors.red.shade600, size: 16),
            const SizedBox(width: 6),
            Text('Temps terminé — Veuillez terminer le cours',
                style: TextStyle(color: Colors.red.shade600,
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ]));
      } else {
        final h = diff ~/ 60;
        final m = diff % 60;
        final timeStr = h > 0 ? '${h}h ${m}min restantes' : '${m} min restantes';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer, color: Colors.green, size: 16),
            const SizedBox(width: 6),
            Text('⏱️ $timeStr',
                style: const TextStyle(color: Colors.green,
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ]));
      }
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF6B7280)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
    ]);
  }

  Widget _buildSchedule() {
    return RefreshIndicator(
      onRefresh: _loadAll, color: _blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Mon Planning',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 14),
          if (_schedule.isEmpty)
            Container(padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Aucun cours planifié',
                  style: TextStyle(color: Color(0xFF9CA3AF)))))
          else
            ..._schedule.map((slot) => _scheduleCard(slot)),
        ]),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon,
      Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0,3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: bg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.w800, color: color)),
        Text(title, style: const TextStyle(
            fontSize: 12, color: Color(0xFF6B7280))),
      ]),
    );
  }

  Widget _sessionCard(Map<String, dynamic> s) {
    final isActive = s['is_active'] == true;
    final present  = s['present_count'] ?? 0;
    final absent   = s['absent_count'] ?? 0;
    final total    = s['students_count'] ?? 0;
    final rate     = total > 0 ? (present / total * 100).toStringAsFixed(0) : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isActive ? Colors.green.shade300 : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0,2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(s['subject'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8)),
            child: Text(isActive ? '● EN COURS' : '● Terminée',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: isActive ? Colors.green : Colors.grey))),
        ]),
        const SizedBox(height: 6),
        Text('📍 ${s['classroom']}  •  📅 ${s['date']}  •  '
            '⏰ ${s['start_time']?.toString().substring(0,5)} → '
            '${s['end_time']?.toString().substring(0,5)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 8),
        Row(children: [
          _chip('✅ $present', Colors.green),
          const SizedBox(width: 6),
          _chip('❌ $absent', Colors.red),
          const SizedBox(width: 6),
          _chip('👥 $total', _blue),
          const Spacer(),
          Text('$rate%', style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15,
              color: int.parse(rate) >= 75 ? Colors.green
                  : int.parse(rate) >= 50 ? Colors.orange : Colors.red)),
        ]),
      ]),
    );
  }

  Widget _scheduleCard(Map<String, dynamic> slot) {
    final canStart = _activeSession == null && _canStartNow(slot);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0,3))]),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.class_, color: Color(0xFF0039CB))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(slot['subject'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text('${slot['day']}  •  '
              '${slot['start_time']?.toString().substring(0,5)} → '
              '${slot['end_time']?.toString().substring(0,5)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text('📍 Salle ${slot['classroom']}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ])),
        if (canStart)
          SizedBox(
            width: 100,
            child: ElevatedButton.icon(
              onPressed: () => _startSession(slot),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
              label: const Text('Lancer', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))),
      ]),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11,
          color: color, fontWeight: FontWeight.w700)));
  }
}


// ═══════════════════════════════════════════════════
// PAGE PROFIL PROFESSEUR
// ═══════════════════════════════════════════════════
class _TeacherProfilePage extends StatelessWidget {
  final String token;
  final Map<String, dynamic> teacher;
  final int totalSessions;
  final int totalPresent;
  final int totalAbsent;

  const _TeacherProfilePage({
    required this.token,
    required this.teacher,
    required this.totalSessions,
    required this.totalPresent,
    required this.totalAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = (teacher['subjects'] as List? ?? []);
    final initials = (teacher['full_name'] ?? 'P')
        .split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0039CB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mon Profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header bleu ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0039CB), Color(0xFF1565C0)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white,
                child: Text(initials,
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800, color: Color(0xFF0039CB)))),
              const SizedBox(height: 14),
              Text(teacher['full_name'] ?? '',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: const Text('Professeur',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _infoCard(Icons.person_outline, "Nom d'utilisateur",
                  teacher['username'] ?? ''),
              const SizedBox(height: 12),
              _infoCard(Icons.email_outlined, 'Email',
                  teacher['email'] ?? ''),
              const SizedBox(height: 12),
              ...subjects.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _infoCard(Icons.book_outlined, 'Matière', s['name'] ?? ''),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Se déconnecter',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)))),
              const SizedBox(height: 24),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
              color: const Color(0xFF0039CB),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12,
              color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        ]),
      ]),
    );
  }
}