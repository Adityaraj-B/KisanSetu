import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Bank Details Step - Collects bank account information for DBT
class BankDetailsStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BankDetailsStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BankDetailsStep> createState() => _BankDetailsStepState();
}

class _BankDetailsStepState extends State<BankDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();

  bool _showAccountNumber = false;

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

    if (profile.bankAccountNumber != null) {
      _accountNumberController.text = profile.bankAccountNumber!;
      _confirmAccountController.text = profile.bankAccountNumber!;
    }
    if (profile.bankIfscCode != null) _ifscController.text = profile.bankIfscCode!;
    if (profile.bankName != null) _bankNameController.text = profile.bankName!;
    if (profile.bankBranch != null) _branchNameController.text = profile.bankBranch!;
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<OnboardingProvider>();
      provider.updateBankDetails(
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim().toUpperCase(),
        bankName: _bankNameController.text.trim(),
        branchName: _branchNameController.text.trim(),
      );
      widget.onNext();
    }
  }

  bool get _isFormValid {
    return _accountNumberController.text.trim().length >= 9 &&
        _confirmAccountController.text.trim() == _accountNumberController.text.trim() &&
        _ifscController.text.trim().length == 11;
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
                      _buildDBTInfoCard(l10n),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildBankDetailsCard(l10n),
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
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('step_6_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.text('bank_details'),
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
          l10n.text('bank_details_subtitle'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDBTInfoCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 10),
              Text(
                l10n.text('direct_benefit_transfer'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.text('dbt_description'),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBenefitChip(l10n.text('pm_kisan'), Icons.agriculture_rounded),
              const SizedBox(width: 8),
              _buildBenefitChip(l10n.text('pmfby_claims'), Icons.shield_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard(AppLocalizations l10n) {
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
          // Bank Name
          _buildTextField(
            controller: _bankNameController,
            label: l10n.text('bank_name'),
            hint: l10n.text('enter_bank_name'),
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Branch Name
          _buildTextField(
            controller: _branchNameController,
            label: l10n.text('branch_name'),
            hint: l10n.text('enter_branch_name'),
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Account Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.text('account_number'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                obscureText: !_showAccountNumber,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.text('account_required');
                  }
                  if (value.length < 9 || value.length > 18) {
                    return l10n.text('account_invalid');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: l10n.text('enter_account_number'),
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF2E7D32)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showAccountNumber ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _showAccountNumber = !_showAccountNumber),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray.withOpacity(0.3),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Confirm Account Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.text('confirm_account_number'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmAccountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value != _accountNumberController.text) {
                    return l10n.text('account_mismatch');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: l10n.text('re_enter_account_number'),
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32)),
                  suffixIcon: _confirmAccountController.text.isNotEmpty &&
                          _confirmAccountController.text == _accountNumberController.text
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
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lightGray.withOpacity(0.3),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // IFSC Code
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.text('ifsc_code'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ifscController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.text('ifsc_required');
                  }
                  if (value.length != 11) {
                    return l10n.text('ifsc_invalid');
                  }
                  // IFSC format: 4 letters + 0 + 6 alphanumeric
                  final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                  if (!ifscRegex.hasMatch(value.toUpperCase())) {
                    return l10n.text('ifsc_format_invalid');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'SBIN0001234',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.qr_code_rounded, color: Color(0xFF2E7D32)),
                  suffixIcon: _ifscController.text.length == 11
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
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            filled: true,
            fillColor: AppColors.lightGray.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Important',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ensure your bank account is linked with your Aadhaar for seamless DBT transfers.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

