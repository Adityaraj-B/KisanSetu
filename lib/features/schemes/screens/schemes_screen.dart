import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/scheme_model.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Income Support', 'Insurance', 'Credit', 'Market Access', 'Soil Health', 'Organic'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForScheme(String iconName) {
    switch (iconName) {
      case 'agriculture': return Icons.agriculture;
      case 'security': return Icons.security;
      case 'credit_card': return Icons.credit_card;
      case 'solar_power': return Icons.solar_power;
      case 'eco': return Icons.eco;
      case 'spa': return Icons.spa;
      case 'storefront': return Icons.storefront;
      default: return Icons.account_balance;
    }
  }

  List<Scheme> _filterSchemes(List<Scheme> schemes) {
    var filtered = schemes;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((s) => s.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
        s.nameEn.toLowerCase().contains(query) ||
        s.nameHi.toLowerCase().contains(query) ||
        s.category.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  void _onSchemeCardTap(Scheme scheme, AppLocalizations l10n) {
    _showSchemeDetailsSheet(scheme, l10n);
  }

  void _showSchemeDetailsSheet(Scheme scheme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryGreenLight],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(_getIconForScheme(scheme.icon), color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.getLocalizedName(Localizations.localeOf(context).languageCode),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(scheme.category, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Description', l10n.text(scheme.description), Icons.info_outline),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildDetailSection('Benefits', l10n.text(scheme.benefits), Icons.card_giftcard),
                    if (scheme.hasLandRequirements) ...[
                      const SizedBox(height: AppConstants.spacingL),
                      _buildLandRequirementsSection(scheme, l10n),
                    ],
                    const SizedBox(height: AppConstants.spacingL),
                    _buildEligibilitySection(scheme, l10n),
                    const SizedBox(height: AppConstants.spacingXL),
                    _buildApplyButton(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: AppConstants.spacingS),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(content, style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLandRequirementsSection(Scheme scheme, AppLocalizations l10n) {
    String requirement = '';
    if (scheme.minLandAcres != null && scheme.maxLandAcres != null) {
      requirement = '${scheme.minLandAcres} - ${scheme.maxLandAcres} ${l10n.acres}';
    } else if (scheme.minLandAcres != null) {
      requirement = '≥ ${scheme.minLandAcres} ${l10n.acres}';
    } else if (scheme.maxLandAcres != null) {
      requirement = '≤ ${scheme.maxLandAcres} ${l10n.acres}';
    }
    return _buildDetailSection('Land Requirement', requirement, Icons.landscape);
  }

  Widget _buildEligibilitySection(Scheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: AppConstants.spacingS),
              Text('Eligibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          _buildEligibilityItem('States', scheme.supportsAllStates ? 'All India' : '${scheme.supportedStates.length} states'),
          _buildEligibilityItem('Crops', scheme.supportsAllCrops ? 'All crops' : '${scheme.supportedCrops.length} crops'),
          _buildEligibilityItem('Land', scheme.hasLandRequirements ? 'Specific requirements' : 'No restrictions'),
        ],
      ),
    );
  }

  Widget _buildEligibilityItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildApplyButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Application feature coming soon!'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            ),
          );
        },
        icon: const Icon(Icons.open_in_new),
        label: Text(l10n.howToApply),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primaryGreen,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryGreen, AppColors.primaryGreenLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppConstants.spacingL, 60, AppConstants.spacingL, AppConstants.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Eligible Schemes', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Consumer<FarmerProvider>(
                            builder: (context, farmer, _) => Text(
                              '${farmer.eligibleSchemes.length} schemes available for you',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search schemes...',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingM),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppConstants.spacingS),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryGreen,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          side: BorderSide(color: isSelected ? AppColors.primaryGreen : AppColors.borderLight),
                        ),
                        onSelected: (selected) => setState(() => _selectedCategory = category),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<FarmerProvider>(
                builder: (context, farmer, _) {
                  if (!farmer.hasState) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreenOverlay10,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: AppColors.primaryGreen),
                          const SizedBox(width: AppConstants.spacingS),
                          Expanded(
                            child: Text(
                              '${farmer.selectedState} • ${farmer.selectedCrops.length} crops • ${farmer.landSizeAcres.toStringAsFixed(1)} ${l10n.acres}',
                              style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Consumer<FarmerProvider>(
              builder: (context, farmer, _) {
                final allSchemes = farmer.eligibleSchemes;
                final filteredSchemes = _filterSchemes(allSchemes);

                if (filteredSchemes.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState(l10n));
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingXL),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final scheme = filteredSchemes[index];
                        final languageCode = Localizations.localeOf(context).languageCode;
                        return _buildSchemeCard(scheme, languageCode, l10n);
                      },
                      childCount: filteredSchemes.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme, String languageCode, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          onTap: () => _onSchemeCardTap(scheme, l10n),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreenOverlay10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForScheme(scheme.icon), color: AppColors.primaryGreen, size: 28),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.getLocalizedName(languageCode),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(scheme.category, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(color: AppColors.warningLight, shape: BoxShape.circle),
              child: Icon(Icons.search_off, size: 64, color: AppColors.warning),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text('No Schemes Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                  ? 'Try different search or category'
                  : 'Try different inputs',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingM),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

