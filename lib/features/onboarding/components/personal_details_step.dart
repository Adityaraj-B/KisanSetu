import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Personal Details Step - Collects basic farmer information
/// Includes name, father's name, gender, address details
class PersonalDetailsStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PersonalDetailsStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _pinCodeController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _genders = ['Male', 'Female', 'Other'];

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

    if (profile.fullName != null) _fullNameController.text = profile.fullName!;
    if (profile.fatherName != null) _fatherNameController.text = profile.fatherName!;
    if (profile.address != null) _addressController.text = profile.address!;
    if (profile.village != null) _villageController.text = profile.village!;
    if (profile.taluka != null) _talukaController.text = profile.taluka!;
    if (profile.pinCode != null) _pinCodeController.text = profile.pinCode!;
    if (profile.gender != null) {
      setState(() => _selectedGender = profile.gender);
    }
    if (profile.dateOfBirth != null) {
      setState(() => _selectedDate = profile.dateOfBirth);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<OnboardingProvider>();
      provider.updatePersonalDetails(
        fullName: _fullNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
        address: _addressController.text.trim(),
        village: _villageController.text.trim(),
        taluka: _talukaController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
      );
      widget.onNext();
    }
  }

  bool get _isFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
        _fatherNameController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
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
                      _buildInfoCard(),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildFormFields(l10n),
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
                color: AppColors.primaryGreenOverlay10,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
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
                    l10n.text('step_1_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.text('personal_details'),
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
          l10n.text('personal_details_subtitle'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
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
            child: Text(
              'Your personal details will be used for scheme verification and document processing.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(AppLocalizations l10n) {
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
          // Full Name
          _buildTextField(
            controller: _fullNameController,
            label: l10n.text('full_name'),
            hint: l10n.text('enter_full_name'),
            icon: Icons.person_rounded,
            required: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.text('name_required');
              }
              if (value.trim().length < 3) {
                return l10n.text('name_too_short');
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Father's Name
          _buildTextField(
            controller: _fatherNameController,
            label: l10n.text('father_name'),
            hint: l10n.text('enter_father_name'),
            icon: Icons.family_restroom_rounded,
            required: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.text('father_name_required');
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Gender Selection
          _buildGenderSelection(l10n),
          const SizedBox(height: AppConstants.spacingM),

          // Date of Birth
          _buildDatePicker(l10n),
          const SizedBox(height: AppConstants.spacingM),

          // Village/Town
          _buildTextField(
            controller: _villageController,
            label: l10n.text('village_town'),
            hint: l10n.text('enter_village_town'),
            icon: Icons.home_work_rounded,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Taluka
          _buildTextField(
            controller: _talukaController,
            label: l10n.text('taluka'),
            hint: l10n.text('enter_taluka'),
            icon: Icons.location_city_rounded,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Address
          _buildTextField(
            controller: _addressController,
            label: l10n.text('full_address'),
            hint: l10n.text('enter_full_address'),
            icon: Icons.location_on_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // PIN Code
          _buildTextField(
            controller: _pinCodeController,
            label: l10n.text('pin_code'),
            hint: l10n.text('enter_pin_code'),
            icon: Icons.pin_drop_rounded,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
    bool required = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: AppColors.lightGray.withOpacity(0.3),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.text('gender'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _genders.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: gender != _genders.last ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => setState(() => _selectedGender = gender),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : AppColors.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          gender == 'Male'
                              ? Icons.male_rounded
                              : gender == 'Female'
                                  ? Icons.female_rounded
                                  : Icons.transgender_rounded,
                          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.text(gender.toLowerCase()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.text('date_of_birth'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : l10n.text('select_date_of_birth'),
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
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

