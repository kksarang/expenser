import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

enum InsightsTimeframe { weekly, monthly, yearly, custom }

class InsightsScreen extends StatefulWidget {
  final TransactionType type;

  const InsightsScreen({super.key, required this.type});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsTimeframe _selectedTimeframe = InsightsTimeframe.monthly;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == TransactionType.income;
    final title = isIncome ? 'Income Insights' : 'Expense Insights';
    final provider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // Get transactions based on type and timeframe
    final filteredTransactions = _getFilteredTransactions(
      provider.transactions,
    );

    // Total Amount
    double totalAmount = filteredTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterTabs(),
              const SizedBox(height: 24),
              _buildHeaderAmount(totalAmount, isIncome),
              const SizedBox(height: 32),

              if (filteredTransactions.isEmpty)
                _buildEmptyState()
              else ...[
                _buildSectionTitle('Category Breakdown'),
                _buildPieChart(
                  filteredTransactions,
                  categoryProvider,
                  totalAmount,
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Key Insights'),
                _buildSmartInsights(
                  filteredTransactions,
                  categoryProvider,
                  isIncome,
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Smart Advice'),
                _buildSmartAdvice(
                  filteredTransactions,
                  categoryProvider,
                  isIncome,
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Top Categories'),
                _buildTopCategories(
                  filteredTransactions,
                  categoryProvider,
                  isIncome,
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No data for this period',
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAmount(double amount, bool isIncome) {
    var format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return Center(
      child: Column(
        children: [
          Text(
            isIncome ? 'Total Income' : 'Total Expenses',
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(amount),
            style: GoogleFonts.inter(
              color: isIncome ? AppColors.income : AppColors.expense,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: InsightsTimeframe.values.map((timeframe) {
          final isSelected = _selectedTimeframe == timeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = timeframe;
                  if (timeframe == InsightsTimeframe.custom) {
                    _pickCustomDateRange();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeframe.name.substring(0, 1).toUpperCase() +
                      timeframe.name.substring(1),
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    } else {
      // Revert if cancelled
      setState(() => _selectedTimeframe = InsightsTimeframe.monthly);
    }
  }

  List<TransactionEntity> _getFilteredTransactions(
    List<TransactionEntity> all,
  ) {
    return all.where((t) {
      if (t.type != widget.type) return false;

      final date = t.date;
      final now = DateTime.now();

      switch (_selectedTimeframe) {
        case InsightsTimeframe.weekly:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfWeek.add(const Duration(days: 7)));
        case InsightsTimeframe.monthly:
          return date.year == now.year && date.month == now.month;
        case InsightsTimeframe.yearly:
          return date.year == now.year;
        case InsightsTimeframe.custom:
          if (_customStartDate != null && _customEndDate != null) {
            return date.isAfter(
                  _customStartDate!.subtract(const Duration(days: 1)),
                ) &&
                date.isBefore(_customEndDate!.add(const Duration(days: 1)));
          }
          return true; // if not selected yet
      }
    }).toList();
  }

  // ==== CHARTS ====

  Widget _buildPieChart(
    List<TransactionEntity> txs,
    CategoryProvider catProv,
    double total,
  ) {
    if (total == 0) return const SizedBox.shrink();

    // Group by category
    Map<String, double> catAmounts = {};
    for (var t in txs) {
      catAmounts[t.categoryId] = (catAmounts[t.categoryId] ?? 0) + t.amount;
    }

    final sortedCats = catAmounts.keys.toList()
      ..sort((a, b) => catAmounts[b]!.compareTo(catAmounts[a]!));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(sortedCats.length, (i) {
                  final isTouched = i == _touchedPieIndex;
                  final radius = isTouched ? 60.0 : 50.0;
                  final catId = sortedCats[i];
                  final cat = catProv.getCategoryById(catId);
                  final val = catAmounts[catId]!;
                  final pct = (val / total * 100).toStringAsFixed(1);

                  return PieChartSectionData(
                    color: Color(cat?.colorValue ?? 0xFF9E9E9E),
                    value: val,
                    title: isTouched ? '$pct%' : '',
                    radius: radius,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: sortedCats.map((catId) {
              final cat = catProv.getCategoryById(catId);
              final val = catAmounts[catId]!;
              final pct = (val / total * 100).toStringAsFixed(1);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(cat?.colorValue ?? 0xFF9E9E9E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${cat?.name ?? 'Unknown'} ($pct%)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==== INSIGHTS & ADVICE ====

  Widget _buildSmartInsights(
    List<TransactionEntity> txs,
    CategoryProvider catProv,
    bool isIncome,
  ) {
    // Generate some mock AI strings based on real data
    List<String> insights = [];

    if (txs.isNotEmpty) {
      Map<String, double> catAmounts = {};
      for (var t in txs) {
        catAmounts[t.categoryId] = (catAmounts[t.categoryId] ?? 0) + t.amount;
      }
      var sortedCats = catAmounts.keys.toList()
        ..sort((a, b) => catAmounts[b]!.compareTo(catAmounts[a]!));
      var topCatName =
          catProv.getCategoryById(sortedCats.first)?.name ??
          'a specific category';

      if (isIncome) {
        insights.add("Your primary income source is $topCatName.");
        if (catAmounts.length == 1) {
          insights.add("You rely entirely on one income stream this period.");
        } else {
          insights.add(
            "You have diversified income across ${catAmounts.length} streams.",
          );
        }
      } else {
        insights.add(
          "$topCatName spending is your largest expense this period.",
        );

        // Simple logic for "increasing in last 3 days"
        final now = DateTime.now();
        final last3Days = txs
            .where((t) => t.date.isAfter(now.subtract(const Duration(days: 3))))
            .toList();
        if (last3Days.isNotEmpty && last3Days.length > txs.length * 0.4) {
          insights.add("Your expenses have spiked in the last 3 days.");
        } else {
          insights.add("Your spending pace seems steady.");
        }
      }
    } else {
      insights.add("Not enough data to generate insights.");
    }

    return Column(
      children: insights
          .map(
            (text) => _buildInsightTile(text, Icons.auto_awesome, Colors.amber),
          )
          .toList(),
    );
  }

  Widget _buildSmartAdvice(
    List<TransactionEntity> txs,
    CategoryProvider catProv,
    bool isIncome,
  ) {
    List<String> advices = [];

    if (txs.isNotEmpty) {
      Map<String, double> catAmounts = {};
      for (var t in txs) {
        catAmounts[t.categoryId] = (catAmounts[t.categoryId] ?? 0) + t.amount;
      }
      var sortedCats = catAmounts.keys.toList()
        ..sort((a, b) => catAmounts[b]!.compareTo(catAmounts[a]!));
      var topCatName =
          catProv.getCategoryById(sortedCats.first)?.name ??
          'a specific category';

      if (isIncome) {
        advices.add(
          "Consider investing 20% of your income into savings or mutual funds.",
        );
        advices.add(
          "Additional side-income sources could improve your financial stability.",
        );
      } else {
        advices.add(
          "Consider setting a monthly budget to control your $topCatName expenses.",
        );
        advices.add(
          "Reducing non-essential purchases could increase your monthly savings.",
        );
      }
    } else {
      advices.add(
        "Add more transactions to see personalized financial advice.",
      );
    }

    return Column(
      children: advices
          .map(
            (text) =>
                _buildInsightTile(text, Icons.lightbulb_outline, Colors.blue),
          )
          .toList(),
    );
  }

  Widget _buildInsightTile(String text, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==== TOP CATEGORIES ====

  Widget _buildTopCategories(
    List<TransactionEntity> txs,
    CategoryProvider catProv,
    bool isIncome,
  ) {
    if (txs.isEmpty) return const SizedBox.shrink();

    Map<String, double> catAmounts = {};
    for (var t in txs) {
      catAmounts[t.categoryId] = (catAmounts[t.categoryId] ?? 0) + t.amount;
    }

    var sortedCats = catAmounts.keys.toList()
      ..sort((a, b) => catAmounts[b]!.compareTo(catAmounts[a]!));
    var top5 = sortedCats.take(5).toList();
    var format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: top5.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final catId = top5[index];
          final amount = catAmounts[catId]!;
          final cat = catProv.getCategoryById(catId);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(cat?.colorValue ?? 0xFFEEEEEE).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(
                  cat?.iconCodePoint ?? 0xe59c,
                  fontFamily: 'MaterialIcons',
                ),
                color: Color(cat?.colorValue ?? 0xFF000000),
              ),
            ),
            title: Text(
              cat?.name ?? 'Unknown',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Text(
              format.format(amount),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          );
        },
      ),
    );
  }
}
