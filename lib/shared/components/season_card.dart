import 'package:flutter/material.dart';
import '../../data/models/enhanced_farmer_profile.dart';

/// Season indicator card showing current farming season
class SeasonCard extends StatelessWidget {
  final String? seasonText;
  final String? activeText;

  const SeasonCard({
    super.key,
    this.seasonText,
    this.activeText,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final seasonDisplay = SeasonHelper.getLocalizedSeasonDisplay(langCode);
    final isKharif = SeasonHelper.getCurrentSeasonName() == 'Kharif';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isKharif
              ? [const Color(0xFF00897B), const Color(0xFF26A69A)]
              : [const Color(0xFF5D4037), const Color(0xFF8D6E63)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isKharif ? const Color(0xFF00897B) : const Color(0xFF5D4037))
                .withValues(alpha :0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha :0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isKharif ? Icons.water_drop_rounded : Icons.ac_unit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seasonText ?? 'Current Season',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha :0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seasonDisplay,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha :0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activeText ?? 'Active',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

