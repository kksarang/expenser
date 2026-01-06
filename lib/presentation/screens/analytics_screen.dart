import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

import '../../domain/entities/category_entity.dart';
import '../../core/utils/responsive.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();
  int touchedIndex = -1;

  @override
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final responsiveWidth = Responsive.width(context);
    final isSmall = Responsive.isSmall(context);

    // Filter transactions for selected month and expense type
    final transactions = transactionProvider.transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.date.year == _selectedDate.year &&
          t.date.month == _selectedDate.month;
    }).toList();

    // Group by Category
    final Map<String, double> categoryAmounts = {};
    final Map<String, int> categoryCounts = {};
    double totalExpense = 0;

    for (var t in transactions) {
      // Find category name or use ID as fallback
      final categoryId = t.categoryId;
      categoryAmounts[categoryId] =
          (categoryAmounts[categoryId] ?? 0) + t.amount;
      categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      totalExpense += t.amount;
    }

    // Sort categories by amount (descending)
    final sortedCategoryIds = categoryAmounts.keys.toList()
      ..sort((a, b) => categoryAmounts[b]!.compareTo(categoryAmounts[a]!));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Financial Report',
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
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
            ),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header / Donut Chart Section
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth * 0.05,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _selectMonth(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: Responsive.fontSize(context, 20),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMMM yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(context, 14),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Chart Toggle or Legend Button could go here, omitting for simplicity/cleanliness
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: isSmall ? 180 : 220,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Small gap between sections
                        centerSpaceRadius: isSmall ? 60 : 70, // Create Donut
                        sections: _generateSections(
                          sortedCategoryIds,
                          categoryAmounts,
                          categoryProvider,
                          totalExpense,
                          isSmall,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Expense',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 14),
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            // User requested Indian English formatting
                            NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: '₹',
                              decimalDigits: 0,
                            ).format(totalExpense),
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 28),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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

          const SizedBox(height: 10),

          // Transaction List
          Expanded(
            child: sortedCategoryIds.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "No expenses for this month",
                          style: TextStyle(color: AppColors.grey),
                        ),
                        Lottie.network(
                          'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json',
                          width: isSmall ? 150 : 200,
                          height: isSmall ? 150 : 200,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth * 0.05,
                      vertical: 10,
                    ),
                    itemCount: sortedCategoryIds.length,
                    itemBuilder: (context, index) {
                      final categoryId = sortedCategoryIds[index];
                      final amount = categoryAmounts[categoryId]!;
                      final count = categoryCounts[categoryId]!;
                      final category = categoryProvider.getCategoryById(
                        categoryId,
                      );

                      // Unified ListTile Style
                      return ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 16),
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
                            size: Responsive.fontSize(context, 24),
                          ),
                        ),
                        title: Text(
                          category?.name ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                        ),
                        subtitle: Text(
                          '$count Transactions',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: Responsive.fontSize(context, 13),
                          ),
                        ),
                        trailing: Text(
                          '- ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 16),
                            color: AppColors.expense,
                          ),
                        ),
                      );
                    },
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
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade200,
          value: 100,
          title: '',
          radius: isSmall ? 15 : 20,
        ),
      ];
    }

    return List.generate(sortedIds.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched
          ? (isSmall ? 25.0 : 30.0)
          : (isSmall ? 20.0 : 25.0); // Ring width

      final categoryId = sortedIds[i];
      final value = amounts[categoryId]!;
      final category = provider.getCategoryById(categoryId);

      return PieChartSectionData(
        color: Color(category?.colorValue ?? 0xFF7F3DFF),
        value: value,
        title: '', // No title on sections for cleaner look
        radius: radius,
      );
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      // Use year-month picker mode if available or just stick to standard picker and ignore day
      initialDatePickerMode: DatePickerMode.year,
    );
    // Note: Standard showDatePicker picks a day.
    // For a true Month Picker, we'd need a custom widget or 'month_picker_dialog' package.
    // For now, standard picker is fine, we just use the month/year.
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
