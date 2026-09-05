import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../models/report_model.dart';
import 'pdf_view_modal.dart';
import 'parameter_trend_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final MedicalReport report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDietFilter = 'Daily Plan';

  @override
  void initState() {
    super.initState();
    // Default to 'Analysis' tab (index 1) as seen prominently in Screen 4
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${DateFormat('dd MMM yyyy').format(report.reportDate)} • ${report.labProvider}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Report'),
                Tab(text: 'Analysis'),
                Tab(text: 'Diet Plan'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Original Report View
          _buildReportTab(context, report),

          // Tab 2: Analysis View matching Screen 4
          _buildAnalysisTab(context, report),

          // Tab 3: Diet Plan View matching Screen 5
          _buildDietPlanTab(context, report),
        ],
      ),
    );
  }

  // ─── TAB 1: REPORT ───
  Widget _buildReportTab(BuildContext context, MedicalReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.categoryDisplayName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Text('Verified & Sealed', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  report.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lab: ${report.labProvider}\nDoctor: ${report.doctorName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const Divider(height: 28, color: AppColors.divider),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('View Original Lab Document'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerModal(
                            title: report.title,
                            assetPath: report.pdfAssetPath,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Extracted Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...report.parameters.map((param) => _buildReportParamRow(context, param)),
        ],
      ),
    );
  }

  Widget _buildReportParamRow(BuildContext context, TestParameter param) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(param.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text('Range: ${param.minNormal} - ${param.maxNormal} ${param.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text('${param.value} ${param.unit}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ─── TAB 2: ANALYSIS MATCHING SCREEN 4 ───
  Widget _buildAnalysisTab(BuildContext context, MedicalReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overall Result Looks Good! Card matching Screen 4
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Result\nLooks Good!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your blood parameters are within normal range. Keep maintaining a healthy lifestyle!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF047857),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Key Insights Section Header
          const Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Insight 1: Hemoglobin
          _buildInsightCard(
            title: 'Hemoglobin',
            valueText: 'Normal (13.8 g/dL)',
            statusDetail: 'Optimal range',
            icon: Icons.shield_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParameterTrendScreen(parameterName: 'Hemoglobin'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Insight 2: WBC Count
          _buildInsightCard(
            title: 'WBC Count',
            valueText: 'Normal (6,200 /μL)',
            statusDetail: 'No signs of infection',
            icon: Icons.shield_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParameterTrendScreen(parameterName: 'White Blood Cell (WBC)'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Insight 3: Platelet Count
          _buildInsightCard(
            title: 'Platelet Count',
            valueText: 'Normal (2.5 lakh/μL)',
            statusDetail: 'Within healthy range',
            icon: Icons.shield_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // 3. AI Suggestion Card matching Screen 4
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'AI Suggestion',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Your results look stable. Maintain a balanced diet, regular exercise and stay hydrated.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B21B6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String valueText,
    required String statusDetail,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusDetail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 3: DIET PLAN MATCHING SCREEN 5 ───
  Widget _buildDietPlanTab(BuildContext context, MedicalReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Personalized Diet Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Based on your test results and health goals.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Filter pills matching Screen 5
          Row(
            children: [
              _buildDietFilterPill('Daily Plan'),
              const SizedBox(width: 8),
              _buildDietFilterPill('Foods to Include'),
              const SizedBox(width: 8),
              _buildDietFilterPill('Foods to Avoid'),
            ],
          ),
          const SizedBox(height: 18),

          // Meal 1: Breakfast
          _buildMealCard(
            mealName: 'Breakfast',
            menu: 'Oats with fruits, nuts\n+ Green tea',
            foodIcon: Icons.breakfast_dining_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),

          // Meal 2: Lunch
          _buildMealCard(
            mealName: 'Lunch',
            menu: 'Brown rice, grilled chicken,\nsalad, vegetables',
            foodIcon: Icons.lunch_dining_rounded,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),

          // Meal 3: Evening
          _buildMealCard(
            mealName: 'Evening',
            menu: 'Fruits / sprouts\n+ Herbal tea',
            foodIcon: Icons.bakery_dining_rounded,
            color: const Color(0xFFEC4899),
          ),
          const SizedBox(height: 12),

          // Meal 4: Dinner
          _buildMealCard(
            mealName: 'Dinner',
            menu: 'Dal, vegetables, roti\n+ Curd',
            foodIcon: Icons.dinner_dining_rounded,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 20),

          // Nutrition Tip Card matching Screen 5
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco_rounded, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition Tip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Include iron-rich foods like spinach, beetroot, and legumes to maintain healthy hemoglobin levels.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF047857),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDietFilterPill(String label) {
    final isSelected = _selectedDietFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDietFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard({
    required String mealName,
    required String menu,
    required IconData foodIcon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menu,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Food photo circle placeholder matching Screen 5
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(foodIcon, color: color, size: 26),
          ),
        ],
      ),
    );
  }
}
