import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/language_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/farmer_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/widgets/premium_widgets.dart';
import '../core/theme/premium_theme.dart';
import '../core/utils/navigation_helper.dart';
import '../main.dart';

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double whiteness;
  final double borderOpacity;
  final List<Color>? gradientColors;
  final List<BoxShadow>? shadows;

  const _LiquidGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.whiteness = 0.12,
    this.borderOpacity = 0.45,
    this.gradientColors,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradientColors != null
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors!,
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: (whiteness + 0.15).clamp(0.0, 1.0)),
                Colors.white.withValues(alpha: (whiteness - 0.05).clamp(0.0, 1.0)),
              ],
              stops: const [0.0, 1.0],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1.2,
            ),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: const Offset(1, 1),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOutSine),
    );
    _backgroundController.repeat(reverse: true);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildFixedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, _) {
        final shift = _backgroundAnimation.value * 0.15;
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8 + shift, -1.0),
                end: Alignment(0.8 - shift, 1.0),
                stops: const [0.0, 0.35, 0.65, 1.0],
                colors: const [
                  Color(0xFF144D18),
                  Color(0xFF246B28),
                  Color(0xFFE2F3E4),
                  Color(0xFFF7FDF8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildFixedBackground(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(l10n)),
                  SliverToBoxAdapter(child: _buildPersonalDetailsSection(l10n)),
                  SliverToBoxAdapter(child: _buildFarmDetailsSection(l10n)),
                  SliverToBoxAdapter(child: _buildIdentitySection(l10n)),
                  SliverToBoxAdapter(child: _buildBankDetailsSection(l10n)),
                  SliverToBoxAdapter(child: _buildLandRecordsSection(l10n)),
                  SliverToBoxAdapter(child: _buildSettingsSection(l10n)),
                  SliverToBoxAdapter(child: _buildAppInfoSection(l10n)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      child: Consumer2<FarmerProvider, AuthProvider>(
        builder: (context, farmer, auth, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    _LiquidGlassCard(
                      padding: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(16),
                      whiteness: 0.15,
                      blurSigma: 20,
                      borderOpacity: 0.5,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.profile,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _LiquidGlassCard(
                  padding: const EdgeInsets.all(28),
                  blurSigma: 30,
                  whiteness: 0.12,
                  borderOpacity: 0.6,
                  child: Row(
                    children: [
                      AnimatedProgressRing(
                        progress: farmer.completionPercentage,
                        size: 84,
                        strokeWidth: 4,
                        gradientColors: const [Colors.white, Color(0xFFA5D6A7)],
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(farmer.completionPercentage * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.fullName ?? auth.userName ?? l10n.text('farmer'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    farmer.selectedDistrict != null && farmer.selectedDistrict!.isNotEmpty
                                        ? '${farmer.selectedDistrict}, ${farmer.selectedState ?? ''}'
                                        : farmer.selectedState ?? l10n.text('not_set'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: farmer.isProfileComplete
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFFFB300).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    farmer.isProfileComplete
                                        ? Icons.verified_rounded
                                        : Icons.pending_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    farmer.isProfileComplete
                                        ? l10n.text('profile_complete')
                                        : l10n.text('complete_profile'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalDetailsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('personal_details'),
            icon: Icons.person_rounded,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 16),
          Consumer<FarmerProvider>(
            builder: (context, farmer, _) {
              return StaggeredAnimation(
                index: 0,
                child: _LiquidGlassCard(
                  padding: EdgeInsets.zero,
                  blurSigma: 30,
                  whiteness: 0.55,
                  borderOpacity: 0.8,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.badge_rounded,
                        title: l10n.text('full_name'),
                        value: farmer.fullName ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF1565C0),
                        isSet: farmer.hasPersonalDetails,
                        onTap: () => _showPersonalDetailsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.family_restroom_rounded,
                        title: l10n.text('father_name'),
                        value: farmer.fatherName ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF1976D2),
                        isSet: farmer.fatherName != null && farmer.fatherName!.isNotEmpty,
                        onTap: () => _showPersonalDetailsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.home_work_rounded,
                        title: l10n.text('village_town'),
                        value: farmer.village ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF2196F3),
                        isSet: farmer.village != null && farmer.village!.isNotEmpty,
                        onTap: () => _showPersonalDetailsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.phone_rounded,
                        title: l10n.text('mobile'),
                        value: farmer.mobileNumber ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF42A5F5),
                        isSet: farmer.mobileNumber != null && farmer.mobileNumber!.isNotEmpty,
                        onTap: () => _showPersonalDetailsSheet(context, farmer, l10n),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFarmDetailsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('farm_details'),
            icon: Icons.agriculture_rounded,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 16),
          Consumer<FarmerProvider>(
            builder: (context, farmer, _) {
              return StaggeredAnimation(
                index: 1,
                child: _LiquidGlassCard(
                  padding: EdgeInsets.zero,
                  blurSigma: 30,
                  whiteness: 0.55,
                  borderOpacity: 0.8,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.location_on_rounded,
                        title: l10n.state,
                        value: farmer.selectedState ?? l10n.selectYourState,
                        color: const Color(0xFF2E7D32),
                        isSet: farmer.hasState,
                        onTap: () => _showStateEditSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.map_rounded,
                        title: l10n.text('district'),
                        value: farmer.selectedDistrict ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF388E3C),
                        isSet: farmer.selectedDistrict != null && farmer.selectedDistrict!.isNotEmpty,
                        onTap: () => _showStateEditSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.grass_rounded,
                        title: l10n.crops,
                        value: farmer.hasCrops
                            ? farmer.selectedCrops.join(', ')
                            : l10n.cropsYouGrow,
                        color: const Color(0xFF43A047),
                        isSet: farmer.hasCrops,
                        onTap: () => _showCropsEditSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.landscape_rounded,
                        title: l10n.land,
                        value: farmer.hasLandSize
                            ? '${farmer.landSizeAcres.toStringAsFixed(2)} ${l10n.acres}'
                            : l10n.landSize,
                        color: const Color(0xFF66BB6A),
                        isSet: farmer.hasLandSize,
                        onTap: () => _showLandSizeEditSheet(context, farmer, l10n),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('identity_details'),
            icon: Icons.badge_rounded,
            color: const Color(0xFFE65100),
          ),
          const SizedBox(height: 16),
          Consumer<FarmerProvider>(
            builder: (context, farmer, _) {
              return StaggeredAnimation(
                index: 2,
                child: _LiquidGlassCard(
                  padding: EdgeInsets.zero,
                  blurSigma: 30,
                  whiteness: 0.55,
                  borderOpacity: 0.8,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFFE65100).withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.fingerprint_rounded,
                        title: l10n.text('aadhaar_card'),
                        value: farmer.hasAadhaar
                            ? farmer.maskedAadhaar
                            : l10n.text('tap_to_add'),
                        color: const Color(0xFFE65100),
                        isSet: farmer.hasAadhaar,
                        onTap: () => _showIdentitySheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.credit_card_rounded,
                        title: l10n.text('pan_card'),
                        value: farmer.hasPan
                            ? farmer.panNumber!
                            : l10n.text('tap_to_add'),
                        color: const Color(0xFFEF6C00),
                        isSet: farmer.hasPan,
                        onTap: () => _showIdentitySheet(context, farmer, l10n),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('bank_details'),
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF00695C),
          ),
          const SizedBox(height: 16),
          Consumer<FarmerProvider>(
            builder: (context, farmer, _) {
              return StaggeredAnimation(
                index: 3,
                child: _LiquidGlassCard(
                  padding: EdgeInsets.zero,
                  blurSigma: 30,
                  whiteness: 0.55,
                  borderOpacity: 0.8,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF00695C).withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.business_rounded,
                        title: l10n.text('bank_name'),
                        value: farmer.bankName ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF00695C),
                        isSet: farmer.bankName != null && farmer.bankName!.isNotEmpty,
                        onTap: () => _showBankDetailsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.numbers_rounded,
                        title: l10n.text('account_number'),
                        value: farmer.hasBankDetails
                            ? farmer.maskedBankAccount
                            : l10n.text('tap_to_add'),
                        color: const Color(0xFF00897B),
                        isSet: farmer.hasBankDetails,
                        onTap: () => _showBankDetailsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.qr_code_rounded,
                        title: l10n.text('ifsc_code'),
                        value: farmer.bankIfscCode ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF26A69A),
                        isSet: farmer.bankIfscCode != null && farmer.bankIfscCode!.isNotEmpty,
                        onTap: () => _showBankDetailsSheet(context, farmer, l10n),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLandRecordsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('land_income_records'),
            icon: Icons.description_rounded,
            color: const Color(0xFF6D4C41),
          ),
          const SizedBox(height: 16),
          Consumer<FarmerProvider>(
            builder: (context, farmer, _) {
              return StaggeredAnimation(
                index: 4,
                child: _LiquidGlassCard(
                  padding: EdgeInsets.zero,
                  blurSigma: 30,
                  whiteness: 0.55,
                  borderOpacity: 0.8,
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF6D4C41).withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.article_rounded,
                        title: l10n.text('seven_twelve_extract'),
                        value: farmer.sevenTwelveNumber ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF6D4C41),
                        isSet: farmer.hasSevenTwelve,
                        onTap: () => _showLandRecordsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.receipt_long_rounded,
                        title: l10n.text('income_certificate'),
                        value: farmer.incomeCertificateNumber ?? l10n.text('tap_to_add'),
                        color: const Color(0xFF8D6E63),
                        isSet: farmer.incomeCertificateNumber != null && farmer.incomeCertificateNumber!.isNotEmpty,
                        onTap: () => _showLandRecordsSheet(context, farmer, l10n),
                      ),
                      const _CustomDivider(),
                      _ProfileInfoTile(
                        icon: Icons.currency_rupee_rounded,
                        title: l10n.text('annual_income_range'),
                        value: farmer.annualIncome != null
                            ? _getIncomeLabel(farmer.annualIncome!)
                            : l10n.text('tap_to_add'),
                        color: const Color(0xFFA1887F),
                        isSet: farmer.annualIncome != null && farmer.annualIncome!.isNotEmpty,
                        onTap: () => _showLandRecordsSheet(context, farmer, l10n),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getIncomeLabel(String value) {
    switch (value) {
      case 'below_1_lakh':
        return 'Below ₹1 Lakh';
      case '1_to_2.5_lakh':
        return '₹1 Lakh - ₹2.5 Lakh';
      case '2.5_to_5_lakh':
        return '₹2.5 Lakh - ₹5 Lakh';
      case '5_to_10_lakh':
        return '₹5 Lakh - ₹10 Lakh';
      case 'above_10_lakh':
        return 'Above ₹10 Lakh';
      default:
        return value;
    }
  }

  Widget _buildSettingsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('settings'),
            icon: Icons.settings_rounded,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 20),
          StaggeredAnimation(
            index: 1,
            child: _LiquidGlassCard(
              padding: EdgeInsets.zero,
              blurSigma: 30,
              whiteness: 0.55,
              borderOpacity: 0.8,
              shadows: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              child: Column(
                children: [
                  _buildLanguageTile(l10n),
                  const _CustomDivider(),
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.text('notifications'),
                    color: const Color(0xFFFF8F00),
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {},
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),
                  const _CustomDivider(),
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: l10n.text('dark_mode'),
                    color: const Color(0xFF424242),
                    trailing: Switch.adaptive(
                      value: false,
                      onChanged: (value) {},
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final currentCode = langProvider.locale.languageCode;
        return _SettingsTile(
          icon: Icons.language_rounded,
          title: l10n.selectLanguage,
          subtitle: currentCode == 'en' ? 'English' : 'हिंदी',
          color: const Color(0xFF0277BD),
          onTap: () {
            HapticFeedback.selectionClick();
            final newCode = currentCode == 'en' ? 'hi' : 'en';
            langProvider.setLocale(newCode);
          },
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              currentCode == 'en' ? '🇬🇧' : '🇮🇳',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppInfoSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSectionHeader(
            title: l10n.text('app_info'),
            icon: Icons.info_rounded,
            color: const Color(0xFF00897B),
          ),
          const SizedBox(height: 20),
          StaggeredAnimation(
            index: 2,
            child: _LiquidGlassCard(
              padding: EdgeInsets.zero,
              blurSigma: 30,
              whiteness: 0.55,
              borderOpacity: 0.8,
              shadows: [
                BoxShadow(
                  color: const Color(0xFF00897B).withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.text('help'),
                    color: const Color(0xFF00897B),
                    onTap: () {},
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ),
                  const _CustomDivider(),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.text('privacy_policy'),
                    color: const Color(0xFF5D4037),
                    onTap: () {},
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ),
                  const _CustomDivider(),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    title: l10n.text('terms'),
                    color: const Color(0xFF424242),
                    onTap: () {},
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ),
                  const _CustomDivider(),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.text('version'),
                    subtitle: 'v${AppConstants.appVersion}',
                    color: const Color(0xFF2E7D32),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Latest',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          StaggeredAnimation(
            index: 3,
            child: _buildSignOutButton(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showSignOutDialog(l10n);
      },
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        blurSigma: 20,
        whiteness: 0.8,
        borderOpacity: 0.9,
        gradientColors: [
          const Color(0xFFFFEBEE).withValues(alpha: 0.9),
          const Color(0xFFFFCDD2).withValues(alpha: 0.7),
        ],
        shadows: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFD32F2F),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              l10n.text('sign_out'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7FDF8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          l10n.text('sign_out'),
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1C1B1F)),
        ),
        content: Text(
          l10n.text('sign_out_confirm'),
          style: TextStyle(color: Colors.grey[800], fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.goBack,
              style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (mounted) {
                NavigationHelper.pushAndRemoveUntil(context, const AppInitializer());
              }
            },
            child: Text(
              l10n.text('sign_out'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showStateEditSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.state,
        child: _StateSelectionContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showCropsEditSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.crops,
        child: _CropSelectionContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showLandSizeEditSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.land,
        child: _LandSizeSelectionContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showPersonalDetailsSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.text('personal_details'),
        child: _PersonalDetailsContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showIdentitySheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.text('identity_details'),
        child: _IdentityDetailsContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showBankDetailsSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.text('bank_details'),
        child: _BankDetailsContent(farmer: farmer, l10n: l10n),
      ),
    );
  }

  void _showLandRecordsSheet(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        title: l10n.text('land_income_records'),
        child: _LandRecordsContent(farmer: farmer, l10n: l10n),
      ),
    );
  }
}

class _PremiumSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _PremiumSectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1B1F),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isSet;
  final VoidCallback onTap;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSet ? const Color(0xFF1C1B1F) : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isSet ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                color: isSet ? color : Colors.grey[400],
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1B1F),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
    );
  }
}

class _PremiumBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _PremiumBottomSheet({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FDF8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _StateSelectionContent extends StatelessWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _StateSelectionContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final states = AppConstants.indianStates;
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        final isSelected = farmer.selectedState == state;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                farmer.updateState(state);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                      size: 26,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF1C1B1F),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 26),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CropSelectionContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _CropSelectionContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_CropSelectionContent> createState() => _CropSelectionContentState();
}

class _CropSelectionContentState extends State<_CropSelectionContent> {
  late List<String> selectedCrops;

  @override
  void initState() {
    super.initState();
    selectedCrops = List.from(widget.farmer.selectedCrops);
  }

  @override
  Widget build(BuildContext context) {
    final crops = AppConstants.commonCrops.map((c) => c['name'] as String).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              final isSelected = selectedCrops.contains(crop);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCrops.remove(crop);
                        } else {
                          selectedCrops.add(crop);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00897B).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00897B)
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.grass_rounded,
                            color: isSelected ? const Color(0xFF00897B) : Colors.grey[600],
                            size: 26,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              crop,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF00897B) : const Color(0xFF1C1B1F),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF00897B), size: 26),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
            onPressed: () {
              widget.farmer.updateCrops(selectedCrops);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

class _LandSizeSelectionContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _LandSizeSelectionContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_LandSizeSelectionContent> createState() => _LandSizeSelectionContentState();
}

class _LandSizeSelectionContentState extends State<_LandSizeSelectionContent> {
  late double landSize;

  @override
  void initState() {
    super.initState();
    landSize = widget.farmer.landSizeAcres;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          AnimatedProgressRing(
            progress: landSize / 100,
            size: 140,
            strokeWidth: 12,
            gradientColors: const [Color(0xFF8D6E63), Color(0xFF5D4037)],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${landSize.toInt()}',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5D4037),
                    height: 1.1,
                  ),
                ),
                Text(
                  widget.l10n.acres,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: landSize,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: const Color(0xFF5D4037),
              inactiveColor: const Color(0xFF5D4037).withValues(alpha: 0.15),
              onChanged: (value) => setState(() => landSize = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 ${widget.l10n.acres}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
              Text('100 ${widget.l10n.acres}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 40),
          PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFF5D4037), Color(0xFF8D6E63)],
            onPressed: () {
              widget.farmer.updateLandSize(landSize);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _PersonalDetailsContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _PersonalDetailsContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_PersonalDetailsContent> createState() => _PersonalDetailsContentState();
}

class _PersonalDetailsContentState extends State<_PersonalDetailsContent> {
  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _villageController;
  late TextEditingController _talukaController;
  late TextEditingController _addressController;
  late TextEditingController _pinCodeController;
  late TextEditingController _mobileController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farmer.fullName ?? '');
    _fatherNameController = TextEditingController(text: widget.farmer.fatherName ?? '');
    _villageController = TextEditingController(text: widget.farmer.village ?? '');
    _talukaController = TextEditingController(text: widget.farmer.taluka ?? '');
    _addressController = TextEditingController(text: widget.farmer.address ?? '');
    _pinCodeController = TextEditingController(text: widget.farmer.pinCode ?? '');
    _mobileController = TextEditingController(text: widget.farmer.mobileNumber ?? '');
    _selectedGender = widget.farmer.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          _buildTextField(widget.l10n.text('full_name'), _nameController, Icons.badge_rounded),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('father_name'), _fatherNameController, Icons.family_restroom_rounded),
          const SizedBox(height: 16),
          _buildGenderSelector(),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('mobile'), _mobileController, Icons.phone_rounded, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('village_town'), _villageController, Icons.home_work_rounded),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('taluka'), _talukaController, Icons.location_city_rounded),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('full_address'), _addressController, Icons.location_on_rounded, maxLines: 2),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('pin_code'), _pinCodeController, Icons.pin_drop_rounded, keyboardType: TextInputType.number, maxLength: 6),
          const SizedBox(height: 32),
          PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
            onPressed: _saveDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: '',
      ),
    );
  }

  Widget _buildGenderSelector() {
    final genders = ['Male', 'Female', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.l10n.text('gender'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Row(
          children: genders.map((g) {
            final isSelected = _selectedGender == g;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: g != genders.last ? 8 : 0),
                child: InkWell(
                  onTap: () => setState(() => _selectedGender = g),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1565C0).withValues(alpha: 0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFF1565C0) : Colors.grey[300]!, width: isSelected ? 2 : 1),
                    ),
                    child: Center(
                      child: Text(widget.l10n.text(g.toLowerCase()), style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF1565C0) : Colors.grey[700])),
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

  void _saveDetails() {
    widget.farmer.updatePersonalDetails(
      fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      fatherName: _fatherNameController.text.trim().isNotEmpty ? _fatherNameController.text.trim() : null,
      gender: _selectedGender,
      village: _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : null,
      taluka: _talukaController.text.trim().isNotEmpty ? _talukaController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      pinCode: _pinCodeController.text.trim().isNotEmpty ? _pinCodeController.text.trim() : null,
      mobileNumber: _mobileController.text.trim().isNotEmpty ? _mobileController.text.trim() : null,
    );
    Navigator.pop(context);
  }
}

class _IdentityDetailsContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _IdentityDetailsContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_IdentityDetailsContent> createState() => _IdentityDetailsContentState();
}

