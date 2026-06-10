// =============================================
// lib/widgets/recent_session_card.dart
// =============================================
 
import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
 
class RecentSessionCard extends StatelessWidget {
  final SessionInfo session;
 
  const RecentSessionCard({super.key, required this.session});
 
  String _fmtTime(String t) => t.length >= 5 ? t.substring(0, 5) : '--:--';
 
  String _fmtDate(String d) {
    if (d.isEmpty) return '--/--/----';
    final p = d.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : d;
  }
 
  Color _rateColor(double r) =>
      r >= 70 ? const Color(0xFF16A34A) : r >= 50 ? Colors.orange : Colors.red;
 
  @override
  Widget build(BuildContext context) {
    final int    total   = session.studentsCount;
    final int    present = session.presentCount;
    final int    absent  = session.absentCount;
    final double rate    = total > 0 ? (present / total) * 100 : 0;
 
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: session.isActive
            ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Matière + badge ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  _statusBadge(),
                ],
              ),
              const SizedBox(height: 6),
              // ── Prof + Salle ──
              Row(
                children: [
                  const Icon(Icons.person, size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(session.teacher,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on, size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(session.classroom,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              // ── Date + Heure ──
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(_fmtDate(session.date),
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmtTime(session.startTime)} → ${_fmtTime(session.endTime)}',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ── Stats ──
              Row(
                children: [
                  _badge('✅ $present', const Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  _badge('❌ $absent', Colors.red),
                  const SizedBox(width: 6),
                  _badge('👥 $total', const Color(0xFF0D6EFD)),
                  const Spacer(),
                  Text(
                    '${rate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _rateColor(rate),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ── Liste présences dépliable ──
          children: [
            if (session.attendances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune présence enregistrée',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              )
            else ...[
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Liste des présences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...session.attendances.map(_attendanceTile),
            ],
          ],
        ),
      ),
    );
  }
 
  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: session.isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        session.isActive ? '🟢 Active' : '⚫ Terminée',
        style: TextStyle(
          color:      session.isActive ? Colors.green : Colors.grey,
          fontSize:   11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
 
  Widget _attendanceTile(AttendanceInfo a) {
    final Color c = a.status == 'present'
        ? const Color(0xFF16A34A)
        : a.status == 'late'
            ? Colors.orange
            : Colors.red;
    final IconData ic = a.status == 'present'
        ? Icons.check_circle
        : a.status == 'late'
            ? Icons.access_time
            : Icons.cancel;
    final String label = a.status == 'present'
        ? 'Présent'
        : a.status == 'late'
            ? 'Retard'
            : 'Absent';
 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(ic, color: c, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(a.student,
                  style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                  color: c, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}