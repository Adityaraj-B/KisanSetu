import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Land Records & Income Step - Collects 7/12 extract and income certificate details
class LandRecordsIncomeStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LandRecordsIncomeStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LandRecordsIncomeStep> createState() => _LandRecordsIncomeStepState();
}

class _LandRecordsIncomeStepState extends State<LandRecordsIncomeStep> {
  final _formKey = GlobalKey<FormState>();
  final _sevenTwelveController = TextEditingController();
  final _incomeCertController = TextEditingController();
  String? _selectedIncomeRange;

  final List<Map<String, dynamic>> _incomeRanges = [
    {'label': 'Below ₹1 Lakh', 'value': 'below_1_lakh'},
    {'label': '₹1 Lakh - ₹2.5 Lakh', 'value': '1_to_2.5_lakh'},
    {'label': '₹2.5 Lakh - ₹5 Lakh', 'value': '2.5_to_5_lakh'},
    {'label': '₹5 Lakh - ₹10 Lakh', 'value': '5_to_10_lakh'},
    {'label': 'Above ₹10 Lakh', 'value': 'above_10_lakh'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final provider = context.read<OnboardingProvider>();
    final profile = provider.profile;

    if (profile.sevenTwelveNumber != null) {
      _sevenTwelveController.text = profile.sevenTwelveNumber!;
    }
    if (profile.incomeCertificateNumber != null) {
      _incomeCertController.text = profile.incomeCertificateNumber!;
    }
    if (profile.annualIncome != null) {
      setState(() => _selectedIncomeRange = profile.annualIncome);
    }
  }

  @override
  void dispose() {
    _sevenTwelveController.dispose();
    _incomeCertController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    final provider = context.read<OnboardingProvider>();
    provider.updateLandRecordsIncome(
      sevenTwelveNumber: _sevenTwelveController.text.trim(),
      incomeCertificateNumber: _incomeCertController.text.trim(),
      annualIncome: _selectedIncomeRange,
    );
    widget.onNext();
  }

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepHeader(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildSevenTwelveCard(l10n),
                      const SizedBox(height: AppConstants.spacingM),
                      _buildIncomeSection(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildWhyNeededCard(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(l10n),
          ],
        );
      },
    );
  }

  Widget _buildStepHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFFEF6C00),
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('step_7_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.text('land_income_records'),
                    style: const TextStyle(
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
          l10n.text('land_income_subtitle'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSevenTwelveCard(AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF6C00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: Color(0xFFEF6C00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.text('seven_twelve_extract'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF6C00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '7/12',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.text('land_ownership_proof'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFEF6C00), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.text('seven_twelve_info'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            l10n.text('survey_gat_number'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sevenTwelveController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.text('enter_survey_number'),
              hintStyle: TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFFEF6C00)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: Color(0xFFEF6C00), width: 2),
              ),
              filled: true,
              fillColor: AppColors.lightGray.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSection(AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('income_certificate'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.text('for_scheme_eligibility'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Income Certificate Number
          Text(
            l10n.text('certificate_number'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _incomeCertController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.text('enter_certificate_number'),
              hintStyle: TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
              ),
              filled: true,
              fillColor: AppColors.lightGray.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Annual Income Range
          Text(
            l10n.text('annual_income_range'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._incomeRanges.map((range) => _buildIncomeRangeOption(range)),
        ],
      ),
    );
  }

  Widget _buildIncomeRangeOption(Map<String, dynamic> range) {
    final isSelected = _selectedIncomeRange == range['value'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedIncomeRange = range['value']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen.withOpacity(0.1)
                : AppColors.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                range['label'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhyNeededCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppColors.info, size: 24),
              const SizedBox(width: 10),
              Text(
                l10n.text('why_these_documents'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentReason(
            Icons.article_rounded,
            l10n.text('seven_twelve_reason'),
          ),
          _buildDocumentReason(
            Icons.receipt_long_rounded,
            l10n.text('income_cert_reason'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentReason(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    return Container(
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
              text: l10n.continueButton,
              onPressed: _saveAndContinue,
              isLoading: false,
            ),
            const SizedBox(height: AppConstants.spacingS),
            TextButton(
              onPressed: _saveAndContinue,
              child: Text(
                l10n.text('skip_for_now'),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