class _IdentityDetailsContentState extends State<_IdentityDetailsContent> {
  late TextEditingController _aadhaarController;
  late TextEditingController _panController;

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController(text: widget.farmer.aadhaarNumber ?? '');
    _panController = TextEditingController(text: widget.farmer.panNumber ?? '');
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          _buildAadhaarField(),
          const SizedBox(height: 20),
          _buildPanField(),
          const SizedBox(height: 16),
          _buildSecurityNote(),
          const SizedBox(height: 32),
          PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFFE65100), Color(0xFFFF8F00)],
            onPressed: _saveDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fingerprint_rounded, color: Color(0xFFE65100), size: 22),
            const SizedBox(width: 8),
            Text(widget.l10n.text('aadhaar_card'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _aadhaarController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '123456789012',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE65100), width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',
          ),
          style: const TextStyle(fontSize: 18, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildPanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.credit_card_rounded, color: Color(0xFF0D47A1), size: 22),
            const SizedBox(width: 8),
            Text(widget.l10n.text('pan_card'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(' (${widget.l10n.text('optional')})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _panController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: 'ABCDE1234F',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',
          ),
          style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your data is encrypted and stored securely on your device.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDetails() {
    widget.farmer.updateIdentityDetails(
      aadhaarNumber: _aadhaarController.text.trim().length == 12 ? _aadhaarController.text.trim() : null,
      panNumber: _panController.text.trim().length == 10 ? _panController.text.trim().toUpperCase() : null,
    );
    Navigator.pop(context);
  }
}

class _BankDetailsContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _BankDetailsContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_BankDetailsContent> createState() => _BankDetailsContentState();
}

