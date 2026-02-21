import 'package:flutter/material.dart';

/// Finance data model for loans
class LoanData {
  final String name;
  final String nameHi;
  final String nameMr;
  final String description;
  final String descriptionHi;
  final String descriptionMr;
  final double interestRate;
  final double maxAmount;
  final double eligibleAmount;
  final String tenure;
  final String provider;
  final List<String> benefits;
  final List<String> benefitsHi;
  final List<String> benefitsMr;
  final IconData icon;
  final Color color;

  const LoanData({
    required this.name,
    required this.nameHi,
    this.nameMr = '',
    required this.description,
    required this.descriptionHi,
    this.descriptionMr = '',
    required this.interestRate,
    required this.maxAmount,
    required this.eligibleAmount,
    required this.tenure,
    required this.provider,
    required this.benefits,
    required this.benefitsHi,
    this.benefitsMr = const [],
    required this.icon,
    required this.color,
  });

  String getLocalizedName(String langCode) {
    if (langCode == 'hi') return nameHi;
    if (langCode == 'mr') return nameMr.isNotEmpty ? nameMr : nameHi;
    return name;
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'hi') return descriptionHi;
    if (langCode == 'mr') return descriptionMr.isNotEmpty ? descriptionMr : descriptionHi;
    return description;
  }

  List<String> getLocalizedBenefits(String langCode) {
    if (langCode == 'hi') return benefitsHi;
    if (langCode == 'mr') return benefitsMr.isNotEmpty ? benefitsMr : benefitsHi;
    return benefits;
  }
}

/// Insurance data model
class InsuranceData {
  final String name;
  final String nameHi;
  final String nameMr;
  final String description;
  final String descriptionHi;
  final String descriptionMr;
  final double premiumPercentage;
  final double sumInsured;
  final String coverage;
  final String coverageHi;
  final String coverageMr;
  final List<String> coveredRisks;
  final List<String> coveredRisksHi;
  final List<String> coveredRisksMr;
  final IconData icon;
  final Color color;

  const InsuranceData({
    required this.name,
    required this.nameHi,
    this.nameMr = '',
    required this.description,
    required this.descriptionHi,
    this.descriptionMr = '',
    required this.premiumPercentage,
    required this.sumInsured,
    required this.coverage,
    required this.coverageHi,
    this.coverageMr = '',
    required this.coveredRisks,
    required this.coveredRisksHi,
    this.coveredRisksMr = const [],
    required this.icon,
    required this.color,
  });

  String getLocalizedName(String langCode) {
    if (langCode == 'hi') return nameHi;
    if (langCode == 'mr') return nameMr.isNotEmpty ? nameMr : nameHi;
    return name;
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'hi') return descriptionHi;
    if (langCode == 'mr') return descriptionMr.isNotEmpty ? descriptionMr : descriptionHi;
    return description;
  }

  String getLocalizedCoverage(String langCode) {
    if (langCode == 'hi') return coverageHi;
    if (langCode == 'mr') return coverageMr.isNotEmpty ? coverageMr : coverageHi;
    return coverage;
  }

  List<String> getLocalizedCoveredRisks(String langCode) {
    if (langCode == 'hi') return coveredRisksHi;
    if (langCode == 'mr') return coveredRisksMr.isNotEmpty ? coveredRisksMr : coveredRisksHi;
    return coveredRisks;
  }
}

/// Subsidy data model
class SubsidyData {
  final String name;
  final String nameHi;
  final String nameMr;
  final String description;
  final String descriptionHi;
  final String descriptionMr;
  final double amount;
  final String frequency;
  final String frequencyHi;
  final String frequencyMr;
  final String eligibility;
  final String eligibilityHi;
  final String eligibilityMr;
  final List<String> benefits;
  final List<String> benefitsHi;
  final List<String> benefitsMr;
  final IconData icon;
  final Color color;

  const SubsidyData({
    required this.name,
    required this.nameHi,
    this.nameMr = '',
    required this.description,
    required this.descriptionHi,
    this.descriptionMr = '',
    required this.amount,
    required this.frequency,
    required this.frequencyHi,
    this.frequencyMr = '',
    required this.eligibility,
    required this.eligibilityHi,
    this.eligibilityMr = '',
    required this.benefits,
    required this.benefitsHi,
    this.benefitsMr = const [],
    required this.icon,
    required this.color,
  });

