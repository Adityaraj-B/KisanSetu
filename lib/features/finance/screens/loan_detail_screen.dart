import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/crop_finance_data.dart';

/// Premium Loan Detail Screen - Full details when user taps "Apply Now"
class LoanDetailScreen extends StatefulWidget {
  final LoanData loan;
  final String langCode;

  const LoanDetailScreen({
    super.key,
    required this.loan,
    required this.langCode,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late ScrollController _scrollController;
  bool _showFab = false;

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
    _scrollController = ScrollController()
      ..addListener(() {
        final show = _scrollController.offset > 200;
        if (show != _showFab) setState(() => _showFab = show);
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
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
    final loan = widget.loan;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero App Bar ───
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: loan.color,
              leading: _CircleBackButton(onTap: () => Navigator.pop(context)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [loan.color, loan.color.withValues(alpha: 0.75)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  _t('Government Backed', 'सरकार समर्थित', 'सरकार समर्थित'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loan.getLocalizedName(widget.langCode),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loan.provider,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(
                            children: [
                              _HeroStat(
                                value: '${loan.interestRate}%',
                                label: _t('Interest', 'ब्याज', 'व्याज'),
                              ),
                              const SizedBox(width: 12),
                              _HeroStat(
                                value: _formatCurrency(loan.eligibleAmount),
                                label: _t('Eligible', 'पात्र', 'पात्र'),
                              ),
                              const SizedBox(width: 12),
                              _HeroStat(
                                value: loan.tenure.split(' ').first,
                                label: _t('Tenure', 'अवधि', 'कालावधी'),
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
                    // ─── Overview Card ───
                    _SectionTitle(
                      icon: Icons.info_outline_rounded,
                      title: _t('Overview', 'अवलोकन', 'अवलोकन'),
                      color: loan.color,
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Text(
                        loan.getLocalizedDescription(widget.langCode),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Loan Details Grid ───
                    _SectionTitle(
                      icon: Icons.analytics_rounded,
                      title: _t('Loan Details', 'ऋण विवरण', 'कर्ज तपशील'),
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 12),
                    _PremiumWhiteCard(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.percent_rounded,
                            label: _t('Interest Rate', 'ब्याज दर', 'व्याज दर'),
                            value: '${loan.interestRate}% p.a.',
                            color: const Color(0xFF2E7D32),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.currency_rupee_rounded,
                            label: _t('Maximum Amount', 'अधिकतम राशि', 'कमाल रक्कम'),
                            value: _formatCurrency(loan.maxAmount),
                            color: const Color(0xFF1565C0),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.check_circle_outline_rounded,
                            label: _t('Your Eligible Amount', 'आपकी पात्र राशि', 'आपली पात्र रक्कम'),
                            value: _formatCurrency(loan.eligibleAmount),
                            color: const Color(0xFFFF8F00),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.calendar_month_rounded,
                            label: _t('Loan Tenure', 'ऋण अवधि', 'कर्ज कालावधी'),
                            value: loan.tenure,
                            color: const Color(0xFF7B1FA2),
                          ),
                          const _ThinDivider(),
                          _DetailRow(
                            icon: Icons.account_balance_rounded,
                            label: _t('Provider', 'प्रदाता', 'प्रदाता'),
                            value: loan.provider,
                            color: const Color(0xFF00897B),
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
                    ...loan.getLocalizedBenefits(widget.langCode).asMap().entries.map(
                      (entry) => _BenefitTile(
                        index: entry.key,
                        text: entry.value,
                        color: loan.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Eligibility Criteria ───
                    _SectionTitle(
                      icon: Icons.person_search_rounded,
                      title: _t('Eligibility Criteria', 'पात्रता मानदंड', 'पात्रता निकष'),
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
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                                ),
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
                        children: _getRequiredDocuments().asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: entry.key < _getRequiredDocuments().length - 1 ? 14 : 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFE65100),
                                        const Color(0xFFE65100).withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
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
                      title: _t('How to Apply', 'आवेदन कैसे करें', 'अर्ज कसा करावा'),
                      color: const Color(0xFF00897B),
                    ),
                    const SizedBox(height: 12),
                    ..._getApplicationSteps().asMap().entries.map(
                      (entry) => _StepTile(
                        stepNumber: entry.key + 1,
                        title: entry.value['title']!,
                        subtitle: entry.value['subtitle']!,
                        icon: _getStepIcon(entry.key),
                        isLast: entry.key == _getApplicationSteps().length - 1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Important Notes ───
                    _SectionTitle(
                      icon: Icons.lightbulb_rounded,
                      title: _t('Important Notes', 'महत्वपूर्ण नोट', 'महत्त्वाच्या नोट्स'),
                      color: const Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Column(
                        children: _getImportantNotes().map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_rounded, color: Color(0xFFFF8F00), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  note,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Contact / Helpline ───
                    _PremiumWhiteCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: loan.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.support_agent_rounded, color: loan.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('Need Help?', 'मदद चाहिए?', 'मदत हवी आहे?'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t(
                                    'Contact your nearest bank branch or call Kisan Call Center at 1800-180-1551',
                                    'अपनी निकटतम बैंक शाखा से संपर्क करें या किसान कॉल सेंटर 1800-180-1551 पर कॉल करें',
                                    'जवळच्या बँक शाखेशी संपर्क साधा किंवा किसान कॉल सेंटर 1800-180-1551 वर कॉल करा',
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
                    _t('Eligible Amount', 'पात्र राशि', 'पात्र रक्कम'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _formatCurrency(loan.eligibleAmount),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: loan.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GradientButton(
                text: _t('Apply Now', 'आवेदन करें', 'अर्ज करा'),
                icon: Icons.arrow_forward_rounded,
                colors: [loan.color, loan.color.withValues(alpha: 0.8)],
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.loan.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: widget.loan.color, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              _t('Application Initiated!', 'आवेदन शुरू हुआ!', 'अर्ज सुरू झाला!'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              _t(
                'Your loan application request has been recorded. Visit your nearest bank branch with required documents to complete the process.',
                'आपका ऋण आवेदन अनुरोध दर्ज किया गया है। प्रक्रिया पूरी करने के लिए आवश्यक दस्तावेजों के साथ अपनी निकटतम बैंक शाखा पर जाएं।',
                'आपला कर्ज अर्ज नोंदवला गेला आहे. प्रक्रिया पूर्ण करण्यासाठी आवश्यक कागदपत्रांसह जवळच्या बँक शाखेला भेट द्या.',
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
                colors: [widget.loan.color, widget.loan.color.withValues(alpha: 0.8)],
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
      _t('Indian citizen engaged in agriculture', 'कृषि में लगा भारतीय नागरिक', 'शेतीत गुंतलेला भारतीय नागरिक'),
      _t('Age between 18-65 years', '18-65 वर्ष की आयु', '18-65 वर्षे वय'),
      _t('Valid land ownership or lease documents', 'वैध भूमि स्वामित्व या पट्टा दस्तावेज', 'वैध जमीन मालकी किंवा भाडेपट्टी कागदपत्रे'),
      _t('Aadhaar card linked with bank account', 'बैंक खाते से जुड़ा आधार कार्ड', 'बँक खात्याशी जोडलेले आधार कार्ड'),
      _t('No existing loan default', 'कोई मौजूदा ऋण चूक नहीं', 'विद्यमान कर्ज थकबाकी नसावी'),
    ];
  }

  List<String> _getRequiredDocuments() {
    return [
      _t('Aadhaar Card', 'आधार कार्ड', 'आधार कार्ड'),
      _t('Land Records (7/12 Extract)', 'भूमि रिकॉर्ड (7/12 उतारा)', 'जमीन नोंदी (७/१२ उतारा)'),
      _t('Bank Passbook / Statement', 'बैंक पासबुक / स्टेटमेंट', 'बँक पासबुक / स्टेटमेंट'),
      _t('2 Passport Size Photos', '2 पासपोर्ट साइज फोटो', '२ पासपोर्ट आकाराचे फोटो'),
      _t('Income Certificate', 'आय प्रमाण पत्र', 'उत्पन्न प्रमाणपत्र'),
      _t('Crop Sowing Certificate', 'फसल बुवाई प्रमाण पत्र', 'पीक पेरणी प्रमाणपत्र'),
    ];
  }

  List<Map<String, String>> _getApplicationSteps() {
    return [
      {
        'title': _t('Visit Bank Branch', 'बैंक शाखा पर जाएं', 'बँक शाखेला भेट द्या'),
        'subtitle': _t('Go to your nearest authorized bank or CSC center', 'अपने निकटतम अधिकृत बैंक या CSC केंद्र पर जाएं', 'जवळच्या अधिकृत बँक किंवा CSC केंद्राला जा'),
      },
      {
        'title': _t('Submit Application', 'आवेदन जमा करें', 'अर्ज सादर करा'),
        'subtitle': _t('Fill the loan application form with your details', 'अपने विवरण के साथ ऋण आवेदन पत्र भरें', 'आपल्या तपशीलासह कर्ज अर्ज भरा'),
      },
      {
        'title': _t('Document Verification', 'दस्तावेज सत्यापन', 'कागदपत्र पडताळणी'),
        'subtitle': _t('Bank will verify your documents and land records', 'बैंक आपके दस्तावेज और भूमि रिकॉर्ड सत्यापित करेगा', 'बँक आपली कागदपत्रे आणि जमीन नोंदी पडताळेल'),
      },
      {
        'title': _t('Loan Approval', 'ऋण स्वीकृति', 'कर्ज मंजुरी'),
        'subtitle': _t('Upon approval, amount is credited to your bank account', 'स्वीकृति पर, राशि आपके बैंक खाते में जमा होती है', 'मंजुरीनंतर, रक्कम आपल्या बँक खात्यात जमा होते'),
      },
    ];
  }

  IconData _getStepIcon(int index) {
    const icons = [
      Icons.account_balance_rounded,
      Icons.edit_document,
      Icons.fact_check_rounded,
      Icons.celebration_rounded,
    ];
    return icons[index % icons.length];
  }

  List<String> _getImportantNotes() {
    return [
      _t(
        'Interest rate may vary based on bank and your credit score',
        'ब्याज दर बैंक और आपके क्रेडिट स्कोर के आधार पर भिन्न हो सकती है',
        'व्याज दर बँक आणि आपल्या क्रेडिट स्कोअरवर आधारित बदलू शकतो',
      ),
      _t(
        'Loan amount is subject to land valuation and income assessment',
        'ऋण राशि भूमि मूल्यांकन और आय मूल्यांकन पर निर्भर है',
        'कर्ज रक्कम जमीन मूल्यांकन आणि उत्पन्न मूल्यांकनावर अवलंबून आहे',
      ),
      _t(
        'Timely repayment ensures eligibility for future loans and interest subvention',
        'समय पर भुगतान भविष्य के ऋण और ब्याज सब्सिडी की पात्रता सुनिश्चित करता है',
        'वेळेवर परतफेड भविष्यातील कर्ज आणि व्याज सवलतीची पात्रता सुनिश्चित करते',
      ),
    ];
  }
}

// ────────────────────────────────────────────
// Shared Premium Widgets
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
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1B1F))),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
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
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
            child: Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
          ),
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
              child: Center(
                child: Text('$stepNumber', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: color.withValues(alpha: 0.3),
              ),
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
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
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