class _BankDetailsContentState extends State<_BankDetailsContent> {
  late TextEditingController _bankNameController;
  late TextEditingController _branchController;
  late TextEditingController _accountController;
  late TextEditingController _ifscController;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.farmer.bankName ?? '');
    _branchController = TextEditingController(text: widget.farmer.bankBranch ?? '');
    _accountController = TextEditingController(text: widget.farmer.bankAccountNumber ?? '');
    _ifscController = TextEditingController(text: widget.farmer.bankIfscCode ?? '');
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          _buildTextField(widget.l10n.text('bank_name'), _bankNameController, Icons.business_rounded),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('branch_name'), _branchController, Icons.location_on_rounded),
          const SizedBox(height: 16),
          _buildTextField(widget.l10n.text('account_number'), _accountController, Icons.numbers_rounded, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildIfscField(),
          const SizedBox(height: 16),
          _buildDBTNote(),
          const SizedBox(height: 32),
          PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFF00695C), Color(0xFF26A69A)],
            onPressed: _saveDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00695C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00695C), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildIfscField() {
    return TextField(
      controller: _ifscController,
      textCapitalization: TextCapitalization.characters,
      maxLength: 11,
      decoration: InputDecoration(
        labelText: widget.l10n.text('ifsc_code'),
        hintText: 'SBIN0001234',
        prefixIcon: const Icon(Icons.qr_code_rounded, color: Color(0xFF00695C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00695C), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: '',
      ),
      style: const TextStyle(letterSpacing: 1.5),
    );
  }

  Widget _buildDBTNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00695C).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: Color(0xFF00695C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your bank account will receive DBT benefits like PM-KISAN and PMFBY claims.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDetails() {
    widget.farmer.updateBankDetails(
      bankName: _bankNameController.text.trim().isNotEmpty ? _bankNameController.text.trim() : null,
      bankBranch: _branchController.text.trim().isNotEmpty ? _branchController.text.trim() : null,
      bankAccountNumber: _accountController.text.trim().isNotEmpty ? _accountController.text.trim() : null,
      bankIfscCode: _ifscController.text.trim().isNotEmpty ? _ifscController.text.trim().toUpperCase() : null,
    );
    Navigator.pop(context);
  }
}