  String getLocalizedName(String langCode) {
    if (langCode == 'hi') return nameHi;
    if (langCode == 'mr') return nameMr.isNotEmpty ? nameMr : nameHi;
    return name;
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'hi') return descriptionHi;
    if (langCode == 'mr') return descriptionMr.isNotEmpty ? descriptionMr : descriptionHi;
    return description;
  }

  String getLocalizedFrequency(String langCode) {
    if (langCode == 'hi') return frequencyHi;
    if (langCode == 'mr') return frequencyMr.isNotEmpty ? frequencyMr : frequencyHi;
    return frequency;
  }

  String getLocalizedEligibility(String langCode) {
    if (langCode == 'hi') return eligibilityHi;
    if (langCode == 'mr') return eligibilityMr.isNotEmpty ? eligibilityMr : eligibilityHi;
    return eligibility;
  }

  List<String> getLocalizedBenefits(String langCode) {
    if (langCode == 'hi') return benefitsHi;
    if (langCode == 'mr') return benefitsMr.isNotEmpty ? benefitsMr : benefitsHi;
    return benefits;
  }
}

/// Demo data generator for crop finance screen
class CropFinanceDataGenerator {
  /// Calculate approximate annual income value from the income range string
  static double getAnnualIncomeValue(String? incomeRange) {
    switch (incomeRange) {
      case 'below_1_lakh':
        return 75000;
      case '1_to_2.5_lakh':
        return 175000;
      case '2.5_to_5_lakh':
        return 375000;
      case '5_to_10_lakh':
        return 750000;
      case 'above_10_lakh':
        return 1500000;
      default:
        return 200000;
    }
  }

