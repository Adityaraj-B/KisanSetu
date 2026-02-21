import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../data/models/state_model.dart';

/// State Selection Step - First step in onboarding
/// Fetches states from PMFBY API and allows selection with search
class StateSelectionStep extends StatefulWidget {
  final VoidCallback onNext;

  const StateSelectionStep({
    super.key,
    required this.onNext,
  });

  @override
  State<StateSelectionStep> createState() => _StateSelectionStepState();
}

class _StateSelectionStepState extends State<StateSelectionStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StateModel> _getFilteredStates(List<StateModel> states) {
    if (_searchQuery.isEmpty) return states;
    return states
        .where((state) =>
            state.stateName.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                    _buildStepHeader(l10n),

                    const SizedBox(height: AppConstants.spacingL),

                    // Season info
                    _buildSeasonInfo(provider),

                    const SizedBox(height: AppConstants.spacingL),

                    // States list or loading/error state
                    _buildStatesContent(provider, l10n),

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
                  onPressed: provider.profile.hasState ? widget.onNext : null,
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
                Icons.location_on,
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
                    l10n.text('step_2_of_8'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.selectYourState,
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
          'Select your state to see available districts and crops for PMFBY coverage',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonInfo(OnboardingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Season',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.currentSeasonDisplay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatesContent(OnboardingProvider provider, AppLocalizations l10n) {
    if (provider.isStatesLoading) {
      return _buildLoadingState();
    }

    if (provider.statesError != null) {
      return _buildErrorState(provider, l10n);
    }

    if (!provider.hasStates) {
      return _buildEmptyState(l10n);
    }

    final filteredStates = _getFilteredStates(provider.states);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search states...',
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

        // States count
        Text(
          '${filteredStates.length} states available',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppConstants.spacingS),

        // States list
        Container(
          constraints: const BoxConstraints(maxHeight: 350),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: filteredStates.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Text(
                      'No states found matching "$_searchQuery"',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingS,
                  ),
                  itemCount: filteredStates.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final state = filteredStates[index];
                    final isSelected =
                        provider.profile.selectedState?.stateId == state.stateId;

                    return _buildStateItem(state, isSelected, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStateItem(
    StateModel state,
    bool isSelected,
    OnboardingProvider provider,
  ) {
    return Material(
      color: isSelected ? AppColors.primaryGreenOverlay10 : Colors.transparent,
      child: InkWell(
        onTap: () => provider.selectState(state),
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
                  child: Text(
                    state.stateName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  state.stateName,
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
            'Loading states...',
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
            provider.statesError ?? 'Failed to load states',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextButton.icon(
            onPressed: () => provider.loadStates(forceRefresh: true),
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
            'No states available at the moment',
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