class _LandRecordsContent extends StatefulWidget {
  final FarmerProvider farmer;
  final AppLocalizations l10n;

  const _LandRecordsContent({
    required this.farmer,
    required this.l10n,
  });

  @override
  State<_LandRecordsContent> createState() => _LandRecordsContentState();
}

class _LandRecordsContentState extends State<_LandRecordsContent> {
  late TextEditingController _sevenTwelveController;
  late TextEditingController _incomeCertController;
  String? _selectedIncomeRange;

  final List<Map<String, String>> _incomeRanges = [
    {'label': 'Below ₹1 Lakh', 'value': 'below_1_lakh'},
    {'label': '₹1 Lakh - ₹2.5 Lakh', 'value': '1_to_2.5_lakh'},
    {'label': '₹2.5 Lakh - ₹5 Lakh', 'value': '2.5_to_5_lakh'},
    {'label': '₹5 Lakh - ₹10 Lakh', 'value': '5_to_10_lakh'},
    {'label': 'Above ₹10 Lakh', 'value': 'above_10_lakh'},
  ];

  @override
  void initState() {
    super.initState();
    _sevenTwelveController = TextEditingController(text: widget.farmer.sevenTwelveNumber ?? '');
    _incomeCertController = TextEditingController(text: widget.farmer.incomeCertificateNumber ?? '');
    _selectedIncomeRange = widget.farmer.annualIncome;
  }

