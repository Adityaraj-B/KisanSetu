import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../data/models/district_model.dart';

/// District Selection Step - Second step in onboarding
/// Shows districts based on selected state from PMFBY API
class DistrictSelectionStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DistrictSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DistrictSelectionStep> createState() => _DistrictSelectionStepState();
}

class _DistrictSelectionStepState extends State<DistrictSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DistrictModel> _getFilteredDistricts(List<DistrictModel> districts) {
    if (_searchQuery.isEmpty) return districts;
    return districts
        .where((district) => district.districtName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildStepHeader(provider, l10n),

                    const SizedBox(height: AppConstants.spacingL),

                    // Selected state info
                    _buildSelectedStateInfo(provider),

                    const SizedBox(height: AppConstants.spacingL),

                    // Districts list or loading/error state
                    _buildDistrictsContent(provider, l10n),

                    const SizedBox(height: AppConstants.spacingL),
                  ],
                ),
              ),
            ),

            // Fixed bottom button bar
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
                  onPressed: provider.profile.hasDistrict ? widget.onNext : null,
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
                Icons.map,
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
                    l10n.text('step_3_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select Your District',
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
          'Select your district to see available crops for insurance coverage',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedStateInfo(OnboardingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected State',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.profile.stateName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onBack,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.success,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsContent(
      OnboardingProvider provider, AppLocalizations l10n) {
    if (provider.isDistrictsLoading) {
      return _buildLoadingState();
    }

    if (provider.districtsError != null) {
      return _buildErrorState(provider, l10n);
    }

    if (!provider.hasDistricts) {
      return _buildEmptyState(l10n);
    }

    final filteredDistricts = _getFilteredDistricts(provider.districts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search districts...',
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
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),

        const SizedBox(height: AppConstants.spacingM),

        // Districts count
        Text(
          '${filteredDistricts.length} districts available',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppConstants.spacingS),

        // Districts list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: filteredDistricts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Text(
                      'No districts found matching "$_searchQuery"',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingS,
                  ),
                  itemCount: filteredDistricts.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final district = filteredDistricts[index];
                    final isSelected = provider.profile.selectedDistrict
                            ?.districtId ==
                        district.districtId;

                    return _buildDistrictItem(district, isSelected, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDistrictItem(
    DistrictModel district,
    bool isSelected,
    OnboardingProvider provider,
  ) {
    return Material(
      color: isSelected ? AppColors.primaryGreenOverlay10 : Colors.transparent,
      child: InkWell(
        onTap: () => provider.selectDistrict(district),
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
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Center(
                  child: Icon(
                    Icons.place,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  district.districtName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 24,
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
          const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Loading districts...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
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
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            provider.districtsError ?? 'Failed to load districts',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextButton.icon(
            onPressed: () => provider.loadDistricts(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
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
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No districts available for the selected state in this season',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

