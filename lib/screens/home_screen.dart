import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/utils/navigation_helper.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/language_provider.dart';
import '../core/providers/farmer_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/widgets/premium_widgets.dart';
import '../core/theme/premium_theme.dart';
import '../features/insurance/screens/insurance_screen.dart';
import '../features/schemes/screens/schemes_screen.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _contentSlide;
  late Animation<double> _backgroundAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOutSine),
    );
    _backgroundController.repeat(reverse: true);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _scrollController.dispose();
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
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildPremiumHeader(l10n),
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          _buildStatsSection(l10n),
                          _buildQuickActionsSection(l10n),
                          _buildServicesGrid(l10n),
                          _buildInsightsSection(l10n),
                          _buildTipsSection(l10n),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _headerSlide,
        child: SafeArea(
          bottom: false,
          child: Consumer2<FarmerProvider, AuthProvider>(
            builder: (context, farmer, auth, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPremiumLogo(l10n),
                        _buildGlassLanguageSelector(),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildGlassWelcomeCard(l10n, farmer, auth),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLogo(AppLocalizations l10n) {
    return Row(
      children: [
        _LiquidGlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(18),
          whiteness: 0.15,
          blurSigma: 20,
          borderOpacity: 0.5,
          child: const Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
            Text(
              'किसान सेतु',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassLanguageSelector() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final currentCode = langProvider.locale.languageCode;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            langProvider.setLocale(currentCode == 'en' ? 'hi' : 'en');
          },
          child: _LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: BorderRadius.circular(24),
            whiteness: 0.1,
            blurSigma: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentCode == 'en' ? '🇮🇳' : '🇬🇧',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  currentCode == 'en' ? 'हिंदी' : 'English',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassWelcomeCard(
      AppLocalizations l10n,
      FarmerProvider farmer,
      AuthProvider auth,
      ) {
    final greeting = _getGreeting(l10n);
    final userName = farmer.fullName ?? auth.userName ?? l10n.text('farmer');

    return _LiquidGlassCard(
      padding: const EdgeInsets.all(28),
      blurSigma: 30,
      whiteness: 0.12,
      borderOpacity: 0.6,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulsingDot(color: Color(0xFF81C784), size: 10),
                      const SizedBox(width: 10),
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                if (farmer.hasState) ...[
                  const SizedBox(height: 12),
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
                              : farmer.selectedState ?? '',
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
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: -2,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildStatsSection(AppLocalizations l10n) {
    return Consumer<FarmerProvider>(
      builder: (context, farmer, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: StaggeredAnimation(
                    index: 0,
                    child: _PremiumStatCard(
                      icon: Icons.verified_rounded,
                      iconGradient: const [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      value: '${farmer.eligibleSchemeCount}',
                      label: l10n.text('schemes'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StaggeredAnimation(
                    index: 1,
                    child: _PremiumStatCard(
                      icon: Icons.grass_rounded,
                      iconGradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
                      value: '${farmer.selectedCrops.length}',
                      label: l10n.text('crops'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StaggeredAnimation(
                    index: 2,
                    child: _PremiumStatCard(
                      icon: Icons.landscape_rounded,
                      iconGradient: const [Color(0xFF5D4037), Color(0xFF8D6E63)],
                      value: farmer.landSizeAcres.toStringAsFixed(0),
                      label: l10n.acres,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassSectionHeader(
              title: l10n.quickAccess,
              icon: Icons.flash_on_rounded,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StaggeredAnimation(
                    index: 3,
                    child: _GlassActionCard(
                      icon: Icons.account_balance_rounded,
                      title: l10n.exploreSchemes,
                      subtitle: l10n.discoverSchemes,
                      gradientColors: const [Color(0xFF1B5E20), Color(0xFF43A047)],
                      onTap: () => NavigationHelper.push(context, const SchemesScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StaggeredAnimation(
                    index: 4,
                    child: _GlassActionCard(
                      icon: Icons.shield_rounded,
                      title: l10n.cropInsurance,
                      subtitle: l10n.text('pmfby_short'),
                      gradientColors: const [Color(0xFF0277BD), Color(0xFF03A9F4)],
                      onTap: () => NavigationHelper.push(context, const InsuranceScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassSectionHeader(
              title: l10n.text('services'),
              icon: Icons.apps_rounded,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StaggeredAnimation(
                  index: 5,
                  child: _ServiceItem(
                    icon: Icons.agriculture_rounded,
                    label: l10n.text('schemes'),
                    color: const Color(0xFF2E7D32),
                    onTap: () => NavigationHelper.push(context, const SchemesScreen()),
                  ),
                ),
                StaggeredAnimation(
                  index: 6,
                  child: _ServiceItem(
                    icon: Icons.security_rounded,
                    label: l10n.text('insurance'),
                    color: const Color(0xFF0277BD),
                    onTap: () => NavigationHelper.push(context, const InsuranceScreen()),
                  ),
                ),
                StaggeredAnimation(
                  index: 7,
                  child: _ServiceItem(
                    icon: Icons.store_rounded,
                    label: l10n.text('market'),
                    color: const Color(0xFFFF8F00),
                    onTap: () {},
                  ),
                ),
                StaggeredAnimation(
                  index: 8,
                  child: _ServiceItem(
                    icon: Icons.wb_sunny_rounded,
                    label: l10n.text('weather'),
                    color: const Color(0xFF00897B),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(AppLocalizations l10n) {
    return Consumer<FarmerProvider>(
      builder: (context, farmer, _) {
        if (!farmer.isProfileComplete) {
          return _buildCompleteProfileCard(l10n);
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: _LiquidGlassCard(
            padding: const EdgeInsets.all(24),
            blurSigma: 30,
            whiteness: 0.55,
            borderOpacity: 0.8,
            shadows: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GlassSectionHeader(
                  title: l10n.text('your_insights'),
                  icon: Icons.insights_rounded,
                ),
                const SizedBox(height: 20),
                StaggeredAnimation(
                  index: 9,
                  child: _PremiumInsightCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: '${farmer.eligibleSchemeCount} ${l10n.text('eligible_schemes')}',
                    subtitle: l10n.text('based_on_profile'),
                    progress: farmer.eligibleSchemeCount / 10,
                  ),
                ),
                if (farmer.selectedCrops.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  StaggeredAnimation(
                    index: 10,
                    child: _PremiumInsightCard(
                      icon: Icons.eco_rounded,
                      iconColor: const Color(0xFF00897B),
                      title: '${l10n.text('growing')}: ${farmer.selectedCrops.take(2).join(", ")}',
                      subtitle: farmer.selectedCrops.length > 2
                          ? '+${farmer.selectedCrops.length - 2} ${l10n.text('more_crops')}'
                          : l10n.text('registered_crops'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteProfileCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: StaggeredAnimation(
        index: 9,
        child: AnimatedGradientBorder(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          gradientColors: const [
            Color(0xFFFF8F00),
            Color(0xFFFFB300),
            Color(0xFFFF8F00),
          ],
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF8F00).withValues(alpha: 0.25),
                        const Color(0xFFFFB300).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Color(0xFFFF8F00),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('complete_profile'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.text('complete_profile_desc'),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFFF8F00),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassSectionHeader(
              title: l10n.didYouKnow,
              icon: Icons.lightbulb_rounded,
            ),
            const SizedBox(height: 20),
            StaggeredAnimation(
              index: 11,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32).withValues(alpha: 0.2),
                          const Color(0xFF4CAF50).withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFF2E7D32),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.text('pm_kisan_title'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1B1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.pmKisanInfo,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
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
    );
  }
}

class _GlassSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GlassSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D32).withValues(alpha: 0.2),
                const Color(0xFF4CAF50).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
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

class _PremiumStatCard extends StatefulWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String value;
  final String label;

  const _PremiumStatCard({
    required this.icon,
    required this.iconGradient,
    required this.value,
    required this.label,
  });

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: _isPressed ? 0.65 : 0.85),
                        Colors.white.withValues(alpha: _isPressed ? 0.45 : 0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconGradient[0].withValues(alpha: _isPressed ? 0.15 : 0.05),
                        blurRadius: _isPressed ? 15 : 25,
                        offset: Offset(0, _isPressed ? 5 : 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.iconGradient[0].withValues(alpha: 0.2),
                              widget.iconGradient[1].withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: widget.iconGradient,
                          ).createShader(bounds),
                          child: Icon(widget.icon, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedCounter(
                        value: int.tryParse(widget.value) ?? 0,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C1B1F),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GlassActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_GlassActionCard> createState() => _GlassActionCardState();
}

class _GlassActionCardState extends State<_GlassActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ServiceItem> createState() => _ServiceItemState();
}

class _ServiceItemState extends State<_ServiceItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color.withValues(alpha: 0.2),
                        widget.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PremiumInsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double? progress;

  const _PremiumInsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.75),
                Colors.white.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (progress != null)
                AnimatedProgressRing(
                  progress: progress!.clamp(0.0, 1.0),
                  size: 52,
                  strokeWidth: 4.5,
                  gradientColors: [iconColor, iconColor.withValues(alpha: 0.4)],
                  child: Icon(icon, color: iconColor, size: 20),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1B1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
            ],
          ),
        ),
      ),
    );
  }
}