import 'package:flutter/material.dart';

/// Step card for numbered instructions/guides
class StepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
  });

  static const List<Color> _defaultColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFFF8F00),
    Color(0xFF7B1FA2),
  ];

  @override
  Widget build(BuildContext context) {
    final stepColor = color ?? _defaultColors[(stepNumber - 1) % _defaultColors.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: stepColor.withValues(alpha :0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [stepColor, stepColor.withValues(alpha :0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: stepColor, size: 22),
        ],
      ),
    );
  }
}

