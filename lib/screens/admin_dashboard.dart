import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../utils/pdf_download.dart';
import '../services/admin_service.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_action_card.dart';
import '../widgets/active_session_card.dart';
import '../widgets/recent_session_card.dart';
import '../widgets/user_tile.dart';
import '../widgets/teacher_stat_card.dart';
import '../widgets/student_attendance_tile.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {

  static const Color _sidebar = Color(0xFF0B5ED7);
  static const Color _btn     = Color(0xFF0D6EFD);
  static const Color _bg      = Color(0xFFF0F4FF);
  static const Color _white   = Colors.white;

  DashboardStats?             _stats;
  List<StudentUser>           _students     = [];
  List<SessionInfo>           _sessions     = [];
  List<StudentAttendanceStat> _studentsStats = [];
  Map<String, dynamic>        _profile      = {};
  bool _loading     = true;
  int  _notifCount  = 0;

  List<Map<String, dynamic>> _subjectStats    = [];
  List<Map<String, dynamic>> _specialityStats = [];
  DateTime? _dateDebut;
  DateTime? _dateFin;
  Map<String, dynamic>? _filterResult;
  bool _filterLoading = false;

  List<Map<String, dynamic>> _schedules    = [];
  bool                       _scheduleLoad = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getStudents(),
        AdminService.getSessions(),
        AdminService.getProfile(),
        AdminService.getStudentsStats(),
      ]);
      setState(() {
        _stats         = results[0] as DashboardStats;
        _students      = results[1] as List<StudentUser>;
        _sessions      = results[2] as List<SessionInfo>;
        _profile       = results[3] as Map<String, dynamic>;
        _studentsStats = results[4] as List<StudentAttendanceStat>;
        _notifCount    = _sessions.where((s) => s.isActive).length;
        _loading       = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) _showSnack('Erreur chargement: $e', Colors.red);
    }
    _loadSubjectStats();
  }

  Future<void> _downloadPdf() async {
    try {
      _showSnack('Génération du PDF...', _btn);
      final bytes = await AdminService.downloadAttendancePdf();
      await downloadPdfBytes(bytes, 'rapport_admin.pdf');
      _showSnack('PDF téléchargé ✅', const Color(0xFF16A34A));
    } catch (e) {
      _showSnack('Erreur PDF: $e', Colors.red);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AdminService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _loadSubjectStats() async {
    try {
      final s  = await AdminService.getStatsBySubject();
      final sp = await AdminService.getStatsBySpeciality();
      setState(() { _subjectStats = s; _specialityStats = sp; });
    } catch (_) {}
  }

  Future<void> _applyFilter() async {
    setState(() => _filterLoading = true);
    try {
      final debut = _dateDebut != null
          ? '${_dateDebut!.year}-${_dateDebut!.month.toString().padLeft(2,'0')}-${_dateDebut!.day.toString().padLeft(2,'0')}' : null;
      final fin = _dateFin != null
          ? '${_dateFin!.year}-${_dateFin!.month.toString().padLeft(2,'0')}-${_dateFin!.day.toString().padLeft(2,'0')}' : null;
      final result = await AdminService.filterByDate(dateDebut: debut, dateFin: fin);
      setState(() { _filterResult = result; _filterLoading = false; });
      _showFilterResultModal();
    } catch (e) {
      setState(() => _filterLoading = false);
      _showSnack('Erreur filtre: $e', Colors.red);
    }
  }

  void _showFilterResultModal() {
    if (_filterResult == null) return;
    final sessions = (_filterResult!['sessions'] as List? ?? []).cast<Map<String,dynamic>>();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.90, maxChildSize: 0.95, minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(color: Color(0xFFF0F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(children: [
            _sheetHandle(),
            Padding(padding: const EdgeInsets.fromLTRB(20,16,20,8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Résultats du filtre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  _filterChip('✅ ${_filterResult!['present']} Présents', const Color(0xFF16A34A)),
                  _filterChip('❌ ${_filterResult!['absent']} Absents', Colors.red),
                  _filterChip('📊 ${_filterResult!['rate']}%', _btn),
                ]),
              ])),
            Expanded(child: sessions.isEmpty
              ? const Center(child: Text('Aucune séance pour cette période'))
              : ListView.builder(
                  controller: ctrl, padding: const EdgeInsets.fromLTRB(20,8,20,20),
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('👤 ${s['teacher']}  📍 ${s['classroom']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text('📅 ${s['date']}  ⏰ ${s['start_time']?.toString().substring(0,5)} → ${s['end_time']?.toString().substring(0,5)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, children: [
                          _filterChip('✅ ${s['present']}', const Color(0xFF16A34A)),
                          _filterChip('❌ ${s['absent']}', Colors.red),
                          _filterChip('📊 ${s['rate']}%', _btn),
                        ]),
                      ]),
                    );
                  })),
          ]),
        ),
      ),
    );
  }

  Widget _filterChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  void _showSubjectStatsModal() {
    if (_subjectStats.isEmpty) { _loadSubjectStats().then((_) => _showSubjectStatsModal()); return; }
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _buildDraggableSheet(
        title: 'Stats par Matière', icon: Icons.book_outlined, color: _btn,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _subjectStats.length,
          itemBuilder: (_, i) {
            final s = _subjectStats[i];
            final rate = (s['rate'] ?? 0).toDouble();
            final color = rate >= 70 ? const Color(0xFF16A34A) : rate >= 50 ? Colors.orange : Colors.red;
            return Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  Text('${rate.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                ]),
                const SizedBox(height: 4),
                Text('${s['sessions_count']} sessions  •  ✅ ${s['present']} présents  •  ❌ ${s['absent']} absents',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: rate/100, backgroundColor: Colors.grey.shade200, color: color, minHeight: 8)),
              ]),
            );
          },
        ),
      ),
    );
  }

  void _showSpecialityStatsModal() {
    if (_specialityStats.isEmpty) { _loadSubjectStats().then((_) => _showSpecialityStatsModal()); return; }
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _buildDraggableSheet(
        title: 'Stats par Spécialité', icon: Icons.school_outlined, color: const Color(0xFF7C3AED),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _specialityStats.length,
          itemBuilder: (_, i) {
            final s = _specialityStats[i];
            final rate = (s['rate'] ?? 0).toDouble();
            final color = rate >= 70 ? const Color(0xFF16A34A) : rate >= 50 ? Colors.orange : Colors.red;
            return Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  Text('${rate.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                ]),
                const SizedBox(height: 4),
                Text('${s['students']} étudiants  •  ✅ ${s['present']}  •  ❌ ${s['absent']}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: rate/100, backgroundColor: Colors.grey.shade200, color: color, minHeight: 8)),
              ]),
            );
          },
        ),
      ),
    );
  }

  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final matricCtrl = TextEditingController();
    String speciality = 'INFO';
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sheetHandle(), const SizedBox(height: 16),
              const Text('Ajouter un Étudiant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _formField(nameCtrl, 'Nom complet', Icons.person),
              const SizedBox(height: 12),
              _formField(userCtrl, 'Username', Icons.account_circle),
              const SizedBox(height: 12),
              _formField(passCtrl, 'Mot de passe', Icons.lock, obscure: true),
              const SizedBox(height: 12),
              _formField(matricCtrl, 'Matricule', Icons.badge),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: speciality,
                decoration: InputDecoration(labelText: 'Spécialité', prefixIcon: const Icon(Icons.school),
                  filled: true, fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                items: ['INFO','DEVELOPMENT','RESEAUX','SECURITE']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => speciality = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _btn,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    try {
                      await AdminService.addStudent(fullName: nameCtrl.text.trim(),
                        username: userCtrl.text.trim(), password: passCtrl.text.trim(),
                        matricule: matricCtrl.text.trim(), speciality: speciality);
                      if (mounted) { Navigator.pop(context); _showSnack('Étudiant ajouté ✅', const Color(0xFF16A34A)); _loadAll(); }
                    } catch (e) { _showSnack('Erreur: $e', Colors.red); }
                  },
                  child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  void _showAddTeacherModal() {
    final nameCtrl    = TextEditingController();
    final userCtrl    = TextEditingController();
    final passCtrl    = TextEditingController();
    final subjectCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sheetHandle(), const SizedBox(height: 16),
            const Text('Ajouter un Professeur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _formField(nameCtrl, 'Nom complet', Icons.person),
            const SizedBox(height: 12),
            _formField(userCtrl, 'Username', Icons.account_circle),
            const SizedBox(height: 12),
            _formField(passCtrl, 'Mot de passe', Icons.lock, obscure: true),
            const SizedBox(height: 12),
            _formField(subjectCtrl, 'Matière', Icons.book),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async {
                  try {
                    await AdminService.addTeacher(fullName: nameCtrl.text.trim(),
                      username: userCtrl.text.trim(), password: passCtrl.text.trim(),
                      subject: subjectCtrl.text.trim());
                    if (mounted) { Navigator.pop(context); _showSnack('Professeur ajouté ✅', const Color(0xFF16A34A)); _loadAll(); }
                  } catch (e) { _showSnack('Erreur: $e', Colors.red); }
                },
                child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {bool obscure = false}) {
    return TextField(controller: ctrl, obscureText: obscure,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: _btn),
        filled: true, fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Future<void> _loadSchedules() async {
    setState(() => _scheduleLoad = true);
    try {
      final data = await AdminService.getSchedules();
      setState(() { _schedules = data; _scheduleLoad = false; });
    } catch (_) { setState(() => _scheduleLoad = false); }
  }

  void _showScheduleModal() {
    _loadSchedules();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.90, maxChildSize: 0.95, minChildSize: 0.5,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(color: Color(0xFFF0F4FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(children: [
              _sheetHandle(),
              Padding(padding: const EdgeInsets.fromLTRB(20,16,20,8),
                child: Row(children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF0039CB)),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Planning des Professeurs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  IconButton(
                    onPressed: () { Navigator.pop(context); _showAddScheduleModal(); },
                    icon: Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFF0039CB), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, color: Colors.white, size: 18))),
                ])),
              Expanded(child: _scheduleLoad
                ? const Center(child: CircularProgressIndicator())
                : _schedules.isEmpty ? const Center(child: Text('Aucun planning défini'))
                : ListView.builder(
                    controller: ctrl, padding: const EdgeInsets.fromLTRB(20,8,20,20),
                    itemCount: _schedules.length,
                    itemBuilder: (_, i) {
                      final t = _schedules[i];
                      final schedule = (t['schedule'] as List? ?? []).cast<Map<String,dynamic>>();
                      if (schedule.isEmpty) return const SizedBox();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            CircleAvatar(backgroundColor: const Color(0xFFDBEAFE),
                              child: Text(
                                (t['full_name'] as String).isNotEmpty
                                    ? (t['full_name'] as String).split(' ').map((e) => e[0]).take(2).join() : '?',
                                style: const TextStyle(color: Color(0xFF0039CB), fontWeight: FontWeight.w700))),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(t['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(t['subject'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            ])),
                          ]),
                          const SizedBox(height: 10),
                          ...schedule.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFF0039CB).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text(s['day'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF0039CB), fontWeight: FontWeight.w700))),
                                const SizedBox(width: 8),
                                Expanded(child: Row(children: [
                                  const Icon(Icons.alarm, size: 12, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Flexible(child: Text('${s['start_time']} → ${s['end_time']}',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis)),
                                ])),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await AdminService.deleteSchedule(username: t['username'], scheduleId: s['id']);
                                      _loadSchedules();
                                      _showSnack('Cours supprimé ✅', const Color(0xFF16A34A));
                                    } catch (e) { _showSnack('Erreur: $e', Colors.red); }
                                  },
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 18)),
                              ]),
                              const SizedBox(height: 2),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text('📍 Salle ${s['classroom']}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            ]),
                          )),
                        ]),
                      );
                    })),
            ]),
          ),
        ),
      ),
    );
  }

  // ✅ CORRIGÉ — le bouton "Ajouter" est désormais toujours accessible.
  // Le modal a une hauteur maximale fixée (constraints), et le contenu scrollable
  // est lui-même contraint à l'intérieur de cette hauteur (ConstrainedBox),
  // donc le SingleChildScrollView peut toujours défiler jusqu'au bouton.
  void _showAddScheduleModal() {
    String? selectedUsername;
    String? selectedDay;
    String? selectedClassroom;
    final startCtrl = TextEditingController();
    final endCtrl   = TextEditingController();
    final days       = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    final classrooms = ['C301','B201','A102','A101','SALL3','SALL7','AMPHI'];
    if (_schedules.isEmpty) _loadSchedules();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setS) => Container(
            decoration: const BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9
                    - MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sheetHandle(), const SizedBox(height: 16),
                  const Text('Ajouter un cours au planning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(value: selectedUsername,
                    decoration: InputDecoration(labelText: 'Professeur', prefixIcon: const Icon(Icons.person),
                      filled: true, fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: _schedules.map((t) => DropdownMenuItem<String>(
                      value: t['username'] as String,
                      child: Text('${t['full_name']} — ${t['subject']}', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setS(() => selectedUsername = v)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(value: selectedDay,
                    decoration: InputDecoration(labelText: 'Jour', prefixIcon: const Icon(Icons.calendar_today),
                      filled: true, fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setS(() => selectedDay = v)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        final h = picked.hour.toString().padLeft(2, '0');
                        final m = picked.minute.toString().padLeft(2, '0');
                        startCtrl.text = h + ':' + m;
                        setS(() {});
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: startCtrl,
                        decoration: InputDecoration(
                          labelText: startCtrl.text.isEmpty ? 'Heure début' : startCtrl.text,
                          prefixIcon: const Icon(Icons.alarm, color: Color(0xFF0039CB)),
                          filled: true, fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 10, minute: 0),
                      );
                      if (picked != null) {
                        final h = picked.hour.toString().padLeft(2, '0');
                        final m = picked.minute.toString().padLeft(2, '0');
                        endCtrl.text = h + ':' + m;
                        setS(() {});
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: endCtrl,
                        decoration: InputDecoration(
                          labelText: endCtrl.text.isEmpty ? 'Heure fin' : endCtrl.text,
                          prefixIcon: const Icon(Icons.alarm_on, color: Color(0xFF0039CB)),
                          filled: true, fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(value: selectedClassroom,
                    decoration: InputDecoration(labelText: 'Salle', prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0039CB)),
                      filled: true, fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: classrooms.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setS(() => selectedClassroom = v)),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0039CB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        if (selectedUsername == null || selectedDay == null ||
                            startCtrl.text.trim().isEmpty || endCtrl.text.trim().isEmpty || selectedClassroom == null) {
                          _showSnack('Remplissez tous les champs', Colors.red); return;
                        }
                        try {
                          await AdminService.addSchedule(username: selectedUsername!, day: selectedDay!,
                            startTime: startCtrl.text.trim(), endTime: endCtrl.text.trim(), classroom: selectedClassroom!);
                          if (mounted) { Navigator.pop(context); _showSnack('Cours ajouté ✅', const Color(0xFF16A34A)); }
                        } catch (e) { _showSnack('Erreur: $e', Colors.red); }
                      },
                      child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    )),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentsModal() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _buildDraggableSheet(title: 'Étudiants (${_students.length})',
        icon: Icons.people, color: _btn,
        child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _students.length, itemBuilder: (_, i) => UserTile(student: _students[i], index: i))));
  }

  void _showStudentsStatsModal() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _buildDraggableSheet(title: 'Taux de présence', icon: Icons.bar_chart, color: _btn,
        child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _studentsStats.length,
          itemBuilder: (_, i) => StudentAttendanceTile(student: _studentsStats[i], index: i))));
  }

  void _showActiveSessionsModal() {
    final active = _sessions.where((s) => s.isActive).toList();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _buildDraggableSheet(title: 'Cours en direct (${active.length})',
        icon: Icons.cast_for_education, color: const Color(0xFF16A34A),
        child: active.isEmpty
          ? const Center(child: Text('Aucun cours en ce moment', style: TextStyle(color: Color(0xFF9CA3AF))))
          : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: active.length, itemBuilder: (_, i) => ActiveSessionCard(session: active[i]))));
  }

  void _showAllSessionsModal() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.90, maxChildSize: 0.95, minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Color(0xFFF0F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(children: [
            _sheetHandle(),
            Padding(padding: const EdgeInsets.fromLTRB(20,16,20,8),
              child: Row(children: [
                const Icon(Icons.history, color: _btn), const SizedBox(width: 10),
                Expanded(child: Text('Toutes les séances (${_sessions.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
              ])),
            Container(margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: TabBar(controller: _tabController, labelColor: _btn,
                unselectedLabelColor: const Color(0xFF9CA3AF),
                indicator: BoxDecoration(color: _btn.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                tabs: [
                  Tab(text: 'Actives (${_sessions.where((s) => s.isActive).length})'),
                  Tab(text: 'Terminées (${_sessions.where((s) => !s.isActive).length})'),
                ])),
            const SizedBox(height: 8),
            Expanded(child: TabBarView(controller: _tabController, children: [
              _sessionList(controller, _sessions.where((s) => s.isActive).toList()),
              _sessionList(controller, _sessions.where((s) => !s.isActive).toList()),
            ])),
          ]),
        ),
      ));
  }

  Widget _sessionList(ScrollController ctrl, List<SessionInfo> list) {
    if (list.isEmpty) return const Center(child: Text('Aucune séance', style: TextStyle(color: Color(0xFF9CA3AF))));
    return ListView.builder(controller: ctrl, padding: const EdgeInsets.fromLTRB(20,8,20,20),
      itemCount: list.length, itemBuilder: (_, i) => RecentSessionCard(session: list[i]));
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Avatar
            Container(width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_sidebar, _btn],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.admin_panel_settings, color: _white, size: 36)),
            const SizedBox(height: 12),
            // Nom
            Text(_profile['full_name'] ?? 'Admin',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            // Email
            Text(_profile['email'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            // Badge
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)),
              child: const Text('Administrateur',
                  style: TextStyle(color: _btn, fontWeight: FontWeight.w700, fontSize: 12))),
            const SizedBox(height: 24),
            // Bouton déconnecter — bien visible au centre
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(context); _logout(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                icon: const Icon(Icons.logout_rounded, color: _white, size: 20),
                label: const Text('Se déconnecter',
                    style: TextStyle(color: _white, fontWeight: FontWeight.w800, fontSize: 15)))),
            const SizedBox(height: 4),
            // Annuler
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13))),
          ]),
        ),
      ));
  }

  void _showNotifications() {
    final active = _sessions.where((s) => s.isActive).toList();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: _white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: _sheetHandle()), const SizedBox(height: 20),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          if (active.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20),
              child: Text('Aucune notification', style: TextStyle(color: Color(0xFF9CA3AF)))))
          else
            ...active.map((s) => ListTile(
              leading: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.cast_for_education, color: Color(0xFF16A34A), size: 20)),
              title: Text('${s.teacher} a lancé un cours', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${s.subject} • ${s.classroom}', style: const TextStyle(fontSize: 11)),
              contentPadding: EdgeInsets.zero)),
          const SizedBox(height: 8),
        ]),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop      = MediaQuery.of(context).size.width > 800;
    final activeSessions = _sessions.where((s) => s.isActive).toList();
    final recentSessions = _sessions.where((s) => !s.isActive).take(5).toList();
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _btn))
          : isDesktop
              ? _buildDesktopLayout(activeSessions, recentSessions)
              : _buildMobileLayout(activeSessions, recentSessions),
    );
  }

  Widget _buildDesktopLayout(List activeSessions, List recentSessions) {
    return Row(children: [
      Container(width: 260, color: _sidebar,
        child: Column(children: [
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: _white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings, color: _white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_profile['full_name'] ?? 'Admin',
                    style: const TextStyle(color: _white, fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Administrateur', style: TextStyle(color: _white.withOpacity(0.7), fontSize: 11)),
              ])),
            ])),
          const SizedBox(height: 32),
          _sidebarItem(Icons.dashboard, 'Tableau de Bord', true),
          _sidebarItem(Icons.people_outline, 'Étudiants', false, onTap: _showStudentsModal),
          _sidebarItem(Icons.person_outline, 'Professeurs', false, onTap: _showAddTeacherModal),
          _sidebarItem(Icons.calendar_month, 'Planning', false, onTap: _showScheduleModal),
          _sidebarItem(Icons.history, 'Séances', false, onTap: _showAllSessionsModal),
          _sidebarItem(Icons.book_outlined, 'Stats Matières', false, onTap: _showSubjectStatsModal),
          _sidebarItem(Icons.school_outlined, 'Stats Spécialités', false, onTap: _showSpecialityStatsModal),
          _sidebarItem(Icons.picture_as_pdf_outlined, 'Rapport PDF', false, onTap: _downloadPdf),
          const Spacer(),
          _sidebarItem(Icons.logout, 'Déconnexion', false, onTap: _logout, color: Colors.red.shade300),
          const SizedBox(height: 20),
        ])),
      Expanded(child: Column(children: [
        Container(height: 64, color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(children: [
            const Text('Dashboard Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const Spacer(),
            Stack(children: [
              IconButton(onPressed: _showNotifications,
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF374151))),
              if (_notifCount > 0) Positioned(right: 8, top: 8,
                child: Container(width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: Center(child: Text('$_notifCount',
                      style: const TextStyle(color: _white, fontSize: 9, fontWeight: FontWeight.w800))))),
            ]),
            const SizedBox(width: 8),
            GestureDetector(onTap: _showProfileModal,
              child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings, color: Color(0xFF0039CB), size: 20))),
          ])),
        Expanded(child: RefreshIndicator(color: _btn, onRefresh: _loadAll,
          child: SingleChildScrollView(padding: const EdgeInsets.all(28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
                children: [
                  AdminStatCard(title: 'Étudiants', value: '${_stats?.students ?? 0}', icon: Icons.school, color: _btn, bgColor: const Color(0xFFDBEAFE)),
                  AdminStatCard(title: 'Professeurs', value: '${_stats?.teachers ?? 0}', icon: Icons.person_outline, color: const Color(0xFF7C3AED), bgColor: const Color(0xFFEDE9FE)),
                  AdminStatCard(title: 'Séances', value: '${_stats?.sessions ?? 0}', icon: Icons.calendar_today_outlined, color: const Color(0xFF0891B2), bgColor: const Color(0xFFCFFAFE)),
                  AdminStatCard(title: 'Taux Présence', value: '${_stats?.attendanceRate ?? 0}%', icon: Icons.bar_chart, color: const Color(0xFF16A34A), bgColor: const Color(0xFFDCFCE7)),
                ]),
              const SizedBox(height: 24),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _buildAttendanceBar()), const SizedBox(width: 20), Expanded(child: _buildDateFilter()),
              ]),
              const SizedBox(height: 24),
              _sectionTitle('Actions rapides'), const SizedBox(height: 14),
              GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 2.8,
                children: [
                  AdminActionCard(title: 'Voir les étudiants', subtitle: '${_students.length} étudiants', icon: Icons.people_outline, color: _btn, onTap: _showStudentsModal),
                  AdminActionCard(title: 'Taux présence', subtitle: 'Stats par étudiant', icon: Icons.bar_chart, color: const Color(0xFF7C3AED), onTap: _showStudentsStatsModal),
                  AdminActionCard(title: 'Cours en direct', subtitle: '${activeSessions.length} actif(s)', icon: Icons.cast_for_education, color: const Color(0xFF16A34A), onTap: _showActiveSessionsModal),
                  AdminActionCard(title: 'Toutes les séances', subtitle: '${_sessions.length} séances', icon: Icons.history, color: const Color(0xFF0891B2), onTap: _showAllSessionsModal),
                  AdminActionCard(title: 'Stats par Matière', subtitle: 'Taux par matière', icon: Icons.book_outlined, color: const Color(0xFF0891B2), onTap: _showSubjectStatsModal),
                  AdminActionCard(title: 'Stats Spécialité', subtitle: 'INFO, Dev, Réseaux...', icon: Icons.school_outlined, color: const Color(0xFF7C3AED), onTap: _showSpecialityStatsModal),
                  AdminActionCard(title: 'Ajouter Étudiant', subtitle: 'Nouveau compte étudiant', icon: Icons.person_add_outlined, color: const Color(0xFF16A34A), onTap: _showAddStudentModal),
                  AdminActionCard(title: 'Ajouter Professeur', subtitle: 'Nouveau compte professeur', icon: Icons.person_add_alt_outlined, color: const Color(0xFF9333EA), onTap: _showAddTeacherModal),
                  AdminActionCard(title: 'Rapport PDF', subtitle: 'Télécharger le rapport', icon: Icons.picture_as_pdf_outlined, color: const Color(0xFFEA580C), onTap: _downloadPdf),
                ]),
              const SizedBox(height: 24),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (activeSessions.isNotEmpty) Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [_sectionTitle('Cours en ce moment'), const SizedBox(width: 8), _activeBadge(activeSessions.length)]),
                  const SizedBox(height: 14),
                  ...activeSessions.map((s) => ActiveSessionCard(session: s)),
                  if (_stats != null && _stats!.teachersStats.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionTitle('Séances par Professeur'),
                    const SizedBox(height: 14),
                    ..._stats!.teachersStats.asMap().entries
                        .map((e) => TeacherStatCard(teacher: e.value, index: e.key)),
                  ],
                ])),
                if (activeSessions.isNotEmpty) const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _sectionTitle('Séances récentes'),
                    GestureDetector(onTap: _showAllSessionsModal,
                      child: const Text('Voir tout →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _btn))),
                  ]),
                  const SizedBox(height: 14),
                  ...recentSessions.map((s) => RecentSessionCard(session: s)),
                  const SizedBox(height: 24),
                  _sectionTitle('Taux de présence global'),
                  const SizedBox(height: 14),
                  _buildAttendanceBar(),
                ])),
              ]),
              const SizedBox(height: 20),
            ])))),
      ])),
    ]);
  }

  Widget _sidebarItem(IconData icon, String label, bool active, {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? (active ? _white : _white.withOpacity(0.7)), size: 20),
      title: Text(label, style: TextStyle(
          color: color ?? (active ? _white : _white.withOpacity(0.7)),
          fontWeight: active ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
      tileColor: active ? _white.withOpacity(0.15) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap, dense: true,
    );
  }

  Widget _buildMobileLayout(List activeSessions, List recentSessions) {
    return RefreshIndicator(
      color: _btn,
      onRefresh: _loadAll,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 140, pinned: true, backgroundColor: _sidebar, elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_sidebar, Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Dashboard Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _white)),
                    const SizedBox(height: 4),
                    Text('Bienvenue, ${_profile['full_name'] ?? 'Admin'} 👋',
                        style: TextStyle(fontSize: 13, color: _white.withOpacity(0.85))),
                  ]),
                  Row(children: [
                    Stack(children: [
                      IconButton(onPressed: _showNotifications,
                          icon: const Icon(Icons.notifications_outlined, color: _white, size: 26)),
                      if (_notifCount > 0) Positioned(right: 8, top: 8,
                        child: Container(width: 18, height: 18,
                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                          child: Center(child: Text('$_notifCount',
                              style: const TextStyle(color: _white, fontSize: 10, fontWeight: FontWeight.w800))))),
                    ]),
                    GestureDetector(onTap: _showProfileModal,
                      child: Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: _white.withOpacity(0.22), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.admin_panel_settings, color: _white, size: 22))),
                  ]),
                ]),
              )),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1,
              children: [
                AdminStatCard(title: 'Étudiants', value: '${_stats?.students ?? 0}', icon: Icons.school, color: _btn, bgColor: const Color(0xFFDBEAFE)),
                AdminStatCard(title: 'Professeurs', value: '${_stats?.teachers ?? 0}', icon: Icons.person_outline, color: const Color(0xFF7C3AED), bgColor: const Color(0xFFEDE9FE)),
                AdminStatCard(title: 'Séances', value: '${_stats?.sessions ?? 0}', icon: Icons.calendar_today_outlined, color: const Color(0xFF0891B2), bgColor: const Color(0xFFCFFAFE)),
                AdminStatCard(title: 'Taux Présence', value: '${_stats?.attendanceRate ?? 0}%', icon: Icons.bar_chart, color: const Color(0xFF16A34A), bgColor: const Color(0xFFDCFCE7)),
              ]),
            const SizedBox(height: 24),
            _buildAttendanceBar(), const SizedBox(height: 24),
            _buildDateFilter(), const SizedBox(height: 24),
            _sectionTitle('Actions rapides'), const SizedBox(height: 14),
            AdminActionCard(title: 'Voir tous les étudiants', subtitle: '${_students.length} étudiants enregistrés', icon: Icons.people_outline, color: _btn, onTap: _showStudentsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Taux de présence étudiants', subtitle: 'Statistiques par étudiant', icon: Icons.bar_chart, color: const Color(0xFF7C3AED), onTap: _showStudentsStatsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Cours en direct', subtitle: '${activeSessions.length} professeur(s) actif(s)', icon: Icons.cast_for_education, color: const Color(0xFF16A34A), onTap: _showActiveSessionsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Toutes les séances', subtitle: '${_sessions.length} séances au total', icon: Icons.history, color: const Color(0xFF0891B2), onTap: _showAllSessionsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Stats par Matière', subtitle: 'Taux de présence par matière', icon: Icons.book_outlined, color: const Color(0xFF0891B2), onTap: _showSubjectStatsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Stats par Spécialité', subtitle: 'INFO, Development, Réseaux...', icon: Icons.school_outlined, color: const Color(0xFF7C3AED), onTap: _showSpecialityStatsModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Ajouter un Étudiant', subtitle: 'Créer un nouveau compte étudiant', icon: Icons.person_add_outlined, color: const Color(0xFF16A34A), onTap: _showAddStudentModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Ajouter un Professeur', subtitle: 'Créer un nouveau compte professeur', icon: Icons.person_add_alt_outlined, color: const Color(0xFF9333EA), onTap: _showAddTeacherModal),
            const SizedBox(height: 10),
            AdminActionCard(title: '📅 Gérer le Planning', subtitle: 'Définir les horaires des professeurs', icon: Icons.calendar_month, color: const Color(0xFF0039CB), onTap: _showScheduleModal),
            const SizedBox(height: 10),
            AdminActionCard(title: 'Télécharger rapport PDF', subtitle: 'Présence + stats par étudiant et professeur', icon: Icons.picture_as_pdf_outlined, color: const Color(0xFFEA580C), onTap: _downloadPdf),
            const SizedBox(height: 28),
            if (activeSessions.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _sectionTitle('Cours en ce moment'), _activeBadge(activeSessions.length)]),
              const SizedBox(height: 14),
              ...activeSessions.map((s) => ActiveSessionCard(session: s)),
              const SizedBox(height: 20),
            ],
            if (recentSessions.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _sectionTitle('Séances récentes'),
                GestureDetector(onTap: _showAllSessionsModal,
                  child: const Text('Voir tout →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _btn))),
              ]),
              const SizedBox(height: 14),
              ...recentSessions.map((s) => RecentSessionCard(session: s)),
              const SizedBox(height: 20),
            ],
            if (_stats != null && _stats!.teachersStats.isNotEmpty) ...[
              _sectionTitle('Séances par Professeur'), const SizedBox(height: 14),
              ..._stats!.teachersStats.asMap().entries.map((e) => TeacherStatCard(teacher: e.value, index: e.key)),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 20),
          ]),
        )),
      ]),
    );
  }

  Widget _buildDateFilter() {
    String fmtDate(DateTime? d) => d != null
        ? '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}' : 'Choisir';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0,4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Filtrer par période', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _dateDebut ?? DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) setState(() => _dateDebut = d);
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _btn.withOpacity(0.2))),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF0D6EFD)), const SizedBox(width: 6),
                Flexible(child: Text(fmtDate(_dateDebut), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              ])))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('→', style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _dateFin ?? DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) setState(() => _dateFin = d);
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _btn.withOpacity(0.2))),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF0D6EFD)), const SizedBox(width: 6),
                Flexible(child: Text(fmtDate(_dateFin), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              ])))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: _filterLoading ? null : _applyFilter,
            style: ElevatedButton.styleFrom(backgroundColor: _btn,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            icon: _filterLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.search, color: Colors.white, size: 18),
            label: Text(_filterLoading ? 'Chargement...' : 'Filtrer',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          if (_dateDebut != null || _dateFin != null) ...[
            const SizedBox(width: 8),
            IconButton(onPressed: () => setState(() { _dateDebut = null; _dateFin = null; _filterResult = null; }),
                icon: const Icon(Icons.clear, color: Colors.red), tooltip: 'Réinitialiser'),
          ],
        ]),
      ]),
    );
  }

  Widget _buildAttendanceBar() {
    final rate   = _stats?.attendanceRate ?? 0.0;
    final absence = 100 - rate;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0,4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Flexible(child: Text('Taux de présence global',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
          Text('$rate%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 14, child: Row(children: [
            Flexible(flex: rate.toInt().clamp(1,100), child: Container(color: const Color(0xFF16A34A))),
            Flexible(flex: absence.toInt().clamp(1,100), child: Container(color: const Color(0xFFFEE2E2))),
          ]))),
        const SizedBox(height: 12),
        Row(children: [
          _legendDot(const Color(0xFF16A34A), 'Présence  $rate%'),
          const Spacer(),
          _legendDot(const Color(0xFFEF4444), 'Absence  ${absence.toStringAsFixed(1)}%'),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _counterChip('${_stats?.presentCount ?? 0}', 'Présents', const Color(0xFF16A34A)),
          _counterChip('${_stats?.absentCount ?? 0}', 'Absents', const Color(0xFFEF4444)),
          _counterChip('${_stats?.lateCount ?? 0}', 'Retards', Colors.orange),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
    ]);
  }

  Widget _counterChip(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ]);
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)));
  }

  Widget _activeBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
      child: Text('$count actif', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))));
  }

  Widget _buildDraggableSheet({required String title, required IconData icon, required Color color, required Widget child}) {
    return DraggableScrollableSheet(initialChildSize: 0.80, maxChildSize: 0.95, minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(color: Color(0xFFF0F4FF), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          _sheetHandle(),
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,12),
            child: Row(children: [
              Icon(icon, color: color), const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
            ])),
          Expanded(child: child),
        ]),
      ));
  }

  Widget _sheetHandle() {
    return Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)));
  }
}