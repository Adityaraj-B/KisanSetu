import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/farmer_provider.dart';
import '../data/crop_finance_data.dart';

class CropFinanceScreen extends StatefulWidget {
  const CropFinanceScreen({super.key});

  @override
  State<CropFinanceScreen> createState() => _CropFinanceScreenState();
}

class _CropFinanceScreenState extends State<CropFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return Consumer<FarmerProvider>(
      builder: (context, farmer, child) {
        final annualIncome = CropFinanceDataGenerator.getAnnualIncomeValue(farmer.annualIncome);
        final landSize = farmer.landSizeAcres > 0 ? farmer.landSizeAcres : 2.0;

        final loans = CropFinanceDataGenerator.generateLoanData(annualIncome, landSize);
        final insurances = CropFinanceDataGenerator.generateInsuranceData(annualIncome, landSize);
        final subsidies = CropFinanceDataGenerator.generateSubsidyData(annualIncome, landSize);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF00695C),
                // leading: IconButton(
                //   icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                //   onPressed: () => Navigator.pop(context),
                // ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00695C), Color(0xFF00897B)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
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
                                        langCode == 'hi' ? 'कृषि वित्त' : (langCode == 'mr' ? 'कृषी वित्त' : 'Crop Finance'),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        langCode == 'hi'
                                            ? 'ऋण, बीमा और सब्सिडी'
                                            : (langCode == 'mr' ? 'कर्ज, विमा आणि अनुदान' : 'Loans, Insurance & Subsidies'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _SummaryChip(
                                  icon: Icons.currency_rupee_rounded,
                                  label: langCode == 'hi' ? 'ऋण' : (langCode == 'mr' ? 'कर्ज' : 'Loans'),
                                  value: '${loans.length}',
                                ),
                                const SizedBox(width: 12),
                                _SummaryChip(
                                  icon: Icons.shield_rounded,
                                  label: langCode == 'hi' ? 'बीमा' : (langCode == 'mr' ? 'विमा' : 'Insurance'),
                                  value: '${insurances.length}',
                                ),
                                const SizedBox(width: 12),
                                _SummaryChip(
                                  icon: Icons.card_giftcard_rounded,
                                  label: langCode == 'hi' ? 'सब्सिडी' : (langCode == 'mr' ? 'अनुदान' : 'Subsidies'),
                                  value: '${subsidies.length}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: const Color(0xFF00695C),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: [
                        Tab(text: langCode == 'hi' ? 'ऋण' : (langCode == 'mr' ? 'कर्ज' : 'Loans')),
                        Tab(text: langCode == 'hi' ? 'बीमा' : (langCode == 'mr' ? 'विमा' : 'Insurance')),
                        Tab(text: langCode == 'hi' ? 'सब्सिडी' : (langCode == 'mr' ? 'अनुदान' : 'Subsidies')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildLoansTab(loans, langCode),
                _buildInsuranceTab(insurances, langCode),
                _buildSubsidiesTab(subsidies, langCode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoansTab(List<LoanData> loans, String langCode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return _LoanCard(loan: loan, langCode: langCode);
      },
    );
  }

  Widget _buildInsuranceTab(List<InsuranceData> insurances, String langCode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insurances.length,
      itemBuilder: (context, index) {
        final insurance = insurances[index];
        return _InsuranceCard(insurance: insurance, langCode: langCode);
      },
    );
  }

  Widget _buildSubsidiesTab(List<SubsidyData> subsidies, String langCode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subsidies.length,
      itemBuilder: (context, index) {
        final subsidy = subsidies[index];
        return _SubsidyCard(subsidy: subsidy, langCode: langCode);
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanData loan;
  final String langCode;

  const _LoanCard({required this.loan, required this.langCode});

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: loan.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [loan.color, loan.color.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(loan.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.getLocalizedName(langCode),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        loan.provider,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.getLocalizedDescription(langCode),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatBox(
                      label: langCode == 'hi' ? 'ब्याज दर' : (langCode == 'mr' ? 'व्याज दर' : 'Interest'),
                      value: '${loan.interestRate}%',
                      color: loan.color,
                    ),
                    const SizedBox(width: 12),
                    _StatBox(
                      label: langCode == 'hi' ? 'पात्र राशि' : (langCode == 'mr' ? 'पात्र रक्कम' : 'Eligible'),
                      value: _formatCurrency(loan.eligibleAmount),
                      color: loan.color,
                    ),
                    const SizedBox(width: 12),
                    _StatBox(
                      label: langCode == 'hi' ? 'अवधि' : (langCode == 'mr' ? 'कालावधी' : 'Tenure'),
                      value: loan.tenure.split(' ').first,
                      color: loan.color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  langCode == 'hi' ? 'लाभ:' : (langCode == 'mr' ? 'फायदे:' : 'Benefits:'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  loan.getLocalizedBenefits(langCode).length,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, color: loan.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loan.getLocalizedBenefits(langCode)[i],
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(langCode == 'hi' ? 'आवेदन लिंक जल्द आ रहा है' : (langCode == 'mr' ? 'अर्ज दुवा लवकरच येत आहे' : 'Application link coming soon')),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: loan.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCode == 'hi' ? 'आवेदन करें' : (langCode == 'mr' ? 'अर्ज करा' : 'Apply Now'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  final InsuranceData insurance;
  final String langCode;

  const _InsuranceCard({required this.insurance, required this.langCode});

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final premiumAmount = insurance.sumInsured * (insurance.premiumPercentage / 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: insurance.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [insurance.color, insurance.color.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(insurance.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insurance.getLocalizedName(langCode),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        insurance.getLocalizedCoverage(langCode),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    insurance.premiumPercentage > 0
                        ? '${insurance.premiumPercentage}%'
                        : '₹436/yr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insurance.getLocalizedDescription(langCode),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: insurance.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              langCode == 'hi' ? 'बीमित राशि' : (langCode == 'mr' ? 'विमित रक्कम' : 'Sum Insured'),
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(insurance.sumInsured),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: insurance.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              langCode == 'hi' ? 'आपका प्रीमियम' : (langCode == 'mr' ? 'आपला प्रीमियम' : 'Your Premium'),
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              insurance.premiumPercentage > 0
                                  ? _formatCurrency(premiumAmount)
                                  : '₹436',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  langCode == 'hi' ? 'कवर किए गए जोखिम:' : (langCode == 'mr' ? 'संरक्षित जोखीम:' : 'Covered Risks:'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  insurance.getLocalizedCoveredRisks(langCode).length,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_rounded, color: insurance.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insurance.getLocalizedCoveredRisks(langCode)[i],
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(langCode == 'hi' ? 'आवेदन लिंक जल्द आ रहा है' : (langCode == 'mr' ? 'अर्ज दुवा लवकरच येत आहे' : 'Application link coming soon')),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: insurance.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCode == 'hi' ? 'बीमा लें' : (langCode == 'mr' ? 'विमा घ्या' : 'Get Insured'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubsidyCard extends StatelessWidget {
  final SubsidyData subsidy;
  final String langCode;

  const _SubsidyCard({required this.subsidy, required this.langCode});

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: subsidy.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [subsidy.color, subsidy.color.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(subsidy.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subsidy.getLocalizedName(langCode),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subsidy.getLocalizedFrequency(langCode),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatCurrency(subsidy.amount),
                    style: TextStyle(
                      color: subsidy.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subsidy.getLocalizedDescription(langCode),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subsidy.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline_rounded, color: subsidy.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langCode == 'hi' ? 'पात्रता:' : (langCode == 'mr' ? 'पात्रता:' : 'Eligibility:'),
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            Text(
                              subsidy.getLocalizedEligibility(langCode),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: subsidy.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  langCode == 'hi' ? 'लाभ:' : (langCode == 'mr' ? 'फायदे:' : 'Benefits:'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  subsidy.getLocalizedBenefits(langCode).length,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.card_giftcard_rounded, color: subsidy.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subsidy.getLocalizedBenefits(langCode)[i],
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(langCode == 'hi' ? 'आवेदन लिंक जल्द आ रहा है' : (langCode == 'mr' ? 'अर्ज दुवा लवकरच येत आहे' : 'Application link coming soon')),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subsidy.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langCode == 'hi' ? 'आवेदन करें' : (langCode == 'mr' ? 'अर्ज करा' : 'Apply Now'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}