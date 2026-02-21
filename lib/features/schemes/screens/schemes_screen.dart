import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/schemes_service.dart';

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
  bool _isLoading = true;
  List<JsonScheme> _eligibleSchemes = [];

  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    await SchemesService.instance.loadSchemesData();

    if (mounted) {
      final farmer = context.read<FarmerProvider>();
      _updateEligibleSchemes(farmer);

      // Get unique categories from loaded schemes
      final categories = SchemesService.instance.getUniqueCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  void _updateEligibleSchemes(FarmerProvider farmer) {
    _eligibleSchemes = SchemesService.instance.getEligibleSchemes(
      state: farmer.selectedState,
      district: farmer.selectedDistrict,
      crops: farmer.selectedCrops,
      landSize: farmer.landSizeAcres,
    );
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
      case 'payments': return Icons.payments;
      case 'water_drop': return Icons.water_drop;
      case 'local_florist': return Icons.local_florist;
      case 'smart_toy': return Icons.smart_toy;
      case 'elderly': return Icons.elderly;
      case 'business': return Icons.business;
      case 'park': return Icons.park;
      case 'hive': return Icons.hive;
      case 'trending_up': return Icons.trending_up;
      case 'recycling': return Icons.recycling;
      case 'groups': return Icons.groups;
      case 'delete_sweep': return Icons.delete_sweep;
      case 'restaurant': return Icons.restaurant;
      case 'factory': return Icons.factory;
      case 'work': return Icons.work;
      case 'price_check': return Icons.price_check;
      default: return Icons.account_balance;
    }
  }

  List<JsonScheme> _filterSchemes(List<JsonScheme> schemes) {
    var filtered = schemes;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((s) => s.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
        s.name.toLowerCase().contains(query) ||
        s.nameHi.toLowerCase().contains(query) ||
        s.category.toLowerCase().contains(query) ||
        s.benefit.toLowerCase().contains(query) ||
        s.benefitHi.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  void _onSchemeCardTap(JsonScheme scheme, AppLocalizations l10n) {
    _showSchemeDetailsSheet(scheme, l10n);
  }

  void _showSchemeDetailsSheet(JsonScheme scheme, AppLocalizations l10n) {
    final languageCode = Localizations.localeOf(context).languageCode;

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
                          scheme.getLocalizedName(languageCode),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(scheme.getLocalizedCategory(languageCode), style: const TextStyle(fontSize: 12, color: Colors.white)),
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
                    _buildDetailSection(
                      languageCode == 'hi' ? 'विवरण' : (languageCode == 'mr' ? 'वर्णन' : 'Description'),
                      scheme.getLocalizedDescription(languageCode),
                      Icons.info_outline,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildDetailSection(
                      languageCode == 'hi' ? 'लाभ' : (languageCode == 'mr' ? 'फायदे' : 'Benefits'),
                      scheme.getLocalizedBenefit(languageCode),
                      Icons.card_giftcard,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildDocumentsSection(scheme, languageCode),
                    if (scheme.hasLandRequirements) ...[
                      const SizedBox(height: AppConstants.spacingL),
                      _buildLandRequirementsSection(scheme, l10n),
                    ],
                    const SizedBox(height: AppConstants.spacingL),
                    _buildEligibilitySection(scheme, l10n, languageCode),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildDeadlineSection(scheme, languageCode),
                    const SizedBox(height: AppConstants.spacingXL),
                    Row(
                      children: [
                        Expanded(child: _buildApplyButton(l10n, scheme.url)),
                        const SizedBox(width: 12),
                        _buildShareButton(l10n, scheme, languageCode),
                      ],
                    ),
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

  Widget _buildLandRequirementsSection(JsonScheme scheme, AppLocalizations l10n) {
    String requirement = '';
    final params = scheme.params;
    if (params.minAcres != null && params.maxAcres != null && params.maxAcres! > 0) {
      requirement = '${params.minAcres} - ${params.maxAcres} ${l10n.acres}';
    } else if (params.minAcres != null) {
      requirement = '≥ ${params.minAcres} ${l10n.acres}';
    } else if (params.maxAcres != null && params.maxAcres! > 0) {
      requirement = '≤ ${params.maxAcres} ${l10n.acres}';
    } else {
      final localizedText = l10n.text('no_land_requirement');
      requirement = localizedText.isNotEmpty ? localizedText : 'No specific requirement';
    }
    return _buildDetailSection('Land Requirement', requirement, Icons.landscape);
  }

  Widget _buildDocumentsSection(JsonScheme scheme, String languageCode) {
    final docs = scheme.getLocalizedDocs(languageCode);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppColors.info, size: 20),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                languageCode == 'hi' ? 'आवश्यक दस्तावेज' : (languageCode == 'mr' ? 'आवश्यक कागदपत्रे' : 'Required Documents'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          ...docs.map((doc) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.info, size: 16),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(child: Text(doc, style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDeadlineSection(JsonScheme scheme, String languageCode) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.warning, size: 20),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageCode == 'hi' ? 'आवेदन की अंतिम तिथि' : (languageCode == 'mr' ? 'अर्जाची अंतिम तारीख' : 'Application Deadline'),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  scheme.getLocalizedDeadline(languageCode),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilitySection(JsonScheme scheme, AppLocalizations l10n, String languageCode) {
    final statesText = scheme.supportsAllStates
        ? (languageCode == 'hi' ? 'पूरे भारत में' : (languageCode == 'mr' ? 'संपूर्ण भारत' : 'All India'))
        : '${scheme.params.states.length} ${languageCode == 'hi' ? 'राज्य' : (languageCode == 'mr' ? 'राज्ये' : 'states')}';
    final cropsText = scheme.supportsAllCrops
        ? (languageCode == 'hi' ? 'सभी फसलें' : (languageCode == 'mr' ? 'सर्व पिके' : 'All crops'))
        : '${scheme.params.crops.length} ${languageCode == 'hi' ? 'फसलें' : (languageCode == 'mr' ? 'पिके' : 'crops')}';
    final landText = scheme.hasLandRequirements
        ? (languageCode == 'hi' ? 'विशेष आवश्यकताएं' : (languageCode == 'mr' ? 'विशेष आवश्यकता' : 'Specific requirements'))
        : (languageCode == 'hi' ? 'कोई प्रतिबंध नहीं' : (languageCode == 'mr' ? 'कोणतेही बंधन नाही' : 'No restrictions'));

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
              Text(
                languageCode == 'hi' ? 'पात्रता' : (languageCode == 'mr' ? 'पात्रता' : 'Eligibility'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            scheme.getLocalizedEligibility(languageCode),
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: AppConstants.spacingS),
          _buildEligibilityItem(languageCode == 'hi' ? 'राज्य' : (languageCode == 'mr' ? 'राज्ये' : 'States'), statesText),
          _buildEligibilityItem(languageCode == 'hi' ? 'फसलें' : (languageCode == 'mr' ? 'पिके' : 'Crops'), cropsText),
          _buildEligibilityItem(languageCode == 'hi' ? 'भूमि' : (languageCode == 'mr' ? 'जमीन' : 'Land'), landText),
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

  Widget _buildApplyButton(AppLocalizations l10n, String url) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(url.isNotEmpty
                  ? 'Visit: $url'
                  : 'Application feature coming soon!'),
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

  Widget _buildShareButton(AppLocalizations l10n, JsonScheme scheme, String languageCode) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        _shareScheme(scheme, languageCode, l10n);
      },
      icon: const Icon(Icons.share_rounded),
      label: Text(l10n.text('share_scheme')),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingM, horizontal: AppConstants.spacingM),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
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
                          Text(
                            '${_eligibleSchemes.length} schemes available for you',
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
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
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingXL),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSkeletonCard(),
                    childCount: 6,
                  ),
                ),
              )
            else
              Consumer<FarmerProvider>(
                builder: (context, farmer, _) {
                  // Update eligible schemes when farmer profile changes
                  _updateEligibleSchemes(farmer);
                  final filteredSchemes = _filterSchemes(_eligibleSchemes);

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

  // ── Skeleton loader ──────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            _SkeletonBox(width: 52, height: 52, radius: 12),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: double.infinity, height: 14, radius: 6),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 180, height: 11, radius: 5),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 80, height: 18, radius: 9),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SkeletonBox(width: 20, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }

  // ── Deadline helpers ─────────────────────────────────────────────────────────
  /// Returns null for "ongoing/rolling" deadlines (e.g. "Rolling", "Ongoing", "N/A", empty)
  /// Returns a positive int for days left, 0 for today, negative for passed
  int? _parseDeadlineDays(String deadline) {
    if (deadline.isEmpty) return null;
    final lower = deadline.toLowerCase().trim();
    if (lower == 'rolling' ||
        lower == 'ongoing' ||
        lower == 'n/a' ||
        lower == 'year-round' ||
        lower == 'continuous' ||
        lower.contains('rolling') ||
        lower.contains('ongoing')) return null;

    // Try to parse a date from common formats like "March 31, 2026" or "31/03/2026"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Pattern: "Month DD, YYYY"
    final monthNames = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
    };
    for (final entry in monthNames.entries) {
      if (lower.contains(entry.key)) {
        final numbers = RegExp(r'\d+').allMatches(deadline).map((m) => int.parse(m.group(0)!)).toList();
        if (numbers.length >= 2) {
          int year = numbers.length >= 3 ? numbers[2] : now.year;
          if (year < 100) year += 2000;
          final day = numbers[0] <= 31 ? numbers[0] : numbers[1];
          try {
            final date = DateTime(year, entry.value, day);
            return date.difference(today).inDays;
          } catch (_) {}
        }
      }
    }
    // Pattern: DD/MM/YYYY or DD-MM-YYYY
    final slashMatch = RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})').firstMatch(deadline);
    if (slashMatch != null) {
      int y = int.parse(slashMatch.group(3)!);
      if (y < 100) y += 2000;
      try {
        final date = DateTime(y, int.parse(slashMatch.group(2)!), int.parse(slashMatch.group(1)!));
        return date.difference(today).inDays;
      } catch (_) {}
    }
    return null;
  }

  Widget? _buildDeadlineBadge(String deadline, AppLocalizations l10n) {
    final days = _parseDeadlineDays(deadline);
    if (days == null) return null; // rolling/ongoing — no badge

    if (days < 0) {
      // Passed
      return _DeadlineBadge(
        label: l10n.text('deadline_passed'),
        color: Colors.grey,
        icon: Icons.lock_outline_rounded,
      );
    } else if (days == 0) {
      return _DeadlineBadge(
        label: l10n.text('deadline_today'),
        color: const Color(0xFFE53935),
        icon: Icons.alarm_rounded,
        pulsing: true,
      );
    } else if (days <= 7) {
      return _DeadlineBadge(
        label: '$days ${days == 1 ? l10n.text('day_left') : l10n.text('days_left')}',
        color: const Color(0xFFFF5722),
        icon: Icons.hourglass_bottom_rounded,
        pulsing: true,
      );
    } else if (days <= 30) {
      return _DeadlineBadge(
        label: '$days ${l10n.text('days_left')}',
        color: const Color(0xFFFF9800),
        icon: Icons.schedule_rounded,
      );
    }
    // More than 30 days — subtle badge
    return _DeadlineBadge(
      label: '$days ${l10n.text('days_left')}',
      color: AppColors.primaryGreen,
      icon: Icons.event_available_rounded,
    );
  }

  // ── Share functionality ──────────────────────────────────────────────────────
  void _shareScheme(JsonScheme scheme, String languageCode, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final name = scheme.getLocalizedName(languageCode);
    final benefit = scheme.getLocalizedBenefit(languageCode);
    final deadline = scheme.getLocalizedDeadline(languageCode);
    final url = scheme.url;

    final text = languageCode == 'hi'
        ? '🌾 *$name*\n\n💰 लाभ: $benefit\n\n📅 आवेदन की तिथि: $deadline\n\n${url.isNotEmpty ? '🔗 अधिक जानकारी: $url\n\n' : ''}'
            '📲 किसान सेतु ऐप से'
        : languageCode == 'mr'
        ? '🌾 *$name*\n\n💰 फायदा: $benefit\n\n📅 अर्जाची तारीख: $deadline\n\n${url.isNotEmpty ? '🔗 अधिक माहिती: $url\n\n' : ''}'
            '📲 किसान सेतु अॅपद्वारे'
        : '🌾 *$name*\n\n💰 Benefit: $benefit\n\n📅 Deadline: $deadline\n\n${url.isNotEmpty ? '🔗 More info: $url\n\n' : ''}'
            '📲 Via Kisan Setu App';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.text('scheme_shared'))),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSchemeCard(JsonScheme scheme, String languageCode, AppLocalizations l10n) {
    final deadlineBadge = _buildDeadlineBadge(scheme.getLocalizedDeadline(languageCode), l10n);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreenOverlay10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIconForScheme(scheme.icon),
                          color: AppColors.primaryGreen, size: 28),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scheme.getLocalizedName(languageCode),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scheme.getLocalizedBenefit(languageCode),
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                            child: Text(
                              scheme.getLocalizedCategory(languageCode),
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Share button
                    GestureDetector(
                      onTap: () => _shareScheme(scheme, languageCode, l10n),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreenOverlay10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.share_rounded,
                            color: AppColors.primaryGreen, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
                // Deadline badge row
                if (deadlineBadge != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const SizedBox(width: 4),
                    deadlineBadge,
                  ]),
                ],
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

// ── Skeleton shimmer box ──────────────────────────────────────────────────────

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Color.lerp(
              const Color(0xFFE0E0E0),
              const Color(0xFFF5F5F5),
              _anim.value,
            ),
          ),
        );
      },
    );
  }
}

// ── Deadline badge widget ─────────────────────────────────────────────────────

class _DeadlineBadge extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool pulsing;

  const _DeadlineBadge({
    required this.label,
    required this.color,
    required this.icon,
    this.pulsing = false,
  });

  @override
  State<_DeadlineBadge> createState() => _DeadlineBadgeState();
}

class _DeadlineBadgeState extends State<_DeadlineBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.pulsing) _ctrl.repeat(reverse: true);
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
        final opacity = widget.pulsing ? (0.75 + _anim.value * 0.25) : 1.0;
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 12, color: widget.color),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

