import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/crop_finance_data.dart';

/// Premium Insurance Detail Screen - Full details when user taps "Get Insured"
class InsuranceDetailScreen extends StatefulWidget {
  final InsuranceData insurance;
  final String langCode;

  const InsuranceDetailScreen({
    super.key,
    required this.insurance,
    required this.langCode,
  });

  @override
  State<InsuranceDetailScreen> createState() => _InsuranceDetailScreenState();
}

class _InsuranceDetailScreenState extends State<InsuranceDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  String _t(String en, String hi, String mr) {
    if (widget.langCode == 'hi') return hi;
    if (widget.langCode == 'mr') return mr;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)} Lakh';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final ins = widget.insurance;
    final premiumAmount = ins.premiumPercentage > 0
        ? ins.sumInsured * (ins.premiumPercentage / 100)
        : 436.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero App Bar ───
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: ins.color,
              leading: _CircleBackButton(onTap: () => Navigator.pop(context)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [ins.color, ins.color.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Top badges
                          Row(
                            children: [
                              _Badge(
                                icon: Icons.verified_user_rounded,
                                text: _t('Government Scheme', 'सरकारी योजना', 'सरकारी योजना'),
                              ),
                              const SizedBox(width: 8),
                              _Badge(
                                icon: Icons.check_circle_rounded,
                                text: _t('Active', 'सक्रिय', 'सक्रिय'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            ins.getLocalizedName(widget.langCode),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ins.getLocalizedCoverage(widget.langCode),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Premium vs Coverage Display
                          Row(
                            children: [
                              Expanded(
                                child: _HeroInfoBox(
                                  label: _t('Sum Insured', 'बीमित राशि', 'विमित रक्कम'),
                                  value: _formatCurrency(ins.sumInsured),
                                  icon: Icons.shield_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _HeroInfoBox(
                                  label: _t('Your Premium', 'आपका प्रीमियम', 'आपला प्रीमियम'),
                                  value: ins.premiumPercentage > 0
                                      ? _formatCurrency(premiumAmount)
                                      : '₹436/yr',
                                  icon: Icons.payments_rounded,
                                ),
                              ),
                            ],
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Premium Breakdown ───
                    if (ins.premiumPercentage > 0) ...[
                      _SectionTitle(
                        icon: Icons.calculate_rounded,
                        title: _t('Premium Breakdown', 'प्रीमियम विवरण', 'प्रीमियम तपशील'),
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 12),
                      _PremiumBreakdownCard(
                        sumInsured: ins.sumInsured,
                        farmerPremium: premiumAmount,
                        govtSubsidy: ins.sumInsured - premiumAmount,
                        premiumPercent: ins.premiumPercentage,
                        langCode: widget.langCode,
                        color: ins.color,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ─── Overview ───
                    _SectionTitle(
                      icon: Icons.info_outline_rounded,
                      title: _t('About This Insurance', 'इस बीमा के बारे में', 'या विम्याबद्दल'),
                      color: ins.color,
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Text(
                        ins.getLocalizedDescription(widget.langCode),
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── What's Covered ───
                    _SectionTitle(
                      icon: Icons.shield_rounded,
                      title: _t('What\'s Covered', 'क्या कवर है', 'काय संरक्षित आहे'),
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 12),
                    ...ins.getLocalizedCoveredRisks(widget.langCode).asMap().entries.map(
                      (entry) => _CoveredRiskTile(
                        index: entry.key,
                        text: entry.value,
                        color: ins.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Insurance Details ───
                    _SectionTitle(
                      icon: Icons.analytics_rounded,
                      title: _t('Insurance Details', 'बीमा विवरण', 'विमा तपशील'),
                      color: const Color(0xFFFF8F00),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.shield_rounded,
                            label: _t('Sum Insured', 'बीमित राशि', 'विमित रक्कम'),
                            value: _formatCurrency(ins.sumInsured),
                            color: ins.color,
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.percent_rounded,
                            label: _t('Premium Rate', 'प्रीमियम दर', 'प्रीमियम दर'),
                            value: ins.premiumPercentage > 0 ? '${ins.premiumPercentage}%' : '₹436/yr',
                            color: const Color(0xFF2E7D32),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.payments_rounded,
                            label: _t('You Pay', 'आप भुगतान करें', 'आपण भरा'),
                            value: ins.premiumPercentage > 0 ? _formatCurrency(premiumAmount) : '₹436',
                            color: const Color(0xFF1565C0),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: _t('Claim Settlement', 'दावा निपटान', 'दावा निपटारा'),
                            value: _t('Within 2 months', '2 महीने के भीतर', '2 महिन्यांत'),
                            color: const Color(0xFFFF8F00),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.verified_rounded,
                            label: _t('Coverage Period', 'कवरेज अवधि', 'संरक्षण कालावधी'),
                            value: _t('Full Season', 'पूर्ण मौसम', 'पूर्ण हंगाम'),
                            color: const Color(0xFF7B1FA2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Key Benefits ───
                    _SectionTitle(
                      icon: Icons.star_rounded,
                      title: _t('Key Benefits', 'मुख्य लाभ', 'मुख्य फायदे'),
                      color: const Color(0xFFFF8F00),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: _getKeyBenefits().asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: entry.key < _getKeyBenefits().length - 1 ? 16 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getBenefitColor(entry.key).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_getBenefitIcon(entry.key), color: _getBenefitColor(entry.key), size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.value['title']!,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1F)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.value['desc']!,
                                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Eligibility ───
                    _SectionTitle(
                      icon: Icons.person_search_rounded,
                      title: _t('Who Can Apply', 'कौन आवेदन कर सकता है', 'कोण अर्ज करू शकतो'),
                      color: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: _getEligibility().map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.check_rounded, color: Color(0xFF7B1FA2), size: 14),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Required Documents ───
                    _SectionTitle(
                      icon: Icons.folder_open_rounded,
                      title: _t('Required Documents', 'आवश्यक दस्तावेज', 'आवश्यक कागदपत्रे'),
                      color: const Color(0xFFE65100),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: _getDocuments().asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: entry.key < _getDocuments().length - 1 ? 14 : 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFFE65100), const Color(0xFFE65100).withValues(alpha: 0.7)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(entry.value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                ),
                                Icon(Icons.description_rounded, color: Colors.grey[400], size: 20),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── How to Apply Steps ───
                    _SectionTitle(
                      icon: Icons.route_rounded,
                      title: _t('How to Get Insured', 'बीमा कैसे लें', 'विमा कसा घ्यावा'),
                      color: const Color(0xFF00897B),
                    ),
                    const SizedBox(height: 12),
                    ..._getSteps().asMap().entries.map(
                      (entry) => _StepTile(
                        stepNumber: entry.key + 1,
                        title: entry.value['title']!,
                        subtitle: entry.value['subtitle']!,
                        icon: _getStepIcon(entry.key),
                        isLast: entry.key == _getSteps().length - 1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Claim Process ───
                    _SectionTitle(
                      icon: Icons.gavel_rounded,
                      title: _t('Claim Process', 'दावा प्रक्रिया', 'दावा प्रक्रिया'),
                      color: const Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Column(
                        children: _getClaimSteps().asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: entry.key < _getClaimSteps().length - 1 ? 14 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD32F2F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Helpline ───
                    _PremiumWhiteCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ins.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.support_agent_rounded, color: ins.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('PMFBY Helpline', 'PMFBY हेल्पलाइन', 'PMFBY हेल्पलाइन'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t(
                                    'Call 1800-180-1551 (Toll Free) for crop insurance queries',
                                    'फसल बीमा प्रश्नों के लिए 1800-180-1551 (टोल फ्री) पर कॉल करें',
                                    'पीक विमा प्रश्नांसाठी 1800-180-1551 (टोल फ्री) वर कॉल करा',
                                  ),
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ─── Bottom Get Insured Button ───
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Your Premium', 'आपका प्रीमियम', 'आपला प्रीमियम'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    ins.premiumPercentage > 0 ? _formatCurrency(premiumAmount) : '₹436/yr',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ins.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GradientButton(
                text: _t('Get Insured', 'बीमा लें', 'विमा घ्या'),
                icon: Icons.shield_rounded,
                colors: [ins.color, ins.color.withValues(alpha: 0.8)],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showInsuranceBottomSheet(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInsuranceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.insurance.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_user_rounded, color: widget.insurance.color, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              _t('Insurance Request Submitted!', 'बीमा अनुरोध जमा हुआ!', 'विमा विनंती सादर झाली!'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _t(
                'Your crop insurance enrollment request has been recorded. Visit your nearest bank or CSC center with required documents to complete enrollment.',
                'आपका फसल बीमा नामांकन अनुरोध दर्ज किया गया है। नामांकन पूरा करने के लिए आवश्यक दस्तावेजों के साथ अपने निकटतम बैंक या CSC केंद्र पर जाएं।',
                'आपली पीक विमा नोंदणी विनंती नोंदवली गेली आहे. नोंदणी पूर्ण करण्यासाठी आवश्यक कागदपत्रांसह जवळच्या बँक किंवा CSC केंद्राला भेट द्या.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: _GradientButton(
                text: _t('Done', 'हो गया', 'पूर्ण'),
                icon: Icons.check_rounded,
                colors: [widget.insurance.color, widget.insurance.color.withValues(alpha: 0.8)],
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getKeyBenefits() {
    return [
      {
        'title': _t('Low Premium', 'कम प्रीमियम', 'कमी प्रीमियम'),
        'desc': _t(
          'Farmers pay only 2% for Kharif, 1.5% for Rabi crops. Government bears the rest.',
          'किसान खरीफ के लिए केवल 2%, रबी फसलों के लिए 1.5% भुगतान करते हैं। बाकी सरकार वहन करती है।',
          'शेतकरी खरीपसाठी फक्त 2%, रब्बी पिकांसाठी 1.5% भरतात. उर्वरित सरकार सहन करते.',
        ),
      },
      {
        'title': _t('Quick Claim Settlement', 'त्वरित दावा निपटान', 'जलद दावा निपटारा'),
        'desc': _t(
          'Claims settled within 2 months of harvest. Amount directly credited to bank.',
          'फसल कटाई के 2 महीने के भीतर दावे निपटाए जाते हैं। राशि सीधे बैंक में जमा।',
          'पीक कापणीनंतर 2 महिन्यांत दावे निपटले जातात. रक्कम थेट बँकेत जमा.',
        ),
      },
      {
        'title': _t('Comprehensive Coverage', 'व्यापक कवरेज', 'सर्वसमावेशक संरक्षण'),
        'desc': _t(
          'Protection against all natural calamities including drought, flood, and pest attacks.',
          'सूखा, बाढ़ और कीट हमलों सहित सभी प्राकृतिक आपदाओं से सुरक्षा।',
          'दुष्काळ, पूर आणि कीड हल्ल्यांसह सर्व नैसर्गिक आपत्तींपासून संरक्षण.',
        ),
      },
      {
        'title': _t('No Upper Limit', 'कोई ऊपरी सीमा नहीं', 'कोणतीही वरची मर्यादा नाही'),
        'desc': _t(
          'No cap on government subsidy. Full protection regardless of premium amount.',
          'सरकारी सब्सिडी पर कोई सीमा नहीं। प्रीमियम राशि की परवाह किए बिना पूर्ण सुरक्षा।',
          'सरकारी अनुदानावर कोणतीही मर्यादा नाही. प्रीमियम रकमेची पर्वा न करता पूर्ण संरक्षण.',
        ),
      },
    ];
  }

  Color _getBenefitColor(int index) {
    const colors = [Color(0xFF2E7D32), Color(0xFFFF8F00), Color(0xFF1565C0), Color(0xFF7B1FA2)];
    return colors[index % colors.length];
  }

  IconData _getBenefitIcon(int index) {
    const icons = [Icons.attach_money_rounded, Icons.speed_rounded, Icons.security_rounded, Icons.all_inclusive_rounded];
    return icons[index % icons.length];
  }

  List<String> _getEligibility() {
    return [
      _t('All farmers growing notified crops in notified areas', 'अधिसूचित क्षेत्रों में अधिसूचित फसलें उगाने वाले सभी किसान', 'अधिसूचित क्षेत्रात अधिसूचित पिके घेणारे सर्व शेतकरी'),
      _t('Both loanee and non-loanee farmers', 'ऋणी और गैर-ऋणी दोनों किसान', 'कर्जदार आणि बिगर-कर्जदार दोन्ही शेतकरी'),
      _t('Share croppers and tenant farmers with valid documents', 'वैध दस्तावेजों वाले बटाईदार और किरायेदार किसान', 'वैध कागदपत्रांसह भागदार आणि भाडेकरू शेतकरी'),
      _t('Farmers with Aadhaar linked bank account', 'आधार से जुड़े बैंक खाते वाले किसान', 'आधार जोडलेल्या बँक खात्यासह शेतकरी'),
    ];
  }

  List<String> _getDocuments() {
    return [
      _t('Aadhaar Card', 'आधार कार्ड', 'आधार कार्ड'),
      _t('Land Records / 7/12 Extract', 'भूमि रिकॉर्ड / 7/12 उतारा', 'जमीन नोंदी / ७/१२ उतारा'),
      _t('Bank Passbook (Aadhaar linked)', 'बैंक पासबुक (आधार से जुड़ी)', 'बँक पासबुक (आधार जोडलेली)'),
      _t('Sowing Certificate from Patwari', 'पटवारी से बुवाई प्रमाण पत्र', 'पटवारीकडून पेरणी प्रमाणपत्र'),
      _t('Photo ID Proof', 'फोटो पहचान प्रमाण', 'फोटो ओळखपत्र'),
    ];
  }

  List<Map<String, String>> _getSteps() {
    return [
      {
        'title': _t('Visit Bank/CSC', 'बैंक/CSC पर जाएं', 'बँक/CSC ला भेट द्या'),
        'subtitle': _t('Go to nearest bank branch, CSC center, or insurance agent', 'निकटतम बैंक शाखा, CSC केंद्र या बीमा एजेंट से मिलें', 'जवळच्या बँक शाखा, CSC केंद्र किंवा विमा एजंटला भेटा'),
      },
      {
        'title': _t('Fill Insurance Form', 'बीमा फॉर्म भरें', 'विमा अर्ज भरा'),
        'subtitle': _t('Complete the crop insurance application with crop details', 'फसल विवरण के साथ फसल बीमा आवेदन पूरा करें', 'पीक तपशीलासह पीक विमा अर्ज भरा'),
      },
      {
        'title': _t('Submit Documents', 'दस्तावेज जमा करें', 'कागदपत्रे सादर करा'),
        'subtitle': _t('Provide land records, Aadhaar, and bank details', 'भूमि रिकॉर्ड, आधार और बैंक विवरण प्रदान करें', 'जमीन नोंदी, आधार आणि बँक तपशील द्या'),
      },
      {
        'title': _t('Pay Premium', 'प्रीमियम भुगतान', 'प्रीमियम भरा'),
        'subtitle': _t('Pay the minimal farmer premium to activate coverage', 'कवरेज सक्रिय करने के लिए न्यूनतम किसान प्रीमियम का भुगतान करें', 'संरक्षण सक्रिय करण्यासाठी किमान शेतकरी प्रीमियम भरा'),
      },
    ];
  }

  IconData _getStepIcon(int index) {
    const icons = [Icons.account_balance_rounded, Icons.edit_document, Icons.upload_file_rounded, Icons.payment_rounded];
    return icons[index % icons.length];
  }

  List<String> _getClaimSteps() {
    return [
      _t('Report crop loss within 72 hours to insurance company or bank', 'फसल नुकसान की 72 घंटे के भीतर बीमा कंपनी या बैंक को सूचना दें', 'पीक नुकसानाची 72 तासांत विमा कंपनी किंवा बँकेला माहिती द्या'),
      _t('Crop cutting experiments conducted by government officials', 'सरकारी अधिकारियों द्वारा फसल कटाई प्रयोग आयोजित', 'सरकारी अधिकाऱ्यांकडून पीक कापणी प्रयोग आयोजित'),
      _t('Yield data compared with threshold yield for your area', 'आपके क्षेत्र के सीमा उपज से उपज डेटा की तुलना', 'आपल्या क्षेत्रातील उंबरठा उत्पन्नाशी उत्पन्न डेटाची तुलना'),
      _t('Claim amount calculated and credited to bank within 2 months', 'दावा राशि गणना और 2 महीने के भीतर बैंक में जमा', 'दावा रक्कम गणना आणि 2 महिन्यांत बँकेत जमा'),
    ];
  }
}

// ────────────────────────────────────────────
// Shared Widgets (same pattern as loan_detail)
// ────────────────────────────────────────────

class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBackButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HeroInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeroInfoBox({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionTitle({required this.icon, required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F)))),
      ],
    );
  }
}

class _PremiumWhiteCard extends StatelessWidget {
  final Widget child;
  const _PremiumWhiteCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();
  @override
  Widget build(BuildContext context) => Divider(height: 24, color: Colors.grey[200]);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
        Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.end)),
      ],
    );
  }
}

class _CoveredRiskTile extends StatelessWidget {
  final int index;
  final String text;
  final Color color;
  const _CoveredRiskTile({required this.index, required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Icon(Icons.shield_rounded, color: Colors.white, size: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4))),
        ],
      ),
    );
  }
}

class _PremiumBreakdownCard extends StatelessWidget {
  final double sumInsured;
  final double farmerPremium;
  final double govtSubsidy;
  final double premiumPercent;
  final String langCode;
  final Color color;

  const _PremiumBreakdownCard({
    required this.sumInsured,
    required this.farmerPremium,
    required this.govtSubsidy,
    required this.premiumPercent,
    required this.langCode,
    required this.color,
  });

  String _t(String en, String hi, String mr) {
    if (langCode == 'hi') return hi;
    if (langCode == 'mr') return mr;
    return en;
  }

  String _fmt(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final govtPercent = 100 - premiumPercent;
    return _PremiumWhiteCard(
      child: Column(
        children: [
          // Visual bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: premiumPercent.toInt(),
                    child: Container(color: color),
                  ),
                  Expanded(
                    flex: govtPercent.toInt(),
                    child: Container(color: const Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BreakdownItem(
                  color: color,
                  label: _t('You Pay', 'आप भुगतान', 'आपण भरा'),
                  value: _fmt(farmerPremium),
                  percent: '${premiumPercent.toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BreakdownItem(
                  color: const Color(0xFF4CAF50),
                  label: _t('Govt. Bears', 'सरकार वहन', 'सरकार सहन'),
                  value: _fmt(govtSubsidy),
                  percent: '${govtPercent.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percent;
  const _BreakdownItem({required this.color, required this.label, required this.value, required this.percent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(percent, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLast;
  const _StepTile({required this.stepNumber, required this.title, required this.subtitle, required this.icon, this.isLast = false});

  static const List<Color> _colors = [Color(0xFF2E7D32), Color(0xFF1565C0), Color(0xFFFF8F00), Color(0xFF7B1FA2)];

  @override
  Widget build(BuildContext context) {
    final color = _colors[(stepNumber - 1) % _colors.length];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text('$stepNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            if (!isLast) Container(width: 2, height: 40, margin: const EdgeInsets.symmetric(vertical: 4), color: color.withValues(alpha: 0.3)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1F))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _GradientButton({required this.text, required this.icon, required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

