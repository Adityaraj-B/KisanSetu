import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Aadhaar & Identity Step - Collects Aadhaar and PAN details
class AadhaarIdentityStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AadhaarIdentityStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AadhaarIdentityStep> createState() => _AadhaarIdentityStepState();
}

class _AadhaarIdentityStepState extends State<AadhaarIdentityStep> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();

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

    if (profile.aadhaarNumber != null) _aadhaarController.text = profile.aadhaarNumber!;
    if (profile.panNumber != null) _panController.text = profile.panNumber!;
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<OnboardingProvider>();
      provider.updateIdentityDetails(
        aadhaarNumber: _aadhaarController.text.replaceAll(' ', ''),
        panNumber: _panController.text.trim().toUpperCase(),
      );
      widget.onNext();
    }
  }

  bool get _isFormValid {
    final aadhaar = _aadhaarController.text.replaceAll(' ', '');
    return aadhaar.length == 12;
  }

  String _formatAadhaar(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 12; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
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
                      _buildImportanceCard(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildAadhaarCard(l10n),
                      const SizedBox(height: AppConstants.spacingM),
                      _buildPanCard(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildSecurityNote(),
                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(l10n),
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
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.badge_rounded,
                color: Color(0xFF1565C0),
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('step_5_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.text('identity_documents'),
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
          l10n.text('identity_documents_subtitle'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImportanceCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.1),
            const Color(0xFF42A5F5).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF1565C0), size: 24),
              const SizedBox(width: 10),
              Text(
                l10n.text('why_aadhaar_needed'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(l10n.text('aadhaar_benefit_1')),
          _buildBulletPoint(l10n.text('aadhaar_benefit_2')),
          _buildBulletPoint(l10n.text('aadhaar_benefit_3')),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
          ),
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

  Widget _buildAadhaarCard(AppLocalizations l10n) {
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
              Image.network(
                'https://upload.wikimedia.org/wikipedia/en/thumb/c/cf/Aadhaar_Logo.svg/220px-Aadhaar_Logo.svg.png',
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fingerprint_rounded, color: Color(0xFFE65100)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.text('aadhaar_card'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    l10n.text('unique_identification'),
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
          TextFormField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 14, // 12 digits + 2 spaces
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            onChanged: (value) {
              final formatted = _formatAadhaar(value);
              if (formatted != value) {
                _aadhaarController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
              setState(() {});
            },
            validator: (value) {
              final digits = value?.replaceAll(' ', '') ?? '';
              if (digits.isEmpty) {
                return l10n.text('aadhaar_required');
              }
              if (digits.length != 12) {
                return l10n.text('aadhaar_invalid');
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'XXXX XXXX XXXX',
              hintStyle: TextStyle(color: AppColors.textHint, letterSpacing: 2),
              prefixIcon: const Icon(Icons.fingerprint_rounded, color: Color(0xFFE65100)),
              suffixIcon: _aadhaarController.text.replaceAll(' ', '').length == 12
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
              ),
              filled: true,
              fillColor: AppColors.lightGray.withOpacity(0.3),
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanCard(AppLocalizations l10n) {
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card_rounded, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.text('pan_card'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' (${l10n.text('optional')})',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.text('income_tax_id'),
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
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (value) {
              setState(() {});
            },
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length != 10) {
                return l10n.text('pan_invalid');
              }
              // PAN format: ABCDE1234F
              if (value != null && value.length == 10) {
                final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                if (!panRegex.hasMatch(value.toUpperCase())) {
                  return l10n.text('pan_format_invalid');
                }
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'ABCDE1234F',
              hintStyle: TextStyle(color: AppColors.textHint, letterSpacing: 1),
              prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF0D47A1)),
              suffixIcon: _panController.text.length == 10
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
              ),
              filled: true,
              fillColor: AppColors.lightGray.withOpacity(0.3),
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your data is secure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All your information is encrypted and stored securely on your device.',
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
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
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
        child: PremiumButton(
          text: l10n.continueButton,
          onPressed: _isFormValid ? _saveAndContinue : null,
          isLoading: false,
        ),
      ),
    );
  }
}

