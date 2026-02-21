import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Review Submit Step - Final step in onboarding
/// Shows summary of all selections and allows submission
class ReviewSubmitStep extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const ReviewSubmitStep({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildSummaryCard(provider, l10n),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildInfoCard(),
                    const SizedBox(height: AppConstants.spacingL),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    PremiumButton(
                      text: 'Submit & Continue',
                      onPressed: onSubmit,
                      isLoading: false,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    TextButton(
                      onPressed: onBack,
                      child: Text(
                        'Go Back & Edit',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenOverlay10,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.fact_check,
                color: AppColors.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review & Submit',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Confirm Your Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          'Please review your information before submitting',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(OnboardingProvider provider, AppLocalizations l10n) {
    final profile = provider.profile;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('registration_summary'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Personal Details Section
          _buildSectionTitle(l10n.text('personal_details'), Icons.person_rounded),
          const SizedBox(height: 12),
          if (profile.fullName != null && profile.fullName!.isNotEmpty)
            _buildSummaryRow(Icons.badge, l10n.text('full_name'), profile.fullName!),
          if (profile.fatherName != null && profile.fatherName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.family_restroom, l10n.text('father_name'), profile.fatherName!),
          ],
          if (profile.village != null && profile.village!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.home_work_rounded, l10n.text('village_town'), profile.village!),
          ],

          const Divider(height: 32),

          // Farm Details Section
          _buildSectionTitle(l10n.text('farm_details'), Icons.agriculture_rounded),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.location_on, l10n.text('state'), profile.stateName),
          const SizedBox(height: 8),
          _buildSummaryRow(Icons.map, l10n.text('district'), profile.districtName),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.grass,
            l10n.text('crops'),
            profile.selectedCrops.map((c) => c.cropName).join(', '),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.square_foot,
            l10n.text('land_area'),
            '${profile.landSizeAcres.toStringAsFixed(2)} ${l10n.acres}',
          ),
          if (profile.sevenTwelveNumber != null && profile.sevenTwelveNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.article_rounded, l10n.text('seven_twelve'), profile.sevenTwelveNumber!),
          ],

          const Divider(height: 32),

          // Identity Details Section
          _buildSectionTitle(l10n.text('identity_details'), Icons.badge_rounded),
          const SizedBox(height: 12),
          if (profile.aadhaarNumber != null && profile.aadhaarNumber!.isNotEmpty)
            _buildSummaryRow(Icons.fingerprint, l10n.text('aadhaar'), profile.maskedAadhaar),
          if (profile.panNumber != null && profile.panNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.credit_card, l10n.text('pan'), profile.panNumber!),
          ],

          const Divider(height: 32),

          // Bank Details Section
          _buildSectionTitle(l10n.text('bank_details'), Icons.account_balance_rounded),
          const SizedBox(height: 12),
          if (profile.bankName != null && profile.bankName!.isNotEmpty)
            _buildSummaryRow(Icons.business, l10n.text('bank_name'), profile.bankName!),
          if (profile.bankAccountNumber != null && profile.bankAccountNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.numbers, l10n.text('account'), profile.maskedBankAccount),
          ],
          if (profile.bankIfscCode != null && profile.bankIfscCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(Icons.qr_code, l10n.text('ifsc'), profile.bankIfscCode!),
          ],

          const Divider(height: 32),

          // Season Info
          _buildSummaryRow(
            Icons.calendar_today,
            l10n.text('season'),
            provider.currentSeasonDisplay,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreenOverlay10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreenOverlay10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 24),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile will be saved and you can proceed to explore insurance options and schemes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

