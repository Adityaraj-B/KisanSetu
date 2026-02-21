import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/headers.dart';
import '../../../shared/components/step_card.dart';

/// Insurance Feature Screen - PMFBY Details
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        title: Text(
          l10n.cropInsurance,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            GradientCard(
              gradientColors: const [Color(0xFF00695C), Color(0xFF00897B)],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha :0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const StatusBadge(text: 'Government Scheme'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.pmFasalBimaYojana,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.comprehensiveCropInsurance,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha :0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const StatDisplay(value: '2%', label: 'Kharif'),
                      const SizedBox(width: 12),
                      const StatDisplay(value: '1.5%', label: 'Rabi'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Benefits Section
            SectionHeader(
              title: l10n.keyBenefits,
              icon: Icons.star_rounded,
              color: const Color(0xFFFF8F00),
            ),
            const SizedBox(height: 16),

            PremiumCard(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.attach_money_rounded,
                    title: l10n.lowPremium,
                    subtitle: l10n.lowPremiumDesc,
                    color: const Color(0xFF2E7D32),
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.security_rounded,
                    title: l10n.wideCoverage,
                    subtitle: l10n.wideCoverageDesc,
                    color: const Color(0xFF1565C0),
                  ),
                  const Divider(height: 24),
                  InfoRow(
                    icon: Icons.speed_rounded,
                    title: l10n.quickSettlement,
                    subtitle: l10n.quickSettlementDesc,
                    color: const Color(0xFFFF8F00),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Steps Section
            SectionHeader(
              title: l10n.howToApply,
              icon: Icons.format_list_numbered_rounded,
              color: const Color(0xFF7B1FA2),
            ),
            const SizedBox(height: 16),

            StepCard(
              stepNumber: 1,
              title: l10n.visitNearestBank,
              subtitle: l10n.visitBankDesc,
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 12),
            StepCard(
              stepNumber: 2,
              title: l10n.fillApplication,
              subtitle: l10n.fillApplicationDesc,
              icon: Icons.edit_document,
            ),
            const SizedBox(height: 12),
            StepCard(
              stepNumber: 3,
              title: l10n.submitDocuments,
              subtitle: l10n.submitDocumentsDesc,
              icon: Icons.upload_file_rounded,
            ),
            const SizedBox(height: 12),
            StepCard(
              stepNumber: 4,
              title: l10n.payPremium,
              subtitle: l10n.payPremiumDesc,
              icon: Icons.payment_rounded,
            ),

            const SizedBox(height: 32),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: l10n.learnMore,
                icon: Icons.open_in_new_rounded,
                gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.externalLinkComingSoon),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
