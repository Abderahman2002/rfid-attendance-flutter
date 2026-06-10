// =============================================
// lib/widgets/teacher_stat_card.dart  (NOUVEAU)
// =============================================

import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class TeacherStatCard extends StatelessWidget {
  final TeacherStat teacher;
  final int         index;

  const TeacherStatCard({
    super.key,
    required this.teacher,
    required this.index,
  });

  Color _rateColor(double r) =>
      r >= 70 ? const Color(0xFF16A34A) : r >= 50 ? Colors.orange : Colors.red;

  @override
  Widget build(BuildContext context) {
    const palette = [
      Color(0xFF0D6EFD),
      Color(0xFF9333EA),
      Color(0xFFEA580C),
      Color(0xFF16A34A),
      Color(0xFF0891B2),
    ];
    final color    = palette[index % palette.length];
    final initials = teacher.fullName.isNotEmpty
        ? teacher.fullName
            .split(' ')
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                color:      color,
                fontWeight: FontWeight.w700,
                fontSize:   15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ── Infos ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.fullName,
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                if (teacher.subjects.isNotEmpty)
                  Text(
                    teacher.subjects.join(' • '),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // ── Barre de présence ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:            teacher.attendanceRate / 100,
                    backgroundColor:  Colors.grey.shade200,
                    color:            _rateColor(teacher.attendanceRate),
                    minHeight:        6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Stats ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sessions
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${teacher.sessionsCount} sessions',
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    color:      color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Taux présence
              Text(
                '${teacher.attendanceRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w800,
                  color:      _rateColor(teacher.attendanceRate),
                ),
              ),
              const Text(
                'présence',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
