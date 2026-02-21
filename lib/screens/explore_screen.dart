import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization/app_localizations.dart';
import '../core/utils/navigation_helper.dart';
import '../features/schemes/screens/schemes_screen.dart';
import '../features/insurance/screens/insurance_screen.dart';
import '../features/weather/screens/weather_screen.dart';
import '../data/models/enhanced_farmer_profile.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final List<_CategoryItem> _categories = [
    _CategoryItem('All', Icons.apps_rounded, 'सभी', 'सर्व', const Color(0xFF2E7D32)),
    _CategoryItem('Schemes', Icons.account_balance_rounded, 'योजनाएं', 'योजना', const Color(0xFF1565C0)),
    _CategoryItem('Insurance', Icons.shield_rounded, 'बीमा', 'विमा', const Color(0xFF00897B)),
    _CategoryItem('Credit', Icons.credit_card_rounded, 'क्रेडिट', 'कर्ज', const Color(0xFFFF8F00)),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(l10n),
              SliverToBoxAdapter(child: _buildSearchSection(l10n)),
              SliverToBoxAdapter(child: _buildCategoryChips(langCode)),
              SliverToBoxAdapter(child: _buildSeasonCard(l10n)),
              SliverToBoxAdapter(child: _buildFeaturedSection(l10n)),
              SliverToBoxAdapter(child: _buildServicesSection(l10n)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1976D2),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha :0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.explore,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.searchExplore,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha :0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha :0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.text('search_placeholder'),
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: Color(0xFF1565C0),
                size: 26,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: Colors.grey[600], size: 16),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(String langCode) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          final displayName = langCode == 'hi' ? category.nameHi : (langCode == 'mr' ? category.nameMr : category.name);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _CategoryChip(
              isSelected: isSelected,
              icon: category.icon,
              label: displayName,
              color: category.color,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedCategoryIndex = index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonCard(AppLocalizations l10n) {
    final langCode = Localizations.localeOf(context).languageCode;
    final seasonDisplay = SeasonHelper.getLocalizedSeasonDisplay(langCode);
    final isKharif = SeasonHelper.getCurrentSeasonName() == 'Kharif';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isKharif
                ? [const Color(0xFF00897B), const Color(0xFF26A69A)]
                : [const Color(0xFF5D4037), const Color(0xFF8D6E63)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isKharif ? const Color(0xFF00897B) : const Color(0xFF5D4037))
                  .withValues(alpha :0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha :0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isKharif ? Icons.water_drop_rounded : Icons.ac_unit_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('current_season'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha :0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seasonDisplay,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha :0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.text('active'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.text('featured'),
            icon: Icons.star_rounded,
            color: const Color(0xFFFF8F00),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              children: [
                _FeaturedCard(
                  title: l10n.text('pm_kisan_featured'),
                  subtitle: l10n.text('pm_kisan_featured_sub'),
                  icon: Icons.account_balance_rounded,
                  gradientColors: const [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  onTap: () => NavigationHelper.push(context, const SchemesScreen()),
                ),
                const SizedBox(width: 14),
                _FeaturedCard(
                  title: l10n.text('pmfby_featured'),
                  subtitle: l10n.text('pmfby_featured_sub'),
                  icon: Icons.shield_rounded,
                  gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  onTap: () => NavigationHelper.push(context, const InsuranceScreen()),
                ),
                const SizedBox(width: 14),
                _FeaturedCard(
                  title: l10n.text('kcc_featured'),
                  subtitle: l10n.text('kcc_featured_sub'),
                  icon: Icons.credit_card_rounded,
                  gradientColors: const [Color(0xFFFF8F00), Color(0xFFFFB300)],
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.quickAccess,
            icon: Icons.grid_view_rounded,
            color: const Color(0xFF2E7D32),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.0,
            children: [
              _ServiceItem(
                icon: Icons.agriculture_rounded,
                label: l10n.text('schemes'),
                color: const Color(0xFF2E7D32),
                onTap: () => NavigationHelper.push(context, const SchemesScreen()),
              ),
              _ServiceItem(
                icon: Icons.security_rounded,
                label: l10n.text('insurance'),
                color: const Color(0xFF1565C0),
                onTap: () => NavigationHelper.push(context, const InsuranceScreen()),
              ),
              _ServiceItem(
                icon: Icons.store_rounded,
                label: l10n.text('market'),
                color: const Color(0xFFFF8F00),
                onTap: () {},
              ),
              _ServiceItem(
                icon: Icons.wb_sunny_rounded,
                label: l10n.text('weather'),
                color: const Color(0xFF00897B),
                onTap: () => NavigationHelper.push(context, const WeatherScreen()),
              ),
              _ServiceItem(
                icon: Icons.article_rounded,
                label: l10n.text('news'),
                color: const Color(0xFF7B1FA2),
                onTap: () {},
              ),
              _ServiceItem(
                icon: Icons.help_rounded,
                label: l10n.text('help'),
                color: const Color(0xFFD32F2F),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Supporting Widgets ====================

class _CategoryItem {
  final String name;
  final IconData icon;
  final String nameHi;
  final String nameMr;
  final Color color;

  _CategoryItem(this.name, this.icon, this.nameHi, this.nameMr, this.color);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha :0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1B1F),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha :0.8)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha :0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha :0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha :0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha :0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha :0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha :0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

