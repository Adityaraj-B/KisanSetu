import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/crop_finance_data.dart';

/// Premium Subsidy Detail Screen - Full details when user taps "Apply Now"
class SubsidyDetailScreen extends StatefulWidget {
  final SubsidyData subsidy;
  final String langCode;

  const SubsidyDetailScreen({
    super.key,
    required this.subsidy,
    required this.langCode,
  });

  @override
  State<SubsidyDetailScreen> createState() => _SubsidyDetailScreenState();
}

class _SubsidyDetailScreenState extends State<SubsidyDetailScreen>
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
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subsidy;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero App Bar ───
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: sub.color,
              leading: _CircleBackButton(onTap: () => Navigator.pop(context)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [sub.color, sub.color.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Badges
                          Row(
                            children: [
                              _Badge(icon: Icons.card_giftcard_rounded, text: _t('Subsidy', 'सब्सिडी', 'अनुदान')),
                              const SizedBox(width: 8),
                              _Badge(icon: Icons.verified_rounded, text: _t('Government', 'सरकारी', 'सरकारी')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            sub.getLocalizedName(widget.langCode),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub.getLocalizedFrequency(widget.langCode),
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          // Amount & Eligibility
                          Row(
                            children: [
                              _HeroInfoBox(
                                label: _t('Amount', 'राशि', 'रक्कम'),
                                value: _formatCurrency(sub.amount),
                                icon: Icons.currency_rupee_rounded,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_rounded, color: Colors.white.withValues(alpha: 0.8), size: 14),
                                          const SizedBox(width: 5),
                                          Text(
                                            _t('Eligibility', 'पात्रता', 'पात्रता'),
                                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sub.getLocalizedEligibility(widget.langCode),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
                    // ─── Overview ───
                    _SectionTitle(
                      icon: Icons.info_outline_rounded,
                      title: _t('About This Subsidy', 'इस सब्सिडी के बारे में', 'या अनुदानाबद्दल'),
                      color: sub.color,
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Text(
                        sub.getLocalizedDescription(widget.langCode),
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Subsidy Details ───
                    _SectionTitle(
                      icon: Icons.analytics_rounded,
                      title: _t('Subsidy Details', 'सब्सिडी विवरण', 'अनुदान तपशील'),
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.currency_rupee_rounded,
                            label: _t('Amount', 'राशि', 'रक्कम'),
                            value: _formatCurrency(sub.amount),
                            color: sub.color,
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: _t('Frequency', 'आवृत्ति', 'वारंवारता'),
                            value: sub.getLocalizedFrequency(widget.langCode),
                            color: const Color(0xFF1565C0),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.person_rounded,
                            label: _t('Eligibility', 'पात्रता', 'पात्रता'),
                            value: sub.getLocalizedEligibility(widget.langCode),
                            color: const Color(0xFF7B1FA2),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.account_balance_rounded,
                            label: _t('Disbursement', 'वितरण', 'वितरण'),
                            value: _t('Direct Bank Transfer', 'सीधे बैंक में', 'थेट बँकेत'),
                            color: const Color(0xFF00897B),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.location_on_rounded,
                            label: _t('Availability', 'उपलब्धता', 'उपलब्धता'),
                            value: _t('All India', 'पूरे भारत में', 'संपूर्ण भारत'),
                            color: const Color(0xFFFF8F00),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Benefits ───
                    _SectionTitle(
                      icon: Icons.star_rounded,
                      title: _t('Benefits', 'लाभ', 'फायदे'),
                      color: const Color(0xFFFF8F00),
                    ),
                    const SizedBox(height: 12),
                    ...sub.getLocalizedBenefits(widget.langCode).asMap().entries.map(
                      (entry) => _BenefitTile(
                        index: entry.key,
                        text: entry.value,
                        color: sub.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Eligibility Criteria ───
                    _SectionTitle(
                      icon: Icons.person_search_rounded,
                      title: _t('Who Can Apply', 'कौन आवेदन कर सकता है', 'कोण अर्ज करू शकतो'),
                      color: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: _getEligibilityCriteria().map((item) => Padding(
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

                    // ─── How to Apply ───
                    _SectionTitle(
                      icon: Icons.route_rounded,
                      title: _t('How to Apply', 'आवेदन कैसे करें', 'अर्ज कसा करावा'),
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

                    // ─── Important Information ───
                    _SectionTitle(
                      icon: Icons.lightbulb_rounded,
                      title: _t('Important Information', 'महत्वपूर्ण जानकारी', 'महत्त्वाची माहिती'),
                      color: const Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Column(
                        children: _getImportantInfo().map((info) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(info, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
                              ),
                            ],
                          ),
                        )).toList(),
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
                              color: sub.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.support_agent_rounded, color: sub.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('Helpline', 'हेल्पलाइन', 'हेल्पलाइन'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t(
                                    'Call Kisan Call Center 1800-180-1551 (Toll Free) for subsidy related queries',
                                    'सब्सिडी संबंधित प्रश्नों के लिए किसान कॉल सेंटर 1800-180-1551 (टोल फ्री) पर कॉल करें',
                                    'अनुदान संबंधित प्रश्नांसाठी किसान कॉल सेंटर 1800-180-1551 (टोल फ्री) वर कॉल करा',
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
      // ─── Bottom Apply Button ───
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4)),
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
                    _t('Subsidy Amount', 'सब्सिडी राशि', 'अनुदान रक्कम'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _formatCurrency(sub.amount),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: sub.color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GradientButton(
                text: _t('Apply Now', 'आवेदन करें', 'अर्ज करा'),
                icon: Icons.arrow_forward_rounded,
                colors: [sub.color, sub.color.withValues(alpha: 0.8)],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showApplicationBottomSheet(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationBottomSheet(BuildContext context) {
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
                color: widget.subsidy.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded, color: widget.subsidy.color, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              _t('Application Submitted!', 'आवेदन जमा हुआ!', 'अर्ज सादर झाला!'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              _t(
                'Your subsidy application has been recorded. Benefits will be transferred to your Aadhaar-linked bank account after verification.',
                'आपका सब्सिडी आवेदन दर्ज किया गया है। सत्यापन के बाद लाभ आपके आधार से जुड़े बैंक खाते में स्थानांतरित किए जाएंगे।',
                'आपला अनुदान अर्ज नोंदवला गेला आहे. पडताळणीनंतर लाभ आपल्या आधार-जोडलेल्या बँक खात्यात हस्तांतरित केले जातील.',
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
                colors: [widget.subsidy.color, widget.subsidy.color.withValues(alpha: 0.8)],
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

  List<String> _getEligibilityCriteria() {
    return [
      _t('All landholding farmer families in India', 'भारत में सभी भूमिधारक किसान परिवार', 'भारतातील सर्व भूधारक शेतकरी कुटुंबे'),
      _t('Must have Aadhaar-linked bank account', 'आधार से जुड़ा बैंक खाता होना चाहिए', 'आधार-जोडलेले बँक खाते असणे आवश्यक'),
      _t('Valid land ownership or cultivation records', 'वैध भूमि स्वामित्व या खेती रिकॉर्ड', 'वैध जमीन मालकी किंवा शेती नोंदी'),
      _t('Registered under state agricultural department', 'राज्य कृषि विभाग के तहत पंजीकृत', 'राज्य कृषी विभागाअंतर्गत नोंदणीकृत'),
    ];
  }

  List<String> _getDocuments() {
    return [
      _t('Aadhaar Card', 'आधार कार्ड', 'आधार कार्ड'),
      _t('Bank Account Passbook', 'बैंक खाता पासबुक', 'बँक खाते पासबुक'),
      _t('Land Records / 7/12 Extract', 'भूमि रिकॉर्ड / 7/12 उतारा', 'जमीन नोंदी / ७/१२ उतारा'),
      _t('Income Certificate (if required)', 'आय प्रमाण पत्र (यदि आवश्यक)', 'उत्पन्न प्रमाणपत्र (आवश्यक असल्यास)'),
      _t('Caste Certificate (if applicable)', 'जाति प्रमाण पत्र (यदि लागू)', 'जात प्रमाणपत्र (लागू असल्यास)'),
    ];
  }

  List<Map<String, String>> _getSteps() {
    return [
      {
        'title': _t('Register Online/Offline', 'ऑनलाइन/ऑफलाइन पंजीकरण', 'ऑनलाइन/ऑफलाइन नोंदणी'),
        'subtitle': _t('Register on the official portal or visit CSC/bank branch', 'आधिकारिक पोर्टल पर पंजीकरण करें या CSC/बैंक शाखा पर जाएं', 'अधिकृत पोर्टलवर नोंदणी करा किंवा CSC/बँक शाखेला भेट द्या'),
      },
      {
        'title': _t('Submit Documents', 'दस्तावेज जमा करें', 'कागदपत्रे सादर करा'),
        'subtitle': _t('Provide Aadhaar, land records, and bank details', 'आधार, भूमि रिकॉर्ड और बैंक विवरण प्रदान करें', 'आधार, जमीन नोंदी आणि बँक तपशील द्या'),
      },
      {
        'title': _t('Verification Process', 'सत्यापन प्रक्रिया', 'पडताळणी प्रक्रिया'),
        'subtitle': _t('Officials verify your eligibility and documents', 'अधिकारी आपकी पात्रता और दस्तावेज सत्यापित करते हैं', 'अधिकारी आपली पात्रता आणि कागदपत्रे पडताळतात'),
      },
      {
        'title': _t('Receive Benefits', 'लाभ प्राप्त करें', 'लाभ प्राप्त करा'),
        'subtitle': _t('Subsidy amount directly credited to your bank via DBT', 'सब्सिडी राशि DBT के माध्यम से सीधे बैंक में जमा', 'अनुदान रक्कम DBT द्वारे थेट बँकेत जमा'),
      },
    ];
  }

  IconData _getStepIcon(int index) {
    const icons = [Icons.app_registration_rounded, Icons.upload_file_rounded, Icons.fact_check_rounded, Icons.celebration_rounded];
    return icons[index % icons.length];
  }

  List<String> _getImportantInfo() {
    return [
      _t(
        'Subsidy is directly transferred to Aadhaar-linked bank account via DBT',
        'सब्सिडी DBT के माध्यम से आधार से जुड़े बैंक खाते में सीधे स्थानांतरित होती है',
        'अनुदान DBT द्वारे आधार-जोडलेल्या बँक खात्यात थेट हस्तांतरित होते',
      ),
      _t(
        'Ensure your Aadhaar is linked with your bank account for smooth transfer',
        'सुगम हस्तांतरण के लिए सुनिश्चित करें कि आपका आधार बैंक खाते से जुड़ा है',
        'सुरळीत हस्तांतरणासाठी आपले आधार बँक खात्याशी जोडलेले असल्याची खात्री करा',
      ),
      _t(
        'Verification may take 2-4 weeks after document submission',
        'दस्तावेज जमा करने के बाद सत्यापन में 2-4 सप्ताह लग सकते हैं',
        'कागदपत्रे सादर केल्यानंतर पडताळणीसाठी 2-4 आठवडे लागू शकतात',
      ),
      _t(
        'Keep your bank account active and operational',
        'अपना बैंक खाता सक्रिय और चालू रखें',
        'आपले बँक खाते सक्रिय आणि कार्यरत ठेवा',
      ),
    ];
  }
}

// ────────────────────────────────────────────
// Shared Widgets
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

class _BenefitTile extends StatelessWidget {
  final int index;
  final String text;
  final Color color;
  const _BenefitTile({required this.index, required this.text, required this.color});
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
            child: const Center(child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4))),
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

