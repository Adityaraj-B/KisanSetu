import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/farmer_provider.dart';

class KccScreen extends StatefulWidget {
  const KccScreen({super.key});

  @override
  State<KccScreen> createState() => _KccScreenState();
}

class _KccScreenState extends State<KccScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ───────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _orbCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _cardScaleAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<double> _shimmerAnim;

  final ScrollController _scrollCtrl = ScrollController();

  // ── Tab state ───────────────────────────────────────────────
  int _activeTab = 0;
  final List<String> _tabLabels = ['Overview', 'Benefits', 'Eligibility', 'Process'];
  final List<String> _tabLabelsHi = ['अवलोकन', 'लाभ', 'पात्रता', 'प्रक्रिया'];
  final List<String> _tabLabelsMr = ['आढावा', 'फायदे', 'पात्रता', 'प्रक्रिया'];
  // 'none' → not applied | 'applied' → under review | 'approved' → card active
  String _kccStatus = 'none';

  double _landSize = 2.0;
  String _selectedCropType = 'Kharif';

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _orbCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    _fadeAnim     = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _cardScaleAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut));
    _cardFadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _shimmerAnim  = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _cardCtrl.forward());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _cardCtrl.dispose();
    _orbCtrl.dispose();
    _shimmerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _t(String en, String hi, String mr) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'hi') return hi;
    if (lang == 'mr') return mr;
    return en;
  }

  // ── KCC credit limit calculator ─────────────────────────────
  double _calcKccLimit(double annualIncome, double land) {
    // RBI formula: Scale of Finance × land + 20% maintenance
    final scaleOfFinance = _selectedCropType == 'Kharif' ? 55000.0 : 45000.0;
    final cropExpense  = land * scaleOfFinance;
    final maintenance  = cropExpense * 0.20;
    final allied       = 10000.0;
    final total        = cropExpense + maintenance + allied;
    return total.clamp(25000.0, 300000.0);
  }

  String _formatCurrency(double amt) {
    if (amt >= 100000) return '₹${(amt / 100000).toStringAsFixed(2)} L';
    if (amt >= 1000)   return '₹${(amt / 1000).toStringAsFixed(1)}K';
    return '₹${amt.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final farmer = context.watch<FarmerProvider>();
    final annualIncome = _getAnnualIncome(farmer.annualIncome);
    final land = farmer.landSizeAcres > 0 ? farmer.landSizeAcres : _landSize;
    final kccLimit = _calcKccLimit(annualIncome, land);
    final lang = Localizations.localeOf(context).languageCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F3),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Section ──────────────────────────────────
              _buildHeroSliver(kccLimit, annualIncome, land, lang),

              // ── KCC Physical Card (locked until approved) ─────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _buildKccCardSection(farmer, kccLimit, lang),
                ),
              ),

              // ── Quick Stats Row ───────────────────────────────
              SliverToBoxAdapter(child: _buildQuickStats(kccLimit, lang)),

              // ── Tab Navigation ────────────────────────────────
              SliverToBoxAdapter(child: _buildTabBar(lang)),

              // ── Tab Content ───────────────────────────────────
              SliverToBoxAdapter(child: _buildTabContent(lang, kccLimit, annualIncome, land, farmer)),

              // ── EMI Calculator ────────────────────────────────
              SliverToBoxAdapter(child: _buildCalculator(farmer, lang)),

              // ── Important Banks ───────────────────────────────
              SliverToBoxAdapter(child: _buildBanksList(lang)),

              // ── Bottom CTA ────────────────────────────────────
              SliverToBoxAdapter(child: _buildCta(lang)),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSliver(double kccLimit, double annualIncome, double land, String lang) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            // Gradient background
            AnimatedBuilder(
              animation: _orbCtrl,
              builder: (_, __) => CustomPaint(
                painter: _OrbBgPainter(t: _orbCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),
            // Back button + title
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('Kisan Credit Card', 'किसान क्रेडिट कार्ड', 'किसान क्रेडिट कार्ड'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                _t('Your Agricultural Credit Gateway', 'आपका कृषि ऋण द्वार', 'तुमचे कृषी कर्ज प्रवेशद्वार'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _GovtBadge(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Limit preview row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            label: _t('Your KCC Limit', 'आपकी KCC सीमा', 'तुमची KCC मर्यादा'),
                            value: _formatCurrency(kccLimit),
                            icon: Icons.credit_card_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroMetric(
                            label: _t('Interest Rate', 'ब्याज दर', 'व्याज दर'),
                            value: '4% p.a.',
                            icon: Icons.percent_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroMetric(
                            label: _t('Validity', 'वैधता', 'वैधता'),
                            value: '5 Years',
                            icon: Icons.calendar_today_rounded,
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

  Widget _buildKccCardSection(FarmerProvider farmer, double kccLimit, String lang) {
    if (_kccStatus == 'approved') {
      return _buildKccCardWidget(farmer, kccLimit);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLockedCard(kccLimit, lang),
        if (_kccStatus == 'applied') ...[
          const SizedBox(height: 12),
          _buildUnderReviewBanner(lang),
        ] else ...[
          const SizedBox(height: 12),
          _buildApplyButton(lang),
        ],
      ],
    );
  }

  // Greyed-out, blurred locked card
  Widget _buildLockedCard(double kccLimit, String lang) {
    return Transform.translate(
      offset: const Offset(0, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The card itself — desaturated & dimmed
          Opacity(
            opacity: 0.45,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5)],
                  stops: [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text('KisanSetu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
                              ]),
                              Row(children: [
                                Icon(Icons.wifi_rounded, color: Colors.white.withValues(alpha: 0.8), size: 20),
                                const SizedBox(width: 8),
                                _ChipWidget(),
                              ]),
                            ],
                          ),
                          const Spacer(),
                          const Text('•••• ••••', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                          const SizedBox(height: 4),
                          Text(_t('Credit Limit', 'क्रेडिट सीमा', 'क्रेडिट मर्यादा'),
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75), letterSpacing: 0.5)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FARMER NAME', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                              Text('4% p.a.', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lock overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _kccStatus == 'applied'
                            ? _t('Under Review', 'समीक्षा में है', 'आढाव्यात आहे')
                            : _t('Card Not Issued', 'कार्ड जारी नहीं', 'कार्ड जारी नाही'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, shadows: [Shadow(blurRadius: 8, color: Colors.black38)]),
                      ),
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

  // Under-review status banner
  Widget _buildUnderReviewBanner(String lang) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCA28), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF9A825), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Application Under Review', 'आवेदन समीक्षा में है', 'अर्ज आढाव्यात आहे'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 2),
                Text(
                  _t('Your KCC application is being reviewed by the bank. This usually takes 7–10 working days.',
                      'आपका KCC आवेदन बैंक द्वारा समीक्षा किया जा रहा है। इसमें सामान्यतः 7–10 कार्य दिवस लगते हैं।',
                      'तुमचा KCC अर्ज बँकेद्वारे तपासला जात आहे. यास साधारणतः 7–10 कामाचे दिवस लागतात.'),
                  style: TextStyle(fontSize: 11.5, color: Colors.brown[400], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Apply button
  Widget _buildApplyButton(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showApplyBottomSheet(context, lang),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(
            _t('Apply for KCC', 'KCC के लिए आवेदन करें', 'KCC साठी अर्ज करा'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet for KCC Application ───────────────────────
  void _showApplyBottomSheet(BuildContext context, String lang) {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController();
    final _mobileCtrl = TextEditingController();
    final _aadhaarCtrl = TextEditingController();
    final _landCtrl = TextEditingController();
    String _selectedBank = 'State Bank of India';
    final banks = ['State Bank of India', 'Punjab National Bank', 'Bank of Baroda', 'NABARD', 'Cooperative Bank'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(ctx),
            child: DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return GestureDetector(
                  onTap: () {}, // absorb taps inside sheet so they don't bubble up
                  child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Handle
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.credit_card_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              _t('KCC Application', 'KCC आवेदन', 'KCC अर्ज'),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(
                            _t('Fill in your details. Your card will be issued after bank review.',
                                'अपना विवरण भरें। बैंक समीक्षा के बाद आपका कार्ड जारी किया जाएगा।',
                                'तुमचे तपशील भरा. बँक समीक्षेनंतर तुमचे कार्ड जारी केले जाईल.'),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    // Form
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          children: [
                            _AppFormField(
                              controller: _nameCtrl,
                              label: _t('Full Name', 'पूरा नाम', 'पूर्ण नाव'),
                              hint: _t('As per Aadhaar', 'आधार अनुसार', 'आधारनुसार'),
                              icon: Icons.person_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty) ? _t('Required', 'आवश्यक है', 'आवश्यक आहे') : null,
                            ),
                            const SizedBox(height: 16),
                            _AppFormField(
                              controller: _mobileCtrl,
                              label: _t('Mobile Number', 'मोबाइल नंबर', 'मोबाइल नंबर'),
                              hint: '10-digit number',
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().length != 10) return _t('Enter valid 10-digit number', '10 अंकों का नंबर दर्ज करें', '10 अंकी नंबर टाका');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _AppFormField(
                              controller: _aadhaarCtrl,
                              label: _t('Aadhaar Number', 'आधार नंबर', 'आधार नंबर'),
                              hint: '12-digit Aadhaar',
                              icon: Icons.badge_rounded,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().length != 12) return _t('Enter valid 12-digit Aadhaar', '12 अंकों का आधार दर्ज करें', '12 अंकी आधार टाका');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _AppFormField(
                              controller: _landCtrl,
                              label: _t('Land Size (acres)', 'भूमि आकार (एकड़)', 'जमीन आकार (एकर)'),
                              hint: 'e.g. 2.5',
                              icon: Icons.landscape_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || double.tryParse(v) == null) return _t('Enter valid land size', 'मान्य भूमि आकार दर्ज करें', 'वैध जमीन आकार टाका');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Bank dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_t('Preferred Bank', 'पसंदीदा बैंक', 'पसंतीचे बँक'),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFCEE0CF)),
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFFF7FBF7),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedBank,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2E7D32)),
                                      items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
                                      onChanged: (v) => setSheetState(() => _selectedBank = v!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // Info note
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _t('After submission, your application will be reviewed by the selected bank within 7–10 working days. You will be notified once your KCC is issued.',
                                          'जमा करने के बाद, आपका आवेदन चयनित बैंक द्वारा 7–10 कार्य दिवसों में समीक्षा किया जाएगा।',
                                          'सादर केल्यानंतर, तुमचा अर्ज निवडलेल्या बँकेद्वारे 7–10 कामाच्या दिवसांत तपासला जाईल.'),
                                      style: TextStyle(fontSize: 12, color: Colors.green[800], height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Submit
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pop(ctx);
                                  setState(() => _kccStatus = 'applied');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                _t('Submit Application', 'आवेदन जमा करें', 'अर्ज सादर करा'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ),   // inner GestureDetector child (Container)
              );     // inner GestureDetector (absorbs taps inside sheet)
            },       // DraggableScrollableSheet builder
          ),         // DraggableScrollableSheet
          );         // outer GestureDetector (closes on outside tap)
        });
      },
    );
  }

  Widget _buildKccCardWidget(FarmerProvider farmer, double kccLimit) {
    final name = farmer.fullName?.toUpperCase() ?? 'FARMER NAME';
    final aadhaar = farmer.maskedAadhaar.isNotEmpty ? farmer.maskedAadhaar : '**** **** ****';
    final bank = farmer.bankName ?? 'State Bank of India';

    return Transform.translate(
      offset: const Offset(0, 10),
      child: ScaleTransition(
        scale: _cardScaleAnim,
        child: FadeTransition(
          opacity: _cardFadeAnim,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Shimmer sweep
                  AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) => Positioned.fill(
                      child: CustomPaint(
                        painter: _ShimmerPainter(position: _shimmerAnim.value),
                      ),
                    ),
                  ),
                  // Background orb circles
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: logo + chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'KisanSetu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            // NFC + chip icon
                            Row(
                              children: [
                                Icon(Icons.wifi_rounded,
                                    color: Colors.white.withValues(alpha: 0.8), size: 20),
                                const SizedBox(width: 8),
                                _ChipWidget(),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // KCC Limit
                        Text(
                          _formatCurrency(kccLimit),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _t('Credit Limit', 'क्रेडिट सीमा', 'क्रेडिट मर्यादा'),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Bottom row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  aadhaar,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  bank,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '4% p.a.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(double kccLimit, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
      child: Row(
        children: [
          Expanded(child: _StatCard(
            icon: Icons.percent_rounded,
            iconColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            value: '4%',
            label: _t('Interest', 'ब्याज', 'व्याज'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: const Color(0xFF0277BD),
            bgColor: const Color(0xFFE3F2FD),
            value: '5 Yr',
            label: _t('Validity', 'वैधता', 'वैधता'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: Icons.lock_open_rounded,
            iconColor: const Color(0xFFFF8F00),
            bgColor: const Color(0xFFFFF3E0),
            value: '₹1.6 Lakh',
            label: _t('No Collateral', 'बिना गारंटी', 'बिना तारण'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: Icons.flash_on_rounded,
            iconColor: const Color(0xFF7B1FA2),
            bgColor: const Color(0xFFF3E5F5),
            value: '7%',
            label: _t('Subvention', 'सब्सिडी', 'अनुदान'),
          )),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  TAB BAR
  // ────────────────────────────────────────────────────────────
  Widget _buildTabBar(String lang) {
    final labels = lang == 'hi' ? _tabLabelsHi : (lang == 'mr' ? _tabLabelsMr : _tabLabels);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _activeTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: selected
                      ? [BoxShadow(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  TAB CONTENT
  // ────────────────────────────────────────────────────────────
  Widget _buildTabContent(String lang, double kccLimit, double income, double land, FarmerProvider farmer) {
    switch (_activeTab) {
      case 0: return _buildOverviewTab(lang, kccLimit, income, land);
      case 1: return _buildBenefitsTab(lang);
      case 2: return _buildEligibilityTab(lang, farmer);
      case 3: return _buildProcessTab(lang);
      default: return const SizedBox.shrink();
    }
  }

  // ── OVERVIEW TAB ─────────────────────────────────────────────
  Widget _buildOverviewTab(String lang, double kccLimit, double income, double land) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: _t('What is KCC?', 'KCC क्या है?', 'KCC म्हणजे काय?')),
          const SizedBox(height: 12),
          _GlassCard(
            child: Text(
              _t(
                'Kisan Credit Card (KCC) is a revolutionary credit scheme launched by the Government of India in 1998. It provides farmers with affordable and timely access to credit for agricultural and allied activities. The scheme is implemented by all scheduled commercial banks, cooperative banks, and regional rural banks across India.',
                'किसान क्रेडिट कार्ड (KCC) भारत सरकार द्वारा 1998 में शुरू की गई एक क्रांतिकारी ऋण योजना है। यह किसानों को कृषि और संबद्ध गतिविधियों के लिए किफायती और समय पर ऋण प्रदान करती है।',
                'किसान क्रेडिट कार्ड (KCC) ही भारत सरकारने 1998 मध्ये सुरू केलेली एक क्रांतिकारी कर्ज योजना आहे. यामुळे शेतकऱ्यांना शेती व संलग्न कामांसाठी परवडणारे कर्ज मिळते.',
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: _t('Your Credit Breakdown', 'आपका ऋण विवरण', 'तुमचे कर्ज विश्लेषण')),
          const SizedBox(height: 12),
          _buildCreditBreakdown(kccLimit, lang),
          const SizedBox(height: 20),
          _SectionTitle(title: _t('Interest Subvention', 'ब्याज सब्सिडी', 'व्याज अनुदान')),
          const SizedBox(height: 12),
          _buildInterestBreakdown(lang),
          const SizedBox(height: 20),
          _SectionTitle(title: _t('Withdrawal Modes', 'निकासी के तरीके', 'पैसे काढण्याचे मार्ग')),
          const SizedBox(height: 12),
          _buildWithdrawalModes(lang),
        ],
      ),
    );
  }

  Widget _buildCreditBreakdown(double kccLimit, String lang) {
    final scaleOfFinance = _selectedCropType == 'Kharif' ? 55000.0 : 45000.0;
    final farmer = context.read<FarmerProvider>();
    final land = farmer.landSizeAcres > 0 ? farmer.landSizeAcres : 2.0;
    final cropComponent  = (land * scaleOfFinance).clamp(0.0, 300000.0);
    final maintenance    = cropComponent * 0.20;
    const allied         = 10000.0;

    final items = [
      (_t('Crop Cultivation Component', 'फसल खेती घटक', 'पीक लागवड घटक'),
       cropComponent, const Color(0xFF2E7D32)),
      (_t('Maintenance / Post-Harvest', 'रख-रखाव / कटाई के बाद', 'देखभाल / काढणीनंतर'),
       maintenance, const Color(0xFF00897B)),
      (_t('Allied Activities', 'संबद्ध गतिविधियाँ', 'संलग्न उपक्रम'),
       allied, const Color(0xFF0277BD)),
    ];

    return _GlassCard(
      child: Column(
        children: [
          ...items.map((item) {
            final (label, amount, color) = item;
            final fraction = kccLimit > 0 ? amount / kccLimit : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                        ],
                      ),
                      Text(
                        _formatCurrency(amount),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_t('Total KCC Limit', 'कुल KCC सीमा', 'एकूण KCC मर्यादा'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
              Text(_formatCurrency(kccLimit),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestBreakdown(String lang) {
    return _GlassCard(
      child: Column(
        children: [
          _InterestRow(
            label: _t('Normal KCC Interest', 'सामान्य KCC ब्याज', 'सामान्य KCC व्याज'),
            rate: '9%',
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          _InterestRow(
            label: _t('Govt. Subvention (2%)', 'सरकारी सब्सिडी (2%)', 'सरकारी अनुदान (2%)'),
            rate: '-2%',
            color: const Color(0xFF00897B),
            isDeduction: true,
          ),
          const SizedBox(height: 10),
          _InterestRow(
            label: _t('Prompt Repayment Bonus (3%)', 'समय पर चुकाने पर (3%)', 'वेळेवर भरल्यास (3%)'),
            rate: '-3%',
            color: const Color(0xFF2E7D32),
            isDeduction: true,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('Effective Rate', 'प्रभावी दर', 'प्रभावी दर'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1F)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '4% p.a.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalModes(String lang) {
    final modes = [
      (Icons.credit_card_rounded, _t('RuPay Debit Card', 'रुपे डेबिट कार्ड', 'रुपे डेबिट कार्ड'), const Color(0xFF2E7D32)),
      (Icons.atm_rounded,         _t('ATM Withdrawal', 'ATM निकासी', 'ATM काढणे'),                  const Color(0xFF0277BD)),
      (Icons.account_balance_rounded, _t('Branch / PoS',  'शाखा / PoS',  'शाखा / PoS'),            const Color(0xFFFF8F00)),
      (Icons.phone_android_rounded, _t('Mobile Banking', 'मोबाइल बैंकिंग', 'मोबाइल बँकिंग'),        const Color(0xFF7B1FA2)),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: modes.map((m) {
        final (icon, label, color) = m;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]))),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── BENEFITS TAB ─────────────────────────────────────────────
  Widget _buildBenefitsTab(String lang) {
    final benefits = [
      _BenefitItem(
        icon: Icons.currency_rupee_rounded,
        color: const Color(0xFF2E7D32),
        title: _t('Low Interest @ 4% p.a.', 'कम ब्याज @ 4% प्रति वर्ष', 'कमी व्याज @ 4% प्रतिवर्ष'),
        desc: _t(
          'After 2% govt. subvention + 3% prompt repayment bonus, effective interest is just 4% per annum — among the lowest in the world for farmers.',
          'सरकार की 2% सब्सिडी और 3% समय पर भुगतान बोनस के बाद, प्रभावी ब्याज केवल 4% प्रति वर्ष है।',
          'सरकारी 2% अनुदान + 3% वेळेवर परतफेड बोनस नंतर, प्रभावी व्याज फक्त 4% प्रतिवर्ष आहे.',
        ),
      ),
      _BenefitItem(
        icon: Icons.lock_open_rounded,
        color: const Color(0xFF0277BD),
        title: _t('No Collateral Up to ₹1.6 Lakh', '₹1.6 लाख तक बिना गारंटी', '₹1.6 लाख पर्यंत तारण नाही'),
        desc: _t(
          'Farmers with KCC limits up to ₹1.6 lakh are not required to provide any collateral security. This makes it accessible for small and marginal farmers.',
          '₹1.6 लाख तक की KCC सीमा वाले किसानों को कोई संपार्श्विक सुरक्षा नहीं देनी होगी।',
          '₹1.6 लाख पर्यंत KCC मर्यादा असलेल्या शेतकऱ्यांना तारण द्यावे लागत नाही.',
        ),
      ),
      _BenefitItem(
        icon: Icons.refresh_rounded,
        color: const Color(0xFF00897B),
        title: _t('Revolving Credit (Like ATM)', 'रिवॉल्विंग क्रेडिट (ATM जैसा)', 'रिव्हॉल्विंग क्रेडिट (ATM सारखे)'),
        desc: _t(
          'KCC works like a revolving credit facility — repay and withdraw again within the sanctioned limit. No need to apply for a fresh loan each season.',
          'KCC एक रिवॉल्विंग क्रेडिट सुविधा की तरह काम करता है — चुकाएं और स्वीकृत सीमा के भीतर फिर से निकालें।',
          'KCC रिव्हॉल्विंग क्रेडिट सुविधेसारखे काम करते — परत करा आणि मंजूर मर्यादेत पुन्हा काढा.',
        ),
      ),
      _BenefitItem(
        icon: Icons.shield_rounded,
        color: const Color(0xFFFF8F00),
        title: _t('Free Crop Insurance Cover', 'मुफ्त फसल बीमा कवर', 'मोफत पीक विमा संरक्षण'),
        desc: _t(
          'KCC holders automatically get crop insurance under PMFBY at subsidised premiums. Personal accident insurance of ₹50,000 is also included.',
          'KCC धारकों को स्वचालित रूप से PMFBY के तहत सब्सिडी वाले प्रीमियम पर फसल बीमा मिलता है।',
          'KCC धारकांना PMFBY अंतर्गत अनुदानित प्रीमियमवर पीक विमा आपोआप मिळतो.',
        ),
      ),
      _BenefitItem(
        icon: Icons.people_rounded,
        color: const Color(0xFF7B1FA2),
        title: _t('Covers All Farmers', 'सभी किसानों के लिए', 'सर्व शेतकऱ्यांसाठी'),
        desc: _t(
          'Owner cultivators, tenant farmers, oral lessees, share croppers, and Self-Help Groups (SHGs) are all eligible for KCC.',
          'मालिक किसान, काश्तकार किसान, मौखिक पट्टेदार, बटाईदार और स्वयं-सहायता समूह (SHGs) सभी KCC के लिए पात्र हैं।',
          'मालक शेतकरी, भाडेकरू शेतकरी, तोंडी भाडेकरू, वाटेकरी आणि बचत गट (SHGs) सर्व KCC साठी पात्र आहेत.',
        ),
      ),
      _BenefitItem(
        icon: Icons.update_rounded,
        color: const Color(0xFFE53935),
        title: _t('5-Year Renewable Limit', '5 साल की नवीकरणीय सीमा', '5 वर्षांची नूतनीकरणीय मर्यादा'),
        desc: _t(
          'KCC is issued for 5 years. The credit limit automatically gets revised upward each year at 10% of short-term credit to cover increased cultivation costs.',
          'KCC 5 साल के लिए जारी की जाती है। ऋण सीमा हर साल बढ़ती खेती लागत को कवर करने के लिए अल्पकालिक ऋण के 10% पर स्वचालित रूप से बढ़ती है।',
          'KCC 5 वर्षांसाठी जारी केले जाते. वाढत्या लागवड खर्चाला सामोरे जाण्यासाठी दरवर्षी क्रेडिट मर्यादा 10% ने वाढते.',
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: _t('Key Benefits of KCC', 'KCC के मुख्य लाभ', 'KCC चे मुख्य फायदे')),
          const SizedBox(height: 12),
          ...benefits.asMap().entries.map((e) => _buildBenefitCard(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(_BenefitItem item, int idx) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + idx * 80),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: item.color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
          border: Border(left: BorderSide(color: item.color, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                  const SizedBox(height: 5),
                  Text(item.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ELIGIBILITY TAB ──────────────────────────────────────────
  Widget _buildEligibilityTab(String lang, FarmerProvider farmer) {
    final checks = [
      _EligibilityCheck(
        title: _t('Indian Citizen Farmer', 'भारतीय नागरिक किसान', 'भारतीय नागरिक शेतकरी'),
        status: true,
        detail: _t('All individual farmers, joint borrowers, tenant farmers', 'सभी व्यक्तिगत किसान, संयुक्त उधारकर्ता, काश्तकार', 'सर्व वैयक्तिक शेतकरी, संयुक्त कर्जदार, भाडेकरू'),
      ),
      _EligibilityCheck(
        title: _t('Aadhaar Linked', 'आधार लिंक', 'आधार लिंक'),
        status: farmer.hasAadhaar,
        detail: farmer.hasAadhaar
            ? _t('Aadhaar linked ✓', 'आधार लिंक है ✓', 'आधार लिंक आहे ✓')
            : _t('Please update Aadhaar in profile', 'प्रोफाइल में आधार अपडेट करें', 'प्रोफाइलमध्ये आधार अपडेट करा'),
      ),
      _EligibilityCheck(
        title: _t('Bank Account', 'बैंक खाता', 'बँक खाते'),
        status: farmer.hasBankDetails,
        detail: farmer.hasBankDetails
            ? _t('Bank details linked ✓', 'बैंक विवरण लिंक है ✓', 'बँक तपशील लिंक आहे ✓')
            : _t('Please add bank details in profile', 'प्रोफाइल में बैंक विवरण जोड़ें', 'प्रोफाइलमध्ये बँक तपशील जोडा'),
      ),
      _EligibilityCheck(
        title: _t('Land Records', 'भूमि अभिलेख', 'जमीन नोंदी'),
        status: farmer.hasSevenTwelve,
        detail: farmer.hasSevenTwelve
            ? _t('7/12 extract available ✓', '7/12 उतारा उपलब्ध ✓', '7/12 उतारा उपलब्ध ✓')
            : _t('7/12 extract / RoR / Patta required', '7/12 उतारा / RoR / पट्टा आवश्यक', '7/12 उतारा / RoR / पट्टा आवश्यक'),
      ),
      _EligibilityCheck(
        title: _t('Age 18–75 Years', 'आयु 18–75 वर्ष', 'वय 18–75 वर्षे'),
        status: true,
        detail: _t('No upper limit for existing farmers with joint borrowers', 'संयुक्त उधारकर्ताओं के साथ मौजूदा किसानों के लिए कोई ऊपरी सीमा नहीं', 'संयुक्त कर्जदारांसह विद्यमान शेतकऱ्यांसाठी वयाची कमाल मर्यादा नाही'),
      ),
    ];

    final docsRequired = [
      _t('Application form (from bank branch)', 'आवेदन फॉर्म (बैंक शाखा से)', 'अर्ज फॉर्म (बँक शाखेतून)'),
      _t('Identity proof (Aadhaar/Voter ID/PAN)', 'पहचान प्रमाण (आधार/वोटर ID/PAN)', 'ओळखीचा पुरावा (आधार/मतदार ओळखपत्र/PAN)'),
      _t('Address proof (Aadhaar/Utility bill)', 'पता प्रमाण (आधार/बिल)', 'पत्त्याचा पुरावा (आधार/युटिलिटी बिल)'),
      _t('Land records (7/12 / RoR / Patta)', 'भूमि अभिलेख (7/12 / RoR / पट्टा)', 'जमीन नोंदी (7/12 / RoR / पट्टा)'),
      _t('Passport-size photographs (2)', 'पासपोर्ट साइज फोटो (2)', 'पासपोर्ट आकाराचे फोटो (2)'),
      _t('Crop cultivation certificate', 'फसल खेती प्रमाण पत्र', 'पीक लागवड प्रमाणपत्र'),
      _t('Security documents (for >₹1.6L limit)', 'सुरक्षा दस्तावेज (₹1.6L से अधिक के लिए)', 'सुरक्षा कागदपत्रे (₹1.6L पेक्षा जास्त मर्यादेसाठी)'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: _t('Your Eligibility Check', 'आपकी पात्रता जाँच', 'तुमची पात्रता तपासणी')),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              children: checks.asMap().entries.map((e) {
                final check = e.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: e.key < checks.length - 1 ? 12 : 0),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: check.status
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                              : const Color(0xFFFF8F00).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          check.status ? Icons.check_rounded : Icons.info_outline_rounded,
                          color: check.status ? const Color(0xFF2E7D32) : const Color(0xFFFF8F00),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(check.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
                            Text(check.detail, style: const TextStyle(fontSize: 12, color: Color(0xFF777777))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: _t('Documents Required', 'आवश्यक दस्तावेज', 'आवश्यक कागदपत्रे')),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              children: docsRequired.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < docsRequired.length - 1 ? 10 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 7, height: 7,
                      decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROCESS TAB ──────────────────────────────────────────────
  Widget _buildProcessTab(String lang) {
    final steps = [
      _ProcessStep(
        step: 1,
        icon: Icons.person_search_rounded,
        color: const Color(0xFF2E7D32),
        title: _t('Choose Your Bank', 'अपना बैंक चुनें', 'तुमची बँक निवडा'),
        desc: _t(
          'Visit the nearest branch of any nationalised bank, cooperative bank, or regional rural bank (RRB). You can also apply online via the bank\'s official website.',
          'किसी भी राष्ट्रीयकृत बैंक, सहकारी बैंक या क्षेत्रीय ग्रामीण बैंक (RRB) की निकटतम शाखा में जाएं।',
          'कोणत्याही राष्ट्रीयकृत बँक, सहकारी बँक किंवा प्रादेशिक ग्रामीण बँकेच्या जवळच्या शाखेला भेट द्या.',
        ),
        duration: _t('Day 1', 'पहला दिन', 'पहिला दिवस'),
      ),
      _ProcessStep(
        step: 2,
        icon: Icons.assignment_rounded,
        color: const Color(0xFF0277BD),
        title: _t('Fill Application Form', 'आवेदन फॉर्म भरें', 'अर्ज फॉर्म भरा'),
        desc: _t(
          'Collect and fill the KCC application form. Mention your land holdings, crops to be grown, and estimated production for the current season.',
          'KCC आवेदन फॉर्म एकत्र करें और भरें। अपनी भूमि जोत, उगाई जाने वाली फसलें और वर्तमान मौसम के लिए अनुमानित उत्पादन का उल्लेख करें।',
          'KCC अर्ज फॉर्म घ्या आणि भरा. जमीन धारणा, घेतले जाणारे पीक आणि अंदाजित उत्पादन नमूद करा.',
        ),
        duration: _t('Day 1–2', 'पहला-दूसरा दिन', 'पहिला-दुसरा दिवस'),
      ),
      _ProcessStep(
        step: 3,
        icon: Icons.folder_copy_rounded,
        color: const Color(0xFF00897B),
        title: _t('Submit Documents', 'दस्तावेज जमा करें', 'कागदपत्रे सादर करा'),
        desc: _t(
          'Submit all required documents: Aadhaar, PAN/Voter ID, land records (7/12), passport photos, and crop cultivation certificate with your application.',
          'सभी आवश्यक दस्तावेज जमा करें: आधार, पैन/वोटर ID, भूमि अभिलेख (7/12), पासपोर्ट फोटो और फसल खेती प्रमाण पत्र।',
          'सर्व आवश्यक कागदपत्रे सादर करा: आधार, PAN/मतदार ओळखपत्र, जमीन नोंदी (7/12), पासपोर्ट फोटो आणि पीक प्रमाणपत्र.',
        ),
        duration: _t('Day 2–3', 'दूसरा-तीसरा दिन', 'दुसरा-तिसरा दिवस'),
      ),
      _ProcessStep(
        step: 4,
        icon: Icons.verified_rounded,
        color: const Color(0xFFFF8F00),
        title: _t('Bank Verification & Appraisal', 'बैंक सत्यापन और मूल्यांकन', 'बँक पडताळणी व मूल्यांकन'),
        desc: _t(
          'The bank verifies your documents and conducts field inspection (for large limits). Credit limit is calculated based on land size, crop type, and scale of finance.',
          'बैंक आपके दस्तावेजों की जांच करता है और क्षेत्र निरीक्षण करता है। ऋण सीमा भूमि आकार, फसल प्रकार और वित्त के पैमाने के आधार पर गणना की जाती है।',
          'बँक कागदपत्रे पडताळते आणि क्षेत्र तपासणी करते. क्रेडिट मर्यादा जमीन आकार, पीक प्रकार आणि वित्त प्रमाण यावर आधारित मोजली जाते.',
        ),
        duration: _t('Day 3–7', 'तीसरा-सातवां दिन', 'तिसरा-सातवा दिवस'),
      ),
      _ProcessStep(
        step: 5,
        icon: Icons.how_to_vote_rounded,
        color: const Color(0xFF7B1FA2),
        title: _t('Sanction & Card Issuance', 'स्वीकृति और कार्ड जारी', 'मंजुरी आणि कार्ड जारी'),
        desc: _t(
          'Upon approval, the KCC limit is sanctioned and a RuPay debit card linked to your KCC account is issued. You can immediately start using it at ATMs, PoS terminals, and online.',
          'अनुमोदन पर, KCC सीमा को मंजूरी दी जाती है और आपके KCC खाते से जुड़ा एक रुपे डेबिट कार्ड जारी किया जाता है।',
          'मंजुरी मिळाल्यावर KCC मर्यादा मंजूर केली जाते आणि RuPay डेबिट कार्ड जारी केले जाते.',
        ),
        duration: _t('Day 7–14', 'सातवां-14वां दिन', 'सातवा-14वा दिवस'),
      ),
      _ProcessStep(
        step: 6,
        icon: Icons.loop_rounded,
        color: const Color(0xFFE53935),
        title: _t('Repayment & Renewal', 'चुकाना और नवीनीकरण', 'परतफेड आणि नूतनीकरण'),
        desc: _t(
          'Repay within 12 months of withdrawal (aligned with crop cycle). For prompt repayment, you get the additional 3% interest subvention. KCC auto-renews every year within the 5-year validity.',
          'निकासी के 12 महीनों के भीतर चुकाएं (फसल चक्र के अनुरूप)। समय पर चुकाने पर आपको अतिरिक्त 3% ब्याज सब्सिडी मिलती है।',
          'काढणीच्या 12 महिन्यांत परतफेड करा (पीक चक्राशी संरेखित). वेळेवर परतफेड केल्यास अतिरिक्त 3% व्याज अनुदान मिळते.',
        ),
        duration: _t('Annually', 'प्रतिवर्ष', 'दरवर्षी'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: _t('Step-by-Step Process', 'चरण-दर-चरण प्रक्रिया', 'टप्प्याटप्प्याने प्रक्रिया')),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((e) => _buildProcessStep(e.value, e.key, steps.length)),
        ],
      ),
    );
  }

  Widget _buildProcessStep(_ProcessStep step, int idx, int total) {
    final isLast = idx == total - 1;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + idx * 100),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [step.color, step.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: step.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Icon(step.icon, color: Colors.white, size: 20),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [step.color.withValues(alpha: 0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: step.color.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(step.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: step.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(step.duration, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: step.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(step.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  EMI CALCULATOR SECTION
  // ────────────────────────────────────────────────────────────
  Widget _buildCalculator(FarmerProvider farmer, String lang) {
    final land = farmer.landSizeAcres > 0 ? farmer.landSizeAcres : _landSize;
    final kccLimit = _calcKccLimit(_getAnnualIncome(farmer.annualIncome), land);
    final monthlyInterest = kccLimit * (0.04 / 12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
              blurRadius: 24, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('KCC Interest Calculator', 'KCC ब्याज कैलकुलेटर', 'KCC व्याज कॅल्क्युलेटर'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            _t('Based on your profile', 'आपके प्रोफाइल के आधार पर', 'तुमच्या प्रोफाइलनुसार'),
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Crop type toggle
                  Row(
                    children: [
                      Text(_t('Crop Season:', 'फसल मौसम:', 'पीक हंगाम:'),
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                      const SizedBox(width: 10),
                      _buildCropTypeToggle(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _CalcMetric(
                        label: _t('Your Limit', 'आपकी सीमा', 'तुमची मर्यादा'),
                        value: _formatCurrency(kccLimit),
                      )),
                      Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
                      Expanded(child: _CalcMetric(
                        label: _t('Monthly Interest', 'मासिक ब्याज', 'मासिक व्याज'),
                        value: _formatCurrency(monthlyInterest),
                      )),
                      Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
                      Expanded(child: _CalcMetric(
                        label: _t('Annual Interest', 'वार्षिक ब्याज', 'वार्षिक व्याज'),
                        value: _formatCurrency(kccLimit * 0.04),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Savings vs market rate
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _t(
                              'You save ₹${_formatCurrency(kccLimit * 0.14)} per year vs 18% market rate!',
                              'आप 18% बाज़ार दर की तुलना में प्रतिवर्ष ${_formatCurrency(kccLimit * 0.14)} बचाते हैं!',
                              'तुम्ही 18% बाजार दराच्या तुलनेत दरवर्षी ${_formatCurrency(kccLimit * 0.14)} वाचवता!',
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
      ),
    );
  }

  Widget _buildCropTypeToggle() {
    final types = ['Kharif', 'Rabi'];
    return Row(
      children: types.map((type) {
        final selected = _selectedCropType == type;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedCropType = type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF2E7D32) : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  BANKS LIST
  // ────────────────────────────────────────────────────────────
  Widget _buildBanksList(String lang) {
    final banks = [
      _BankItem('State Bank of India', Icons.account_balance_rounded, const Color(0xFF2E7D32), '1800-11-2211'),
      _BankItem('Punjab National Bank', Icons.account_balance_rounded, const Color(0xFF1565C0), '1800-180-2222'),
      _BankItem('Bank of Baroda', Icons.account_balance_rounded, const Color(0xFFFF8F00), '1800-258-4455'),
      _BankItem('NABARD (Refinance)', Icons.agriculture_rounded, const Color(0xFF7B1FA2), '1800-26-7789'),
      _BankItem('Co-operative Banks', Icons.handshake_rounded, const Color(0xFF00897B), '—'),
      _BankItem('Regional Rural Banks', Icons.location_city_rounded, const Color(0xFFE53935), '—'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: _t('Banks Offering KCC', 'KCC देने वाले बैंक', 'KCC देणाऱ्या बँका')),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: banks.length,
            itemBuilder: (_, i) {
              final b = banks[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: b.color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: b.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(b.icon, color: b.color, size: 18),
                    ),
                    const Spacer(),
                    Text(b.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F)), maxLines: 2),
                    if (b.helpline != '—') ...[
                      const SizedBox(height: 3),
                      Text(b.helpline, style: TextStyle(fontSize: 10, color: b.color, fontWeight: FontWeight.w500)),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  BOTTOM CTA
  // ────────────────────────────────────────────────────────────
  Widget _buildCta(String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _t('PM Kisan Credit Card Helpline', 'पीएम किसान क्रेडिट कार्ड हेल्पलाइन', 'पीएम किसान क्रेडिट कार्ड हेल्पलाइन'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _CtaButton(
                      icon: Icons.phone_rounded,
                      label: _t('Call Helpline', 'हेल्पलाइन कॉल', 'हेल्पलाइन कॉल करा'),
                      sublabel: '1800-180-1551',
                      color: const Color(0xFF2E7D32),
                      onTap: () => HapticFeedback.lightImpact(),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _CtaButton(
                      icon: Icons.language_rounded,
                      label: _t('Apply Online', 'ऑनलाइन आवेदन', 'ऑनलाइन अर्ज'),
                      sublabel: 'pmkisan.gov.in',
                      color: const Color(0xFF0277BD),
                      onTap: () => HapticFeedback.lightImpact(),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Disclaimer
          Text(
            _t(
              '* Credit limit is indicative, based on RBI Scale of Finance. Actual limit is determined by your bank.',
              '* क्रेडिट सीमा संकेतात्मक है, RBI वित्त के पैमाने पर आधारित है। वास्तविक सीमा आपके बैंक द्वारा निर्धारित की जाती है।',
              '* क्रेडिट मर्यादा सूचक आहे, RBI वित्त प्रमाणावर आधारित. वास्तविक मर्यादा तुमच्या बँकेद्वारे निश्चित केली जाते.',
            ),
            style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  HELPERS
  // ────────────────────────────────────────────────────────────
  double _getAnnualIncome(String? incomeRange) {
    switch (incomeRange) {
      case 'below_1_lakh':     return 75000;
      case '1_to_2.5_lakh':   return 175000;
      case '2.5_to_5_lakh':   return 375000;
      case '5_to_10_lakh':    return 750000;
      case 'above_10_lakh':   return 1500000;
      default:                return 200000;
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  DATA MODELS
// ════════════════════════════════════════════════════════════════

class _BenefitItem {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _BenefitItem({required this.icon, required this.color, required this.title, required this.desc});
}

class _EligibilityCheck {
  final String title;
  final bool status;
  final String detail;
  const _EligibilityCheck({required this.title, required this.status, required this.detail});
}

class _ProcessStep {
  final int step;
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String duration;
  const _ProcessStep({required this.step, required this.icon, required this.color, required this.title, required this.desc, required this.duration});
}

class _BankItem {
  final String name;
  final IconData icon;
  final Color color;
  final String helpline;
  const _BankItem(this.name, this.icon, this.color, this.helpline);
}

// ════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ════════════════════════════════════════════════════════════════

class _OrbBgPainter extends CustomPainter {
  final double t;
  _OrbBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1565C0)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Orbs
    final orbData = [
      (0.15, 0.25, 70.0, 0.0,   const Color(0xFF4CAF50)),
      (0.80, 0.10, 55.0, 1.0,   const Color(0xFF81C784)),
      (0.60, 0.70, 50.0, 2.0,   const Color(0xFF42A5F5)),
      (0.05, 0.75, 45.0, 0.5,   const Color(0xFF66BB6A)),
    ];

    for (final orb in orbData) {
      final (bx, by, br, phase, color) = orb;
      final angle = t * math.pi * 2 + phase;
      final cx = size.width * bx  + math.cos(angle) * 12.0;
      final cy = size.height * by + math.sin(angle * 1.3) * 10.0;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: br));
      canvas.drawCircle(Offset(cx, cy), br, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbBgPainter old) => old.t != t;
}

class _ShimmerPainter extends CustomPainter {
  final double position;
  _ShimmerPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(position - 0.6, -0.5),
        end: Alignment(position + 0.6, 0.5),
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.position != position;
}

// ════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _GovtBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          const Text('RBI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeroMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.iconColor, required this.bgColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: iconColor.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: iconColor)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1C1B1F))),
      ],
    );
  }
}

class _InterestRow extends StatelessWidget {
  final String label;
  final String rate;
  final Color color;
  final bool isDeduction;
  const _InterestRow({required this.label, required this.rate, required this.color, this.isDeduction = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(isDeduction ? Icons.remove_circle_outline_rounded : Icons.circle_rounded,
              color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF444444)))),
        Text(rate, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _CalcMetric extends StatelessWidget {
  final String label;
  final String value;
  const _CalcMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)), textAlign: TextAlign.center),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;
  const _CtaButton({required this.icon, required this.label, required this.sublabel, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  Text(sublabel, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small EMV chip widget on the card
class _ChipWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 20,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.4)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), paint);
    canvas.drawLine(Offset(0, size.height * 0.67), Offset(size.width, size.height * 0.67), paint);
    // Vertical lines
    canvas.drawLine(Offset(size.width * 0.33, 0), Offset(size.width * 0.33, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.67, 0), Offset(size.width * 0.67, size.height), paint);
  }

  @override
  bool shouldRepaint(_ChipPainter old) => false;
}

// ── Application form field ───────────────────────────────────
class _AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AppFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            filled: true,
            fillColor: const Color(0xFFF7FBF7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCEE0CF))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCEE0CF))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }
}


