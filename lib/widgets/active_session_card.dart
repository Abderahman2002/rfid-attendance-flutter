// =============================================
// lib/widgets/active_session_card.dart
// =============================================

import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class ActiveSessionCard extends StatelessWidget {
  // ── Pour admin : SessionInfo ──────────────
  final SessionInfo? session;

  // ── Pour teacher : Map + onEnd ────────────
  final Map<String, dynamic>? sessionMap;
  final VoidCallback? onEnd;

  // ── Constructeur admin ────────────────────
  const ActiveSessionCard({
    super.key,
    required this.session,
  })  : sessionMap = null,
        onEnd      = null;

  // ── Constructeur teacher ──────────────────
  const ActiveSessionCard.fromMap({
    super.key,
    required this.sessionMap,
    this.onEnd,
  }) : session = null;

  String _fmt(String t) => t.length >= 5 ? t.substring(0, 5) : '--:--';

  @override
  Widget build(BuildContext context) {
    // ── Récupère les données selon le type ──
    final String subject   = session?.subject
        ?? sessionMap?['subject']   ?? '';
    final String teacher   = session?.teacher
        ?? sessionMap?['teacher']   ?? '';
    final String classroom = session?.classroom
        ?? sessionMap?['classroom'] ?? '';
    final String startTime = session?.startTime
        ?? sessionMap?['start_time'] ?? '';
    final String endTime   = session?.endTime
        ?? sessionMap?['end_time']   ?? '';
    final int present      = session?.presentCount
        ?? sessionMap?['present_count']  ?? 0;
    final int absent       = session?.absentCount
        ?? sessionMap?['absent_count']   ?? 0;
    final int total        = session?.studentsCount
        ?? sessionMap?['students_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     Colors.green.withOpacity(0.28),
            blurRadius: 14,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge EN COURS ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle,
                        color: Colors.greenAccent, size: 9),
                    SizedBox(width: 6),
                    Text(
                      'EN COURS',
                      style: TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:   11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.wifi,
                  color: Colors.greenAccent, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          // ── Matière ──
          Text(
            subject,
            style: const TextStyle(
              color:      Colors.white,
              fontSize:   20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // ── Prof + Salle ──
          Row(
            children: [
              const Icon(Icons.person,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(teacher,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 14),
              const Icon(Icons.location_on,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(classroom,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          // ── Horaire ──
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                '${_fmt(startTime)} → ${_fmt(endTime)}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Chips stats ──
          Row(
            children: [
              _chip('✅ $present Présents', Colors.greenAccent),
              const SizedBox(width: 8),
              _chip('❌ $absent Absents', Colors.redAccent),
              const SizedBox(width: 8),
              _chip('👥 $total Total', Colors.white70),
            ],
          ),
          // ── Bouton End Session (teacher only) ──
          if (onEnd != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEnd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon:  const Icon(Icons.stop_circle_outlined,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Terminer le cours',
                  style: TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:      color,
          fontSize:   11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
