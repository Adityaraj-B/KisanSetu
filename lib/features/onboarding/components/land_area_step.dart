import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';

/// Land Area Step - Fourth step in onboarding
/// Allows user to input land area in acres/hectares
class LandAreaStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LandAreaStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LandAreaStep> createState() => _LandAreaStepState();
}

class _LandAreaStepState extends State<LandAreaStep> {
  final TextEditingController _areaController = TextEditingController();
  String _selectedUnit = 'Acres';
  final List<String> _units = ['Acres', 'Hectares'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      if (provider.profile.landSizeAcres > 0) {
        _areaController.text = provider.profile.landSizeAcres.toString();
      }
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _updateArea() {
    final provider = context.read<OnboardingProvider>();
    final area = double.tryParse(_areaController.text) ?? 0;
    // Convert to acres if needed
    double areaInAcres = area;
    if (_selectedUnit == 'Hectares') {
      areaInAcres = area * 2.471; // Convert hectares to acres
    }
    provider.updateLandSize(areaInAcres);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepHeader(l10n),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildSelectedInfo(provider),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildAreaInput(provider),
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
                child: PremiumButton(
                  text: l10n.continueButton,
                  onPressed: provider.profile.hasValidLandSize ? widget.onNext : null,
                  isLoading: false,
                ),
              ),
            ),
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
                Icons.square_foot,
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
                    l10n.text('step_5_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter Land Area',
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
          'Enter the total area of land you want to insure',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedInfo(OnboardingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Crops',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.profile.selectedCrops.map((c) => c.cropName).join(', '),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaInput(OnboardingProvider provider) {
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
            'Land Area',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _areaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter area',
                    hintStyle: TextStyle(color: AppColors.textHint),
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
                      borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                  ),
                  onChanged: (_) => _updateArea(),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUnit = value);
                          _updateArea();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.success, size: 20),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                'Helpful Tip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            '1 Acre = 0.4047 Hectares\n1 Hectare = 2.471 Acres',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

