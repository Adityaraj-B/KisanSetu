import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../data/models/crop_model.dart';

/// Crop Selection Step - Third step in onboarding
/// Shows crops based on selected district from PMFBY API
/// Allows multi-selection with chip-style UI
class CropSelectionStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CropSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CropSelectionStep> createState() => _CropSelectionStepState();
}

class _CropSelectionStepState extends State<CropSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CropModel> _getFilteredCrops(List<CropModel> crops) {
    if (_searchQuery.isEmpty) return crops;
    return crops
        .where((crop) =>
            crop.cropName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
                    _buildStepHeader(provider, l10n),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildSelectedInfo(provider),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildCropsContent(provider, l10n),
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
                  onPressed: provider.profile.hasCrops ? widget.onNext : null,
                  isLoading: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepHeader(OnboardingProvider provider, AppLocalizations l10n) {
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
                Icons.grass,
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
                    l10n.text('step_4_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select Your Crops',
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
          'Select the crops you want to insure under PMFBY',
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
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Location',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.profile.districtName}, ${provider.profile.stateName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          if (provider.profile.selectedCrops.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${provider.profile.selectedCrops.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCropsContent(OnboardingProvider provider, AppLocalizations l10n) {
    if (provider.isCropsLoading) {
      return _buildLoadingState();
    }

    if (provider.cropsError != null) {
      return _buildErrorState(provider, l10n);
    }

    if (!provider.hasCrops) {
      return _buildEmptyState(l10n);
    }

    final filteredCrops = _getFilteredCrops(provider.crops);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search crops...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
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
            fillColor: Colors.white,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          '${filteredCrops.length} crops available',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: filteredCrops.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Text(
                      'No crops found matching "$_searchQuery"',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
                  itemCount: filteredCrops.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final crop = filteredCrops[index];
                    final isSelected = provider.profile.selectedCrops
                        .any((c) => c.cropId == crop.cropId);
                    return _buildCropItem(crop, isSelected, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCropItem(CropModel crop, bool isSelected, OnboardingProvider provider) {
    return Material(
      color: isSelected ? AppColors.primaryGreenOverlay10 : Colors.transparent,
      child: InkWell(
        onTap: () => provider.toggleCrop(crop),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingM,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Center(
                  child: Icon(
                    Icons.eco,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  crop.cropName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (_) => provider.toggleCrop(crop),
                activeColor: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primaryGreen),
          const SizedBox(height: AppConstants.spacingM),
          Text('Loading crops...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(OnboardingProvider provider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            provider.cropsError ?? 'Failed to load crops',
            style: const TextStyle(color: AppColors.error, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextButton.icon(
            onPressed: () => provider.loadCrops(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 48),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No crops available for the selected district in this season',
            style: TextStyle(color: AppColors.warning, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

