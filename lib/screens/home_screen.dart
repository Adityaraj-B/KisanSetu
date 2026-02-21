import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/utils/navigation_helper.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/language_provider.dart';
import '../core/providers/farmer_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/weather_provider.dart';
import '../core/widgets/premium_widgets.dart';
import '../core/theme/premium_theme.dart';
import '../core/services/schemes_service.dart';
import '../core/constants/app_constants.dart';
import '../features/finance/screens/crop_finance_screen.dart';
import '../features/finance/screens/kcc_screen.dart';
import '../features/schemes/screens/schemes_screen.dart';
import '../features/weather/screens/weather_screen.dart';
import 'profile_screen.dart';

// ─── Liquid Glass Card ───────────────────────────────────────────────────────

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double whiteness;
  final double borderOpacity;
  final List<BoxShadow>? shadows;

  const _LiquidGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.whiteness = 0.12,
    this.borderOpacity = 0.45,
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
            gradient: LinearGradient(
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

// ─── Animated Orb Painter ────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double t;
  final List<Color> colors;

  _OrbPainter({required this.t, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final orbConfigs = [
      (0.15, 0.20, 110.0, 0.0),
      (0.75, 0.10, 90.0, math.pi * 0.66),
      (0.55, 0.72, 75.0, math.pi * 1.33),
      (0.10, 0.65, 60.0, math.pi * 0.33),
    ];

    for (int i = 0; i < orbConfigs.length; i++) {
      final (bx, by, br, phase) = orbConfigs[i];
      final angle = t * math.pi * 2 + phase;
      final cx = size.width * bx + math.cos(angle) * 18;
      final cy = size.height * by + math.sin(angle * 1.3) * 14;
      final paint = Paint()
        ..shader = RadialGradient(colors: [
          colors[i % colors.length].withValues(alpha: 0.35),
          colors[i % colors.length].withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: br));
      canvas.drawCircle(Offset(cx, cy), br, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ─── Dynamic Welcome Card ────────────────────────────────────────────────────

class _DynamicWelcomeCard extends StatefulWidget {
  final Widget child;
  final List<Color> orbColors;

  const _DynamicWelcomeCard({required this.child, required this.orbColors});

  @override
  State<_DynamicWelcomeCard> createState() => _DynamicWelcomeCardState();
}

class _DynamicWelcomeCardState extends State<_DynamicWelcomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _orb;

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _orb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: AnimatedBuilder(
          animation: _orb,
          builder: (context, child) {
            return CustomPaint(
              painter: _OrbPainter(t: _orb.value, colors: widget.orbColors),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  blurRadius: 0,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Pill ────────────────────────────────────────────────────────────

class _ShimmerPill extends StatefulWidget {
  final String text;
  const _ShimmerPill({required this.text});

  @override
  State<_ShimmerPill> createState() => _ShimmerPillState();
}

class _ShimmerPillState extends State<_ShimmerPill> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.28),
              Colors.white.withValues(alpha: 0.18),
            ], stops: [
              (_anim.value - 0.5).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.5).clamp(0.0, 1.0),
            ]),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const PulsingDot(color: Color(0xFF81C784), size: 8),
            const SizedBox(width: 8),
            Text(widget.text,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
          ]),
        );
      },
    );
  }
}

