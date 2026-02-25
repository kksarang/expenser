import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../core/utils/responsive.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/pdf_export_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final PdfExportService _pdfExportService = PdfExportService();

  AnalyticsType _selectedType = AnalyticsType.month;
  DateTime _selectedDate = DateTime.now();
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final isSmall = Responsive.isSmall(context);

    // Get all transactions
    final allTransactions = transactionProvider.transactions;

    // Filter based on selected state
    final filteredTransactions = _analyticsService.filterTransactions(
      allTransactions,
      _selectedType,
      _selectedDate,
      customStartDate: _customStartDate,
      customEndDate: _customEndDate,
    );

    // Calculate figures
    final totalIncome = _analyticsService.getTotalIncome(filteredTransactions);
    final totalExpense = _analyticsService.getTotalExpense(
      filteredTransactions,
    );
    final balance = _analyticsService.getBalance(filteredTransactions);
    final savingsRate = _analyticsService.getSavingsRate(filteredTransactions);
    final categoryAmounts = _analyticsService.getCategoryWiseExpense(
      filteredTransactions,
    );

    final categoryCounts = <String, int>{};
    for (var t in filteredTransactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      categoryCounts[t.categoryId] = (categoryCounts[t.categoryId] ?? 0) + 1;
    }

    // Sort categories by amount
    final sortedCategoryIds = categoryAmounts.keys.toList()
      ..sort((a, b) => categoryAmounts[b]!.compareTo(categoryAmounts[a]!));

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Export Analytics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.share,
                          color: AppColors.primary,
                        ),
                        title: const Text('Share PDF'),
                        onTap: () {
                          Navigator.pop(context);
                          _exportPdf(
                            totalIncome,
                            totalExpense,
                            balance,
                            savingsRate,
                            categoryAmounts,
                            categoryCounts,
                            categoryProvider,
                            share: true,
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.save_alt,
                          color: AppColors.primary,
                        ),
                        title: const Text('Save / Print PDF'),
                        onTap: () {
                          Navigator.pop(context);
                          _exportPdf(
                            totalIncome,
                            totalExpense,
                            balance,
                            savingsRate,
                            categoryAmounts,
                            categoryCounts,
                            categoryProvider,
                            share: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilterTabs()),
          SliverToBoxAdapter(child: _buildDateSelector()),
          if (filteredTransactions.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            SliverToBoxAdapter(
              child: _buildSummaryCards(
                totalIncome,
                totalExpense,
                balance,
                savingsRate,
                currencyFormat,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildIncomeExpenseChart(filteredTransactions),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Top Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildDonutChart(
                sortedCategoryIds,
                categoryAmounts,
                categoryProvider,
                totalExpense,
                isSmall,
                currencyFormat,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final categoryId = sortedCategoryIds[index];
                final amount = categoryAmounts[categoryId]!;
                final count = categoryCounts[categoryId]!;
                final category = categoryProvider.getCategoryById(categoryId);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(
                        category?.colorValue ?? 0xFFEEE5FF,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      IconData(
                        category?.iconCodePoint ?? 0xe59c,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Color(category?.colorValue ?? 0xFF000000),
                    ),
                  ),
                  title: Text(
                    category?.name ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$count Transactions',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  trailing: Text(
                    '- ${currencyFormat.format(amount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.expense,
                    ),
                  ),
                );
              }, childCount: sortedCategoryIds.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: AnalyticsType.values.map((type) {
            final isSelected = _selectedType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                    // Reset custom dates if switching back
                    if (type != AnalyticsType.custom) {
                      _customStartDate = null;
                      _customEndDate = null;
                    } else {
                      _pickCustomDateRange();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    type.name.substring(0, 1).toUpperCase() +
                        type.name.substring(1),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                if (_selectedType == AnalyticsType.week) {
                  _selectedDate = _selectedDate.subtract(
                    const Duration(days: 7),
                  );
                } else if (_selectedType == AnalyticsType.month) {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month - 1,
                    _selectedDate.day,
                  );
                } else if (_selectedType == AnalyticsType.year) {
                  _selectedDate = DateTime(
                    _selectedDate.year - 1,
                    _selectedDate.month,
                    _selectedDate.day,
                  );
                }
              });
            },
          ),
          InkWell(
            onTap: _pickDate,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getDateLabel(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                if (_selectedType == AnalyticsType.week) {
                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                } else if (_selectedType == AnalyticsType.month) {
                  _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month + 1,
                    _selectedDate.day,
                  );
                } else if (_selectedType == AnalyticsType.year) {
                  _selectedDate = DateTime(
                    _selectedDate.year + 1,
                    _selectedDate.month,
                    _selectedDate.day,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String _getDateLabel() {
    switch (_selectedType) {
      case AnalyticsType.week:
        final startOfWeek = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final format = DateFormat('MMM dd');
        return "${format.format(startOfWeek)} - ${format.format(endOfWeek)}";
      case AnalyticsType.month:
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case AnalyticsType.year:
        return DateFormat('yyyy').format(_selectedDate);
      case AnalyticsType.custom:
        if (_customStartDate != null && _customEndDate != null) {
          final format = DateFormat('MMM dd');
          return "${format.format(_customStartDate!)} - ${format.format(_customEndDate!)}";
        }
        return "Select Date Range";
    }
  }

  Future<void> _pickDate() async {
    if (_selectedType == AnalyticsType.month) {
      final selected = await showMonthPicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (selected != null) {
        setState(() => _selectedDate = selected);
      }
    } else if (_selectedType == AnalyticsType.year) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select Year"),
            content: SizedBox(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: _selectedDate,
                selectedDate: _selectedDate,
                onChanged: (DateTime dateTime) {
                  setState(() => _selectedDate = dateTime);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      );
    } else if (_selectedType == AnalyticsType.custom) {
      _pickCustomDateRange();
    } else {
      final selected = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (selected != null) {
        setState(() => _selectedDate = selected);
      }
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedType = AnalyticsType.custom;
      });
    } else if (_customStartDate == null) {
      setState(() => _selectedType = AnalyticsType.month); // fallback
    }
  }

  Widget _buildSummaryCards(
    double totalIncome,
    double totalExpense,
    double balance,
    double savingsRate,
    NumberFormat format,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  "Income",
                  format.format(totalIncome),
                  Icons.arrow_downward,
                  Colors.green,
                  Colors.green.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  "Expense",
                  format.format(totalExpense),
                  Icons.arrow_upward,
                  Colors.red,
                  Colors.red.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  "Balance",
                  format.format(balance),
                  Icons.account_balance_wallet,
                  Colors.blue,
                  Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  "Savings Rate",
                  "${savingsRate.toStringAsFixed(1)}%",
                  Icons.savings,
                  Colors.purple,
                  Colors.purple.shade50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String amount,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(List<TransactionEntity> transactions) {
    // Generate simple Bar chart comparing Income vs Expense overall for the period
    final income = _analyticsService.getTotalIncome(transactions);
    final expense = _analyticsService.getTotalExpense(transactions);
    if (income == 0 && expense == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Income vs Expense",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (income > expense ? income : expense) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value == 0 ? 'Income' : 'Expense',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: income,
                          color: Colors.green,
                          width: 25,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expense,
                          color: Colors.red,
                          width: 25,
                          borderRadius: BorderRadius.circular(6),
                        ),
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

  Widget _buildDonutChart(
    List<String> sortedIds,
    Map<String, double> amounts,
    CategoryProvider provider,
    double total,
    bool isSmall,
    NumberFormat format,
  ) {
    if (total == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: isSmall ? 55 : 65,
              sections: _generateSections(
                sortedIds,
                amounts,
                provider,
                total,
                isSmall,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Expense',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  format.format(total),
                  style: TextStyle(
                    fontSize: isSmall ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections(
    List<String> sortedIds,
    Map<String, double> amounts,
    CategoryProvider provider,
    double total,
    bool isSmall,
  ) {
    return List.generate(sortedIds.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched
          ? (isSmall ? 25.0 : 30.0)
          : (isSmall ? 20.0 : 25.0);

      final categoryId = sortedIds[i];
      final value = amounts[categoryId]!;
      final category = provider.getCategoryById(categoryId);
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        color: Color(category?.colorValue ?? 0xFF7F3DFF),
        value: value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: radius,
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No transactions found for this period.",
            style: TextStyle(color: AppColors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Lottie.network(
            'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(
    double totalIncome,
    double totalExpense,
    double balance,
    double savingsRate,
    Map<String, double> categoryAmounts,
    Map<String, int> categoryCounts,
    CategoryProvider categoryProvider, {
    bool share = true,
  }) async {
    final names = <String, String>{};
    for (var id in categoryAmounts.keys) {
      names[id] = categoryProvider.getCategoryById(id)?.name ?? 'Unknown';
    }

    try {
      await _pdfExportService.exportAnalyticsReport(
        type: _selectedType,
        selectedDate: _selectedDate,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        savingsRate: savingsRate,
        categoryWiseExpense: categoryAmounts,
        categoryCounts: categoryCounts,
        categoryNames: names,
        share: share,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }
}
