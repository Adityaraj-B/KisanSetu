import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../localization/language_provider.dart';
import '../../screens/home_screen.dart';
import '../../screens/explore_screen.dart';
import '../../screens/insurance_screen.dart';
import '../../screens/profile_screen.dart';
import 'animated_chat_fab.dart';

/// Premium Main Navigation with Material 3 floating bottom bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _navAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _navSlideAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    InsuranceScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _navSlideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _navAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      _fadeController.reset();
      _fadeController.forward();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = context.watch<LanguageProvider>().locale.languageCode;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Stack(
        children: [
          // Current screen with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Premium floating bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _navSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _navSlideAnimation.value),
                  child: child,
                );
              },
              child: _PremiumFloatingNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabChanged,
                bottomPadding: bottomPadding,
                items: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: l10n.home,
                  ),
                  _NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: l10n.explore,
                  ),
                  _NavItem(
                    icon: Icons.shield_outlined,
                    activeIcon: Icons.shield_rounded,
                    label: l10n.cropInsurance,
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: l10n.profile,
                  ),
                ],
              ),
            ),
          ),

          // Animated floating chat button
          AnimatedChatFAB(languageCode: languageCode),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _PremiumFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;
  final double bottomPadding;

  const _PremiumFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = currentIndex == index;

                return _PremiumNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumNavItem> createState() => _PremiumNavItemState();
}

class _PremiumNavItemState extends State<_PremiumNavItem>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 20 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey(widget.isSelected),
                  color: widget.isSelected
                      ? Colors.white
                      : Colors.grey[600],
                  size: 24,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: widget.isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          widget.item.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
