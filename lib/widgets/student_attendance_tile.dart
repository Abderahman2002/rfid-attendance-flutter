// =============================================
// lib/widgets/student_attendance_tile.dart
// =============================================

import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class StudentAttendanceTile extends StatelessWidget {
  final StudentAttendanceStat student;
  final int                   index;

  const StudentAttendanceTile({
    super.key,
    required this.student,
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
    final initials = student.fullName.isNotEmpty
        ? student.fullName
            .split(' ')
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          // ── Avatar ──
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                color:      color,
                fontWeight: FontWeight.w700,
                fontSize:   13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Nom + Matricule + barre ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.matricule} • ${student.speciality}',
                  style: const TextStyle(
                    fontSize: 10,
                    color:    Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           student.rate / 100,
                    backgroundColor: Colors.grey.shade200,
                    color:           _rateColor(student.rate),
                    minHeight:       5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Taux + compteurs ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${student.rate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w800,
                  color:      _rateColor(student.rate),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _mini('✅ ${student.present}', const Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  _mini('❌ ${student.absent}', Colors.red),
                  if (student.late > 0) ...[
                    const SizedBox(width: 4),
                    _mini('⏰ ${student.late}', Colors.orange),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize:   10,
        fontWeight: FontWeight.w600,
        color:      color,
      ),
    );
  }
}
