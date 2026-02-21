import 'package:flutter/material.dart';
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
                    _buildApplyButton(l10n, scheme.url),
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
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
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

  Widget _buildSchemeCard(JsonScheme scheme, String languageCode, AppLocalizations l10n) {
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

