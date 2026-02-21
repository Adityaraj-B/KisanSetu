import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/main_navigation.dart';
import '../../../core/utils/navigation_helper.dart';
import '../components/step_indicator.dart';
import '../components/personal_details_step.dart';
import '../components/state_selection_step.dart';
import '../components/district_selection_step.dart';
import '../components/crop_selection_step.dart';
import '../components/land_area_step.dart';
import '../components/aadhaar_identity_step.dart';
import '../components/bank_details_step.dart';
import '../components/land_records_income_step.dart';
import '../components/review_submit_step.dart';

/// PMFBY Onboarding Screen - Step-by-step farmer details collection
/// Progressive disclosure UI with API integration
class PMFBYOnboardingScreen extends StatefulWidget {
  const PMFBYOnboardingScreen({super.key});

  @override
  State<PMFBYOnboardingScreen> createState() => _PMFBYOnboardingScreenState();
}

class _PMFBYOnboardingScreenState extends State<PMFBYOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController = PageController();

    // Initialize the onboarding provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().initialize();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    final currentStep = provider.currentStep;
    debugPrint('PMFBYOnboarding: _onNext called - currentStep = $currentStep');

    if (currentStep < 8) {
      final nextStep = currentStep + 1;
      debugPrint('PMFBYOnboarding: Navigating from step $currentStep to $nextStep');

      // Update provider state first
      provider.goToStep(nextStep);

      // Then animate the PageView
      _pageController.animateToPage(
        nextStep,
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      ).then((_) {
        debugPrint('PMFBYOnboarding: Navigation animation completed to step $nextStep');
      });
    } else {
      debugPrint('PMFBYOnboarding: Already at last step (8), cannot advance');
    }
  }

  void _onBack() {
    final provider = context.read<OnboardingProvider>();
    final currentStep = provider.currentStep;
    debugPrint('PMFBYOnboarding: _onBack called - currentStep = $currentStep');

    if (currentStep > 0) {
      final prevStep = currentStep - 1;
      debugPrint('PMFBYOnboarding: Navigating back from step $currentStep to $prevStep');

      // Update provider state first
      provider.goToStep(prevStep);

      // Then animate the PageView
      _pageController.animateToPage(
        prevStep,
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      ).then((_) {
        debugPrint('PMFBYOnboarding: Back navigation animation completed to step $prevStep');
      });
    } else {
      debugPrint('PMFBYOnboarding: Already at first step (0), cannot go back');
    }
  }

  void _onSubmit() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    final farmerProvider = context.read<FarmerProvider>();
    final authProvider = context.read<AuthProvider>();
    final profile = onboardingProvider.profile;

    // Update the main farmer provider with ALL the onboarding data
    // Convert crop names for compatibility with existing system
    final cropNames = profile.selectedCrops.map((c) => c.cropName).toList();

    // Farm details
    await farmerProvider.updateState(profile.stateName);
    await farmerProvider.updateDistrict(profile.districtName);
    await farmerProvider.updateCrops(cropNames);
    await farmerProvider.updateLandSize(profile.landSizeAcres);

    // Personal details
    await farmerProvider.updatePersonalDetails(
      fullName: profile.fullName,
      fatherName: profile.fatherName,
      gender: profile.gender,
      dateOfBirth: profile.dateOfBirth,
      village: profile.village,
      taluka: profile.taluka,
      address: profile.address,
      pinCode: profile.pinCode,
      mobileNumber: profile.mobileNumber,
    );

    // Identity details
    await farmerProvider.updateIdentityDetails(
      aadhaarNumber: profile.aadhaarNumber,
      panNumber: profile.panNumber,
    );

    // Bank details
    await farmerProvider.updateBankDetails(
      bankAccountNumber: profile.bankAccountNumber,
      bankIfscCode: profile.bankIfscCode,
      bankName: profile.bankName,
      bankBranch: profile.bankBranch,
    );

    // Land records & income
    await farmerProvider.updateLandRecordsIncome(
      sevenTwelveNumber: profile.sevenTwelveNumber,
      incomeCertificateNumber: profile.incomeCertificateNumber,
      annualIncome: profile.annualIncome,
    );

    // Mark onboarding as completed
    await authProvider.completeOnboarding();

    // Navigate to main app
    if (mounted) {
      NavigationHelper.pushAndRemoveUntil(context, const MainNavigation());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header with back button and step indicator
                  _buildHeader(provider, l10n),

                  // Step content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        provider.goToStep(index);
                      },
                      children: [
                        // Step 1: Personal Details
                        PersonalDetailsStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 2: State Selection
                        StateSelectionStep(
                          onNext: _onNext,
                        ),
                        // Step 3: District Selection
                        DistrictSelectionStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 4: Crop Selection
                        CropSelectionStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 5: Land Area
                        LandAreaStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 6: Aadhaar & Identity
                        AadhaarIdentityStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 7: Bank Details
                        BankDetailsStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 8: Land Records & Income
                        LandRecordsIncomeStep(
                          onNext: _onNext,
                          onBack: _onBack,
                        ),
                        // Step 9: Review & Submit
                        ReviewSubmitStep(
                          onSubmit: _onSubmit,
                          onBack: _onBack,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(OnboardingProvider provider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button and title
          Row(
            children: [
              // Left side - Back button or placeholder
              SizedBox(
                width: 80,
                child: provider.currentStep > 0
                    ? IconButton(
                        onPressed: _onBack,
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: const Color(0xFF1C1B1F),
                        tooltip: l10n.goBack,
                      )
                    : const SizedBox.shrink(),
              ),

              // Center - Title
              Expanded(
                child: Text(
                  l10n.tellUsAboutYou,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1B1F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Right side - Skip button or placeholder
              SizedBox(
                width: 80,
                child: provider.currentStep == 0
                    ? TextButton(
                        onPressed: () {
                          NavigationHelper.pushAndRemoveUntil(
                            context,
                            const MainNavigation(),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: const Color(0xFF6B6B6B),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Step indicator
          StepIndicator(
            currentStep: provider.currentStep,
            totalSteps: 9, // Personal, State, District, Crops, Land, Aadhaar, Bank, Records, Review
            stepLabels: const ['Personal', 'State', 'District', 'Crops', 'Land', 'ID', 'Bank', 'Records', 'Review'],
          ),
        ],
      ),
    );
  }
}

