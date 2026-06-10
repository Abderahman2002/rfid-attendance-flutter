// =============================================
// lib/widgets/admin_stat_card.dart
// =============================================

import 'package:flutter/material.dart';

class AdminStatCard extends StatelessWidget {
  final String   title;
  final String   value;
  final IconData icon;
  final Color    color;
  final Color    bgColor;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      color.withOpacity(0.10),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,   // ← fix overflow
        children: [
          // ── Icône ──
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          // ── Valeur ──
          FittedBox(                        // ← s'adapte à la taille
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize:   26,
                fontWeight: FontWeight.w800,
                color:      color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // ── Titre ──
          Text(
            title,
            style: const TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w500,
              color:      Color(0xFF6B7280),
            ),
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