  @override
  void dispose() {
    _sevenTwelveController.dispose();
    _incomeCertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSevenTwelveSection(),
          const SizedBox(height: 24),
          _buildIncomeCertSection(),
          const SizedBox(height: 24),
          _buildIncomeRangeSection(),
          const SizedBox(height: 32),
          PremiumButton(
            text: widget.l10n.continueButton,
            gradient: const [Color(0xFF6D4C41), Color(0xFF8D6E63)],
            onPressed: _saveDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildSevenTwelveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.article_rounded, color: Color(0xFF6D4C41), size: 22),
            const SizedBox(width: 8),
            Text(widget.l10n.text('seven_twelve_extract'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(widget.l10n.text('land_ownership_proof'), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 12),
        TextField(
          controller: _sevenTwelveController,
          decoration: InputDecoration(
            labelText: widget.l10n.text('survey_gat_number'),
            prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF6D4C41)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeCertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Color(0xFF8D6E63), size: 22),
            const SizedBox(width: 8),
            Text(widget.l10n.text('income_certificate'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _incomeCertController,
          decoration: InputDecoration(
            labelText: widget.l10n.text('certificate_number'),
            prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF8D6E63)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF8D6E63), width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.currency_rupee_rounded, color: Color(0xFFA1887F), size: 22),
            const SizedBox(width: 8),
            Text(widget.l10n.text('annual_income_range'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        ..._incomeRanges.map((range) {
          final isSelected = _selectedIncomeRange == range['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedIncomeRange = range['value']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6D4C41).withValues(alpha: 0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF6D4C41) : Colors.grey[300]!, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF6D4C41) : Colors.grey[500], size: 22),
                    const SizedBox(width: 12),
                    Text(range['label']!, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? const Color(0xFF6D4C41) : Colors.grey[800])),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _saveDetails() {
    widget.farmer.updateLandRecordsIncome(
      sevenTwelveNumber: _sevenTwelveController.text.trim().isNotEmpty ? _sevenTwelveController.text.trim() : null,
      incomeCertificateNumber: _incomeCertController.text.trim().isNotEmpty ? _incomeCertController.text.trim() : null,
      annualIncome: _selectedIncomeRange,
    );
    Navigator.pop(context);
  }
}