// ─── Home Screen ─────────────────────────────────────────────────────────────

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
  bool _schemesLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSchemes();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchWeatherForFarmer());
  }

  void _fetchWeatherForFarmer() {
    if (!mounted) return;
    final farmer = context.read<FarmerProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final location = farmer.selectedDistrict?.isNotEmpty == true
        ? farmer.selectedDistrict!
        : farmer.selectedState;
    if (location != null && location.isNotEmpty) {
      weatherProvider.fetchWeather(location);
    }
  }

  Future<void> _loadSchemes() async {
    await SchemesService.instance.loadSchemesData();
    if (mounted) setState(() => _schemesLoaded = true);
  }

  int _getEligibleSchemesCount(FarmerProvider farmer) {
    if (!_schemesLoaded) return 0;
    return SchemesService.instance.getEligibleSchemes(
      state: farmer.selectedState,
      district: farmer.selectedDistrict,
      crops: farmer.selectedCrops,
      landSize: farmer.landSizeAcres,
    ).length;
  }

  void _initAnimations() {
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);

    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 14));
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

  // ── Background ──────────────────────────────────────────────────────────────

  Widget _buildFixedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, _) {
        final shift = _backgroundAnimation.value * 0.12;
        return Positioned.fill(
          child: Stack(children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.8 + shift, -1.0),
                  end: Alignment(0.8 - shift, 1.0),
                  stops: const [0.0, 0.30, 0.58, 1.0],
                  colors: const [
                    Color(0xFF0D3B12),
                    Color(0xFF1A5C1E),
                    Color(0xFFD4EDD6),
                    Color(0xFFF2FCF3),
                  ],
                ),
              ),
            ),
            // Subtle noise / texture overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.04,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://grainy-gradients.vercel.app/noise.png'),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
            ),
            // Soft radial vignette for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.4 - shift * 0.5, -0.8),
                    radius: 1.4,
                    colors: [
                      const Color(0xFF2E7D32).withValues(alpha: 0.3 + shift * 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ]),
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
        body: Stack(children: [
          _buildFixedBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                _buildPremiumHeader(l10n),
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(children: [
                      _buildStatsSection(l10n),
                      _buildProfileProgressNudge(l10n),
                      _buildQuickActionsSection(l10n),
                      _buildServicesGrid(l10n),
                      _buildInsightsSection(l10n),
                      _buildTipsSection(l10n),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ]),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPremiumLogo(l10n),
                      _buildGlassLanguageSelector(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDynamicWelcomeCard(l10n, farmer, auth),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLogo(AppLocalizations l10n) {
    return Row(children: [
      _LiquidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(18),
        whiteness: 0.18,
        blurSigma: 20,
        borderOpacity: 0.55,
        child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 26),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          l10n.appTitle,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.4,
            height: 1.1,
          ),
        ),
        Text(
          'किसान सेतु',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.3,
          ),
        ),
      ]),
    ]);
  }

  Widget _buildGlassLanguageSelector() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final currentCode = langProvider.locale.languageCode;
        // Cycle: en → hi → mr → en
        String nextCode() {
          switch (currentCode) {
            case 'en': return 'hi';
            case 'hi': return 'mr';
            case 'mr': return 'en';
            default: return 'en';
          }
        }
        String nextLabel() {
          switch (currentCode) {
            case 'en': return 'हिंदी';
            case 'hi': return 'मराठी';
            case 'mr': return 'English';
            default: return 'English';
          }
        }
        String nextFlag() {
          switch (currentCode) {
            case 'en': return '🇮🇳';
            case 'hi': return '🇮🇳';
            case 'mr': return '🇬🇧';
            default: return '🇬🇧';
          }
        }
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            langProvider.setLocale(nextCode());
          },
          child: _LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: BorderRadius.circular(24),
            whiteness: 0.1,
            blurSigma: 24,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(nextFlag(),
                    style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Text(
                nextLabel(),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
              ),
              const SizedBox(width: 6),
              Icon(Icons.swap_horiz_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildDynamicWelcomeCard(AppLocalizations l10n, FarmerProvider farmer, AuthProvider auth) {
    final greeting = _getGreeting(l10n);
    final userName = farmer.fullName ?? auth.userName ?? l10n.text('farmer');

    return Consumer<WeatherProvider>(
      builder: (context, weather, _) {
        final orbColors = weather.hasData
            ? [weather.weatherGradient[0], weather.weatherGradient[1], const Color(0xFF81C784)]
            : [const Color(0xFF2E7D32), const Color(0xFF43A047), const Color(0xFF81C784)];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context)
                .push(CustomPageRoute(page: const WeatherScreen()))
                .then((_) => _fetchWeatherForFarmer());
          },
          child: _DynamicWelcomeCard(
            orbColors: orbColors,
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerPill(text: greeting),
                          const SizedBox(height: 25),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFD4F5D8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.05,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildWeatherBadge(weather, l10n),
                  ],
                ),

                // ── Location ──────────────────────────────────────────────────
                if (farmer.hasState) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on_rounded,
                          color: Colors.white.withValues(alpha: 0.9), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        farmer.selectedDistrict != null && farmer.selectedDistrict!.isNotEmpty
                            ? '${farmer.selectedDistrict}, ${farmer.selectedState ?? ''}'
                            : farmer.selectedState ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                ],

                // ── Weather strip ─────────────────────────────────────────────
                if (weather.hasData) ...[
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherStat('💧', '${weather.humidity}%', l10n.text('humidity')),
                            _buildWeatherDivider(),
                            _buildWeatherStat(
                                '💨', '${weather.windKph?.toStringAsFixed(0)} km/h', l10n.text('wind')),
                            _buildWeatherDivider(),
                            _buildWeatherStat(
                                '🌧️', '${weather.precipMm?.toStringAsFixed(1)} mm', l10n.text('rain')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(l10n.text('tap_for_forecast'),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 10),
                  ]),
                ] else if (weather.isLoading) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.text('fetching_weather'),
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ],
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherBadge(WeatherProvider weather, AppLocalizations l10n) {
    if (weather.isLoading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.9)),
        ),
      );
    }
    if (!weather.hasData) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1),
        ),
        child: Icon(Icons.wb_cloudy_outlined, color: Colors.white.withValues(alpha: 0.7), size: 28),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.50), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(weather.weatherEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [Colors.white, Color(0xFFD4F5D8)]).createShader(b),
              child: Text(
                '${weather.currentTemp?.toStringAsFixed(0)}°C',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(weather.conditionText ?? '',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.80),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildWeatherStat(String emoji, String value, String label) {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
      const SizedBox(height: 3),
      Text(label,
          style: TextStyle(
              fontSize: 10, color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildWeatherDivider() {
    return Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18));
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _showCropsDialog(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grass_rounded, color: Color(0xFF00897B), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.text('crops'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F))),
                  const SizedBox(height: 4),
                  Text('${farmer.selectedCrops.length} ${l10n.text('registered_crops')}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ]),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: farmer.selectedCrops.isEmpty
                ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.eco_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(l10n.text('no_crops_selected'),
                      style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ]))
                : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: farmer.selectedCrops.length,
                itemBuilder: (context, index) {
                  final crop = farmer.selectedCrops[index];
                  final cropData = AppConstants.commonCrops.firstWhere(
                        (c) => c['name'] == crop,
                    orElse: () => {'name': crop, 'icon': '🌱', 'nameHindi': crop},
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Text(cropData['icon'] as String, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(crop,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1F))),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF00897B), size: 24),
                    ]),
                  );
                }),
          ),
        ]),
      ),
    );
  }

  void _showLandSizeDialog(BuildContext context, FarmerProvider farmer, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.landscape_rounded, color: Color(0xFF5D4037), size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.text('land'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F))),
                const SizedBox(height: 4),
                Text(l10n.text('total_land_area'), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ]),
            ),
          ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF5D4037).withValues(alpha: 0.1),
                const Color(0xFF8D6E63).withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF5D4037).withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Text(farmer.landSizeAcres.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF5D4037))),
              const SizedBox(height: 4),
              Text(l10n.acres,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ── Stats Section ─────────────────────────────────────────────────────────────

  Widget _buildStatsSection(AppLocalizations l10n) {
    return Consumer<FarmerProvider>(
      builder: (context, farmer, _) {
        final schemesCount = _getEligibleSchemesCount(farmer);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: IntrinsicHeight(
            child: Row(children: [
              Expanded(
                child: StaggeredAnimation(
                  index: 0,
                  child: _PremiumStatCard(
                    icon: Icons.verified_rounded,
                    iconGradient: const [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    value: '$schemesCount',
                    label: l10n.text('schemes'),
                    onTap: () => NavigationHelper.push(context, const SchemesScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StaggeredAnimation(
                  index: 1,
                  child: _PremiumStatCard(
                    icon: Icons.grass_rounded,
                    iconGradient: const [Color(0xFF00695C), Color(0xFF26A69A)],
                    value: '${farmer.selectedCrops.length}',
                    label: l10n.text('crops'),
                    onTap: () => _showCropsDialog(context, farmer, l10n),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StaggeredAnimation(
                  index: 2,
                  child: _PremiumStatCard(
                    icon: Icons.landscape_rounded,
                    iconGradient: const [Color(0xFF4E342E), Color(0xFF8D6E63)],
                    value: farmer.landSizeAcres.toStringAsFixed(0),
                    label: l10n.acres,
                    onTap: () => _showLandSizeDialog(context, farmer, l10n),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────────

  Widget _buildQuickActionsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        blurSigma: 30,
        whiteness: 0.55,
        borderOpacity: 0.80,
        shadows: [
          BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GlassSectionHeader(title: l10n.quickAccess, icon: Icons.flash_on_rounded),
          const SizedBox(height: 20),
          Row(children: [
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
                  icon: Icons.account_balance_wallet_rounded,
                  title: l10n.text('crop_finance'),
                  subtitle: l10n.text('crop_finance_subtitle'),
                  gradientColors: const [Color(0xFF01579B), Color(0xFF0288D1)],
                  onTap: () => NavigationHelper.push(context, const CropFinanceScreen()),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── Services Grid ─────────────────────────────────────────────────────────────

  Widget _buildServicesGrid(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        blurSigma: 30,
        whiteness: 0.55,
        borderOpacity: 0.80,
        shadows: [
          BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GlassSectionHeader(title: l10n.text('services'), icon: Icons.apps_rounded),
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
                  icon: Icons.account_balance_wallet_rounded,
                  label: l10n.text('finance'),
                  color: const Color(0xFF0277BD),
                  onTap: () => NavigationHelper.push(context, const CropFinanceScreen()),
                ),
              ),
              StaggeredAnimation(
                index: 7,
                child: _ServiceItem(
                  icon: Icons.credit_card_rounded,
                  label: l10n.text('kcc'),
                  color: const Color(0xFFE65100),
                  onTap: () => NavigationHelper.push(context, const KccScreen()),
                ),
              ),
              StaggeredAnimation(
                index: 8,
                child: _ServiceItem(
                  icon: Icons.wb_sunny_rounded,
                  label: l10n.text('weather'),
                  color: const Color(0xFF00897B),
                  onTap: () => NavigationHelper.push(context, const WeatherScreen()),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // ── Insights ──────────────────────────────────────────────────────────────────

  Widget _buildInsightsSection(AppLocalizations l10n) {
    return Consumer<FarmerProvider>(
      builder: (context, farmer, _) {
        if (!farmer.isProfileComplete) return _buildCompleteProfileCard(l10n);
        final schemesCount = _getEligibleSchemesCount(farmer);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: _LiquidGlassCard(
            padding: const EdgeInsets.all(24),
            blurSigma: 30,
            whiteness: 0.55,
            borderOpacity: 0.80,
            shadows: [
              BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
            ],
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _GlassSectionHeader(title: l10n.text('your_insights'), icon: Icons.insights_rounded),
              const SizedBox(height: 20),
              StaggeredAnimation(
                index: 9,
                child: _PremiumInsightCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  title: '$schemesCount ${l10n.text('eligible_schemes')}',
                  subtitle: l10n.text('based_on_profile'),
                  progress: schemesCount / 25,
                  onTap: () => NavigationHelper.push(context, const SchemesScreen()),
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
                    onTap: () => _showCropsDialog(context, farmer, l10n),
                  ),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }

  // ── Profile Progress Nudge ────────────────────────────────────────────────────

  Widget _buildProfileProgressNudge(AppLocalizations l10n) {
    return Consumer<FarmerProvider>(
      builder: (context, farmer, _) {
        final pct = farmer.completionPercentage;
        // Only show if profile is NOT fully complete
        if (pct >= 1.0) return const SizedBox.shrink();

        final completedSteps = (pct * 6).round();
        final totalSteps = 6;
        final isLow = pct < 0.34;
        final isMid = pct >= 0.34 && pct < 0.67;

        final Color progressColor = isLow
            ? const Color(0xFFE53935)
            : isMid
                ? const Color(0xFFFF8F00)
                : const Color(0xFF43A047);

        final String emoji = isLow ? '🔴' : isMid ? '🟡' : '🟢';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: StaggeredAnimation(
            index: 1,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                NavigationHelper.push(context, const ProfileScreen());
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.90),
                          Colors.white.withValues(alpha: 0.70),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: progressColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.text('profile_progress'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1C1B1F),
                                    ),
                                  ),
                                  Text(
                                    '$completedSteps/$totalSteps ${l10n.text('profile_progress_desc')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: progressColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: progressColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${(pct * 100).round()}${l10n.text('profile_pct_complete')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: progressColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor:
                                progressColor.withValues(alpha: 0.12),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Step pills
                        _buildProfileStepPills(farmer, progressColor, l10n),
                        const SizedBox(height: 12),
                        // CTA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.text('complete_now'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: progressColor, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileStepPills(
      FarmerProvider farmer, Color color, AppLocalizations l10n) {
    final steps = [
      (farmer.hasState, l10n.state),
      (farmer.hasCrops, l10n.crops),
      (farmer.hasLandSize, l10n.land),
      (farmer.hasPersonalDetails, l10n.text('personal_details')),
      (farmer.hasAadhaar, l10n.text('aadhaar')),
      (farmer.hasBankDetails, l10n.text('bank_details')),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: steps.map((step) {
        final done = step.$1;
        final label = step.$2.length > 8
            ? '${step.$2.substring(0, 7)}…'
            : step.$2;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: done
                ? color.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: done
                  ? color.withValues(alpha: 0.35)
                  : Colors.grey.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                size: 11,
                color: done ? color : Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: done ? color : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompleteProfileCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: StaggeredAnimation(
        index: 9,
        child: AnimatedGradientBorder(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          gradientColors: const [Color(0xFFFF8F00), Color(0xFFFFB300), Color(0xFFFF8F00)],
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFFFF8F00).withValues(alpha: 0.25),
                    const Color(0xFFFFB300).withValues(alpha: 0.1),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_add_rounded, color: Color(0xFFFF8F00), size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.text('complete_profile'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                  const SizedBox(height: 6),
                  Text(l10n.text('complete_profile_desc'),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF8F00), size: 22),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Tips ──────────────────────────────────────────────────────────────────────

  Widget _buildTipsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: _LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        blurSigma: 30,
        whiteness: 0.55,
        borderOpacity: 0.80,
        shadows: [
          BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GlassSectionHeader(title: l10n.didYouKnow, icon: Icons.lightbulb_rounded),
          const SizedBox(height: 20),
          StaggeredAnimation(
            index: 11,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF2E7D32), size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.text('pm_kisan_title'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                  const SizedBox(height: 8),
                  Text(l10n.pmKisanInfo,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _GlassSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _GlassSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF2E7D32).withValues(alpha: 0.2),
            const Color(0xFF4CAF50).withValues(alpha: 0.08),
          ]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      ),
      const SizedBox(width: 14),
      Text(title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1F), letterSpacing: 0.2)),
    ]);
  }
}

// ─── Premium Stat Card ────────────────────────────────────────────────────────

class _PremiumStatCard extends StatefulWidget {
  final IconData icon;
  final List<Color> iconGradient;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _PremiumStatCard({
    required this.icon,
    required this.iconGradient,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); setState(() => _pressed = true); },
      onTapUp: (_) { _ctrl.reverse(); setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () { _ctrl.reverse(); setState(() => _pressed = false); },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, _) => Transform.scale(
          scale: _scale.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: _pressed ? 0.60 : 0.88),
                      Colors.white.withValues(alpha: _pressed ? 0.40 : 0.68),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconGradient[0].withValues(alpha: _pressed ? 0.18 : 0.07),
                      blurRadius: _pressed ? 14 : 28,
                      offset: Offset(0, _pressed ? 4 : 10),
                    ),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        widget.iconGradient[0].withValues(alpha: 0.22),
                        widget.iconGradient[1].withValues(alpha: 0.08),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: widget.iconGradient).createShader(b),
                      child: Icon(widget.icon, color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedCounter(
                    value: int.tryParse(widget.value) ?? 0,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1C1B1F), height: 1.0),
                  ),
                  const SizedBox(height: 5),
                  Text(widget.label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass Action Card ────────────────────────────────────────────────────────

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
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, _) => Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: widget.gradientColors[0].withValues(alpha: 0.45),
                    blurRadius: 28, offset: const Offset(0, 14)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 18),
              Text(widget.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 5),
              Text(widget.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.82), height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Row(children: [
                Text('Explore',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.95))),
                const SizedBox(width: 5),
                Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.95), size: 15),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Service Item ─────────────────────────────────────────────────────────────

class _ServiceItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  State<_ServiceItem> createState() => _ServiceItemState();
}

class _ServiceItemState extends State<_ServiceItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.82).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, _) => Transform.scale(
          scale: _scale.value,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.color.withValues(alpha: 0.22), widget.color.withValues(alpha: 0.06)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: widget.color.withValues(alpha: 0.32), width: 1.5),
                boxShadow: [
                  BoxShadow(color: widget.color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(widget.label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}

// ─── Premium Insight Card ─────────────────────────────────────────────────────

class _PremiumInsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double? progress;
  final VoidCallback? onTap;

  const _PremiumInsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withValues(alpha: 0.78), Colors.white.withValues(alpha: 0.48)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: iconColor.withValues(alpha: 0.28), width: 1.5),
              boxShadow: [
                BoxShadow(color: iconColor.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(children: [
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
                    color: iconColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
            ]),
          ),
        ),
      ),
    );
  }
}