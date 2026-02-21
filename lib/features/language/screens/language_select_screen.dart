import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/premium_widgets.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen>
    with TickerProviderStateMixin {
  String? _selectedLanguage;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String languageCode) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedLanguage = languageCode;
    });

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLocale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + (_backgroundController.value * 0.5),
                      -1,
                    ),
                    end: Alignment(
                      1 - (_backgroundController.value * 0.5),
                      1,
                    ),
                    colors: const [
                      Color(0xFF1B5E20),
                      Color(0xFF2E7D32),
                      Color(0xFF388E3C),
                    ],
                  ),
                ),
              );
            },
          ),
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Animated logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.agriculture_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App name
                      StaggeredAnimation(
                        index: 0,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'KisanSetu',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      StaggeredAnimation(
                        index: 1,
                        child: Text(
                          'किसान सेतु',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Language selection card
                      StaggeredAnimation(
                        index: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.language_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n?.chooseYourLanguage ?? 'Choose Your Language',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n?.selectYourLanguage ?? 'अपनी भाषा चुनें',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),
                                  // Language options
                                  ...AppConstants.supportedLanguages.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final language = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: StaggeredAnimation(
                                        index: 3 + index,
                                        child: _PremiumLanguageCard(
                                          languageCode: language['code']!,
                                          languageName: language['name']!,
                                          nativeName: language['nativeName']!,
                                          icon: language['icon']!,
                                          isSelected: _selectedLanguage == language['code'],
                                          onTap: () => _onLanguageSelected(language['code']!),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLanguageCard extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final String nativeName;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumLanguageCard({
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumLanguageCard> createState() => _PremiumLanguageCardState();
}

class _PremiumLanguageCardState extends State<_PremiumLanguageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(
                widget.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.languageName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? const Color(0xFF1B5E20)
                            : Colors.white,
                      ),
                    ),
                    Text(
                      widget.nativeName,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isSelected
                            ? Colors.grey[600]
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  widget.isSelected
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