  /// Generate loan data based on annual income
  static List<LoanData> generateLoanData(double annualIncome, double landSize) {
    final kccLimit = (annualIncome * 3).clamp(50000.0, 300000.0);
    final tractorLoanLimit = (annualIncome * 5).clamp(100000.0, 1500000.0);
    final cropLoanLimit = (landSize * 50000).clamp(25000.0, 500000.0);
    final mudraLimit = (annualIncome * 2).clamp(50000.0, 1000000.0);

    return [
      LoanData(
        name: 'Kisan Credit Card (KCC)',
        nameHi: 'किसान क्रेडिट कार्ड (KCC)',
        description: 'Short-term credit for crop production and agricultural needs',
        descriptionHi: 'फसल उत्पादन और कृषि आवश्यकताओं के लिए अल्पकालिक ऋण',
        interestRate: 4.0,
        maxAmount: 300000,
        eligibleAmount: kccLimit,
        tenure: '1 Year (Renewable)',
        provider: 'All Scheduled Banks',
        benefits: [
          'Interest subvention of 2% for timely repayment',
          'Additional 3% bonus for prompt payment',
          'No collateral up to ₹1.6 Lakh',
          'Flexible repayment based on crop cycle',
        ],
        benefitsHi: [
          'समय पर भुगतान के लिए 2% ब्याज सब्सिडी',
          'त्वरित भुगतान के लिए अतिरिक्त 3% बोनस',
          '₹1.6 लाख तक बिना गारंटी',
          'फसल चक्र के आधार पर लचीला भुगतान',
        ],
        icon: Icons.credit_card_rounded,
        color: const Color(0xFF2E7D32),
      ),
      LoanData(
        name: 'Crop Loan',
        nameHi: 'फसल ऋण',
        description: 'Production loan for purchasing seeds, fertilizers, and pesticides',
        descriptionHi: 'बीज, उर्वरक और कीटनाशक खरीदने के लिए उत्पादन ऋण',
        interestRate: 7.0,
        maxAmount: 500000,
        eligibleAmount: cropLoanLimit,
        tenure: '6-12 Months',
        provider: 'Cooperative Banks, RRBs',
        benefits: [
          'Quick disbursement for seasonal needs',
          'Interest subsidy under government schemes',
          'Linked to crop insurance for protection',
          'Flexible based on crop type and season',
        ],
        benefitsHi: [
          'मौसमी जरूरतों के लिए त्वरित वितरण',
          'सरकारी योजनाओं के तहत ब्याज सब्सिडी',
          'सुरक्षा के लिए फसल बीमा से जुड़ा',
          'फसल प्रकार और मौसम के आधार पर लचीला',
        ],
        icon: Icons.grass_rounded,
        color: const Color(0xFF00897B),
      ),
      LoanData(
        name: 'Tractor & Equipment Loan',
        nameHi: 'ट्रैक्टर और उपकरण ऋण',
        description: 'Long-term financing for farm mechanization',
        descriptionHi: 'कृषि मशीनीकरण के लिए दीर्घकालिक वित्तपोषण',
        interestRate: 9.5,
        maxAmount: 1500000,
        eligibleAmount: tractorLoanLimit,
        tenure: '5-7 Years',
        provider: 'Commercial Banks, NBFCs',
        benefits: [
          'Up to 85% financing on equipment cost',
          'Government subsidy on select equipment',
          'Doorstep service for application',
          'Moratorium period available',
        ],
        benefitsHi: [
          'उपकरण लागत पर 85% तक वित्तपोषण',
          'चुनिंदा उपकरणों पर सरकारी सब्सिडी',
          'आवेदन के लिए घर-घर सेवा',
          'स्थगन अवधि उपलब्ध',
        ],
        icon: Icons.agriculture_rounded,
        color: const Color(0xFFFF8F00),
      ),
      LoanData(
        name: 'PM-MUDRA Shishu Loan',
        nameHi: 'पीएम-मुद्रा शिशु ऋण',
        description: 'Micro-financing for small-scale agricultural activities',
        descriptionHi: 'छोटे पैमाने की कृषि गतिविधियों के लिए माइक्रो-फाइनेंसिंग',
        interestRate: 8.5,
        maxAmount: 50000,
        eligibleAmount: mudraLimit.clamp(10000.0, 50000.0),
        tenure: '3-5 Years',
        provider: 'Banks, MFIs, NBFCs',
        benefits: [
          'No collateral required',
          'Simple documentation process',
          'Quick approval and disbursement',
          'Women entrepreneurs get priority',
        ],
        benefitsHi: [
          'कोई गारंटी आवश्यक नहीं',
          'सरल दस्तावेज प्रक्रिया',
          'त्वरित अनुमोदन और वितरण',
          'महिला उद्यमियों को प्राथमिकता',
        ],
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF7B1FA2),
      ),
    ];
  }

  /// Generate insurance data based on land size and income
  static List<InsuranceData> generateInsuranceData(double annualIncome, double landSize) {
    final cropSumInsured = (landSize * 40000).clamp(10000.0, 500000.0);
    final lifeSumInsured = (annualIncome * 5).clamp(100000.0, 500000.0);

    return [
      InsuranceData(
        name: 'PM Fasal Bima Yojana (PMFBY)',
        nameHi: 'प्रधानमंत्री फसल बीमा योजना',
        description: 'Comprehensive crop insurance against natural calamities',
        descriptionHi: 'प्राकृतिक आपदाओं के विरुद्ध व्यापक फसल बीमा',
        premiumPercentage: 2.0,
        sumInsured: cropSumInsured,
        coverage: 'Kharif & Rabi Crops',
        coverageHi: 'खरीफ और रबी फसलें',
        coveredRisks: [
          'Natural disasters (flood, drought, cyclone)',
          'Pest and disease attacks',
          'Post-harvest losses (up to 14 days)',
          'Localized calamities (hailstorm, landslide)',
        ],
        coveredRisksHi: [
          'प्राकृतिक आपदाएं (बाढ़, सूखा, चक्रवात)',
          'कीट और रोग का हमला',
          'कटाई के बाद का नुकसान (14 दिन तक)',
          'स्थानीय आपदाएं (ओलावृष्टि, भूस्खलन)',
        ],
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF00695C),
      ),
      InsuranceData(
        name: 'Weather Based Crop Insurance (WBCIS)',
        nameHi: 'मौसम आधारित फसल बीमा योजना',
        description: 'Insurance based on weather parameters deviation',
        descriptionHi: 'मौसम मापदंडों के विचलन पर आधारित बीमा',
        premiumPercentage: 2.0,
        sumInsured: cropSumInsured * 0.8,
        coverage: 'Weather-sensitive crops',
        coverageHi: 'मौसम संवेदनशील फसलें',
        coveredRisks: [
          'Rainfall deviation',
          'Temperature extremes',
          'Humidity variations',
          'Automated claim settlement',
        ],
        coveredRisksHi: [
          'वर्षा विचलन',
          'तापमान चरम सीमा',
          'आर्द्रता भिन्नता',
          'स्वचालित दावा निपटान',
        ],
        icon: Icons.cloud_rounded,
        color: const Color(0xFF0277BD),
      ),
      InsuranceData(
        name: 'Livestock Insurance',
        nameHi: 'पशुधन बीमा',
        description: 'Protection for cattle, buffalo, sheep, and goat',
        descriptionHi: 'गाय, भैंस, भेड़ और बकरी के लिए सुरक्षा',
        premiumPercentage: 3.0,
        sumInsured: 50000,
        coverage: 'All indigenous & crossbred livestock',
        coverageHi: 'सभी देशी और संकर पशुधन',
        coveredRisks: [
          'Death due to accident or disease',
          'Permanent disability',
          'Emergency slaughter',
          'Natural calamities',
        ],
        coveredRisksHi: [
          'दुर्घटना या बीमारी से मृत्यु',
          'स्थायी विकलांगता',
          'आपातकालीन वध',
          'प्राकृतिक आपदाएं',
        ],
        icon: Icons.pets_rounded,
        color: const Color(0xFFE65100),
      ),
      InsuranceData(
        name: 'PM Jeevan Jyoti Bima (PMJJBY)',
        nameHi: 'प्रधानमंत्री जीवन ज्योति बीमा',
        description: 'Life insurance cover for farmers and their families',
        descriptionHi: 'किसानों और उनके परिवारों के लिए जीवन बीमा कवर',
        premiumPercentage: 0.0,
        sumInsured: lifeSumInsured,
        coverage: 'Life Cover (18-50 years)',
        coverageHi: 'जीवन कवर (18-50 वर्ष)',
        coveredRisks: [
          'Death due to any reason',
          'Premium only ₹436/year',
          'Auto-renewal facility',
          'Direct bank account linkage',
        ],
        coveredRisksHi: [
          'किसी भी कारण से मृत्यु',
          'प्रीमियम केवल ₹436/वर्ष',
          'स्वचालित नवीनीकरण सुविधा',
          'सीधा बैंक खाता जुड़ाव',
        ],
        icon: Icons.favorite_rounded,
        color: const Color(0xFFD32F2F),
      ),
    ];
  }

  /// Generate subsidy data based on income and land size
  static List<SubsidyData> generateSubsidyData(double annualIncome, double landSize) {
    final isSmallFarmer = landSize <= 2.0;
    final isBPL = annualIncome <= 100000;

    List<SubsidyData> subsidies = [
      SubsidyData(
        name: 'PM-KISAN',
        nameHi: 'पीएम-किसान',
        description: 'Direct income support to all landholding farmers',
        descriptionHi: 'सभी भूमिधारक किसानों को सीधी आय सहायता',
        amount: 6000,
        frequency: 'Per Year (3 installments)',
        frequencyHi: 'प्रति वर्ष (3 किस्तें)',
        eligibility: 'All landholding farmer families',
        eligibilityHi: 'सभी भूमिधारक किसान परिवार',
        benefits: [
          '₹2,000 every 4 months directly to bank',
          'No need to repay - it\'s a grant',
          'Linked with Aadhaar for transparency',
          'Covers all operational farmers',
        ],
        benefitsHi: [
          'हर 4 महीने ₹2,000 सीधे बैंक में',
          'चुकाने की जरूरत नहीं - यह अनुदान है',
          'पारदर्शिता के लिए आधार से जुड़ा',
          'सभी परिचालन किसानों को कवर करता है',
        ],
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF2E7D32),
      ),
      SubsidyData(
        name: 'Fertilizer Subsidy',
        nameHi: 'उर्वरक सब्सिडी',
        description: 'Subsidized fertilizers through DBT',
        descriptionHi: 'डीबीटी के माध्यम से रियायती उर्वरक',
        amount: (landSize * 2500).clamp(500.0, 10000.0),
        frequency: 'Per Season',
        frequencyHi: 'प्रति मौसम',
        eligibility: 'Farmers with Soil Health Card',
        eligibilityHi: 'मृदा स्वास्थ्य कार्ड वाले किसान',
        benefits: [
          'Up to 50% discount on fertilizers',
          'Direct transfer to bank on purchase',
          'Available at all authorized dealers',
          'No quantity restrictions',
        ],
        benefitsHi: [
          'उर्वरकों पर 50% तक छूट',
          'खरीद पर सीधे बैंक में ट्रांसफर',
          'सभी अधिकृत डीलरों पर उपलब्ध',
          'कोई मात्रा प्रतिबंध नहीं',
        ],
        icon: Icons.science_rounded,
        color: const Color(0xFF00897B),
      ),
      SubsidyData(
        name: 'Seed Subsidy',
        nameHi: 'बीज सब्सिडी',
        description: 'Quality seeds at subsidized rates',
        descriptionHi: 'रियायती दरों पर गुणवत्ता वाले बीज',
        amount: (landSize * 1500).clamp(300.0, 5000.0),
        frequency: 'Per Season',
        frequencyHi: 'प्रति मौसम',
        eligibility: 'All farmers',
        eligibilityHi: 'सभी किसान',
        benefits: [
          '50-75% subsidy on certified seeds',
          'High-yielding varieties available',
          'Drought/pest resistant options',
          'Through state agriculture dept.',
        ],
        benefitsHi: [
          'प्रमाणित बीजों पर 50-75% सब्सिडी',
          'उच्च उपज वाली किस्में उपलब्ध',
          'सूखा/कीट प्रतिरोधी विकल्प',
          'राज्य कृषि विभाग के माध्यम से',
        ],
        icon: Icons.eco_rounded,
        color: const Color(0xFF7CB342),
      ),
      SubsidyData(
        name: 'Farm Equipment Subsidy',
        nameHi: 'कृषि उपकरण सब्सिडी',
        description: 'Subsidy on agricultural machinery purchase',
        descriptionHi: 'कृषि मशीनरी खरीद पर सब्सिडी',
        amount: (annualIncome * 0.25).clamp(5000.0, 100000.0),
        frequency: 'As per purchase',
        frequencyHi: 'खरीद के अनुसार',
        eligibility: isSmallFarmer ? 'Small/Marginal Farmers (Priority)' : 'All Farmers',
        eligibilityHi: isSmallFarmer ? 'छोटे/सीमांत किसान (प्राथमिकता)' : 'सभी किसान',
        benefits: [
          'Up to 50% subsidy on equipment',
          'Covers tractors, tillers, sprayers',
          'Priority for women farmers',
          'Apply through Krishi Portal',
        ],
        benefitsHi: [
          'उपकरणों पर 50% तक सब्सिडी',
          'ट्रैक्टर, टिलर, स्प्रेयर शामिल',
          'महिला किसानों को प्राथमिकता',
          'कृषि पोर्टल से आवेदन करें',
        ],
        icon: Icons.construction_rounded,
        color: const Color(0xFF5D4037),
      ),
    ];

    if (isSmallFarmer) {
      subsidies.add(SubsidyData(
        name: 'PM-KUSUM Scheme',
        nameHi: 'पीएम-कुसुम योजना',
        description: 'Solar pump and solarization of agricultural feeders',
        descriptionHi: 'सोलर पंप और कृषि फीडरों का सोलराइजेशन',
        amount: 35000,
        frequency: 'One-time (60% subsidy)',
        frequencyHi: 'एकमुश्त (60% सब्सिडी)',
        eligibility: 'Farmers with irrigated land',
        eligibilityHi: 'सिंचित भूमि वाले किसान',
        benefits: [
          'Solar pump of 3-10 HP capacity',
          '60% government subsidy',
          '30% bank loan at low interest',
          'Only 10% farmer contribution',
        ],
        benefitsHi: [
          '3-10 HP क्षमता का सोलर पंप',
          '60% सरकारी सब्सिडी',
          'कम ब्याज पर 30% बैंक ऋण',
          'केवल 10% किसान योगदान',
        ],
        icon: Icons.solar_power_rounded,
        color: const Color(0xFFFF8F00),
      ));
    }

    if (isBPL) {
      subsidies.add(SubsidyData(
        name: 'Antyodaya Anna Yojana',
        nameHi: 'अंत्योदय अन्न योजना',
        description: 'Subsidized food grains for poorest families',
        descriptionHi: 'गरीब परिवारों के लिए रियायती खाद्यान्न',
        amount: 2100,
        frequency: 'Monthly',
        frequencyHi: 'मासिक',
        eligibility: 'BPL Families',
        eligibilityHi: 'बीपीएल परिवार',
        benefits: [
          '35 kg food grains per family/month',
          'Rice at ₹3/kg, Wheat at ₹2/kg',
          'Available at fair price shops',
          'Ration card required',
        ],
        benefitsHi: [
          '35 किलो खाद्यान्न प्रति परिवार/माह',
          'चावल ₹3/किलो, गेहूं ₹2/किलो',
          'उचित मूल्य की दुकानों पर उपलब्ध',
          'राशन कार्ड आवश्यक',
        ],
        icon: Icons.rice_bowl_rounded,
        color: const Color(0xFFD32F2F),
      ));
    }

    return subsidies;
  }
}

