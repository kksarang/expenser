import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

import '../../domain/entities/category_entity.dart';
import '../utils/transaction_actions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../core/utils/responsive.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionType _selectedTab = TransactionType.expense;
  Timeframe _selectedTimeframe = Timeframe.week;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final summaryData = provider.getSummary(_selectedTimeframe);
    final responsiveWidth = Responsive.width(context);
    final isSmall = Responsive.isSmall(context);

    // Filter transactions based on selected tab
    final filteredTransactions = provider.transactions
        .where((t) => t.type == _selectedTab)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: responsiveWidth * 0.05),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Expenser',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Reference Balance Cards (Income - Light Purple, Expense - Light Peach)
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      label: 'Total Income',
                      amount: provider.totalIncome,
                      bgColor: const Color(0xFFEEE5FF), // Light Purple
                      iconColor: AppColors.primary,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OverviewCard(
                      label: 'Total Expenses',
                      amount: provider.totalExpense,
                      bgColor: const Color(0xFFFFEFE9), // Light Peach
                      iconColor: const Color(0xFFFF643B), // Orange/Peach Dark
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Statistics Section with Timeframe Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Timeframe>(
                        value: _selectedTimeframe,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: Responsive.fontSize(context, 18),
                          color: AppColors.grey,
                        ),
                        onChanged: (Timeframe? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTimeframe = newValue;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: Timeframe.week,
                            child: Text(
                              'Weekly',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(context, 13),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: Timeframe.month,
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(context, 13),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: Timeframe.year,
                            child: Text(
                              'Yearly',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bar Chart Area (Real Data)
              SizedBox(
                height: isSmall ? 180 : 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(summaryData), // Dynamic MaxY
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30, // Give space for titles
                          getTitlesWidget: (value, meta) {
                            final style = TextStyle(
                              color: AppColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(context, 10),
                            );
                            int index = value.toInt();

                            if (index < 0 || index >= summaryData.length)
                              return const SizedBox.shrink();

                            String text = '';
                            if (_selectedTimeframe == Timeframe.week) {
                              // Last 7 days
                              DateTime date = DateTime.now().subtract(
                                Duration(days: 6 - index),
                              );
                              text = DateFormat.E().format(date);
                            } else if (_selectedTimeframe == Timeframe.month) {
                              // Days of Month - show sparse labels to avoid clutter
                              if (index % 5 == 0 ||
                                  index == summaryData.length - 1) {
                                // Show every 5th day and last day
                                text = '${index + 1}';
                              }
                            } else if (_selectedTimeframe == Timeframe.year) {
                              // Months
                              text = DateFormat.MMM().format(
                                DateTime(2022, index + 1),
                              );
                            }

                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            // Compact format for large numbers
                            if (value >= 1000)
                              return Text(
                                '${(value / 1000).toStringAsFixed(1)}k',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: Responsive.fontSize(context, 10),
                                ),
                              );
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: Responsive.fontSize(context, 10),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.lightGrey,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(summaryData.length, (index) {
                      final data = summaryData[index];
                      return _makeGroupData(
                        index,
                        data['income'] ?? 0,
                        data['expense'] ?? 0,
                        isSmall,
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tabs: Income | Expenses (Toggle)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedTab = TransactionType.income,
                        ),
                        child: _TabButton(
                          label: 'Income',
                          isSelected: _selectedTab == TransactionType.income,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedTab = TransactionType.expense,
                        ),
                        child: _TabButton(
                          label: 'Expenses',
                          isSelected: _selectedTab == TransactionType.expense,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Transactions List (Filtered)
              filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Lottie.network(
                            'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json',
                            width: isSmall ? 150 : 200,
                            height: isSmall ? 150 : 200,
                          ),
                          const Text(
                            'No activities found',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length > 10
                          ? 10
                          : filteredTransactions.length, // Show more
                      itemBuilder: (context, index) {
                        final transaction =
                            filteredTransactions[filteredTransactions.length -
                                1 -
                                index];
                        final category = Provider.of<CategoryProvider>(
                          context,
                        ).getCategoryById(transaction.categoryId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            key: ValueKey(transaction.id),
                            startActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) =>
                                      navigateToEdit(context, transaction),
                                  backgroundColor: AppColors.income,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) => confirmDeleteTransaction(
                                    context,
                                    transaction,
                                  ),
                                  backgroundColor: AppColors.expense,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: _AnimatedTransactionCard(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
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
                                      color: Color(
                                        category?.colorValue ?? 0xFF000000,
                                      ),
                                      size: Responsive.fontSize(context, 24),
                                    ),
                                  ),
                                  title: Text(
                                    category?.name ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.fontSize(
                                        context,
                                        16,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(transaction.date),
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${transaction.type == TransactionType.expense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color:
                                              transaction.type ==
                                                  TransactionType.expense
                                              ? AppColors.expense
                                              : AppColors.income,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Responsive.fontSize(
                                            context,
                                            16,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: AppColors.grey,
                                          size: 22,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            navigateToEdit(
                                              context,
                                              transaction,
                                            );
                                          } else if (value == 'delete') {
                                            confirmDeleteTransaction(
                                              context,
                                              transaction,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 12),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
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
                        );
                      },
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<Map<String, double>> data) {
    double max = 0;
    for (var item in data) {
      if ((item['income'] ?? 0) > max) max = item['income']!;
      if ((item['expense'] ?? 0) > max) max = item['expense']!;
    }
    return max == 0 ? 100 : max * 1.2; // Add buffer
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2, bool isSmall) {
    final width = isSmall ? 4.0 : 8.0; // Responsive bar width
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.primary,
          width: width,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: y2,
          color: const Color(0xFFFF643B),
          width: width,
          borderRadius: BorderRadius.circular(4),
        ), // Peach color
      ],
      barsSpace: _selectedTimeframe == Timeframe.month
          ? (isSmall ? 1 : 2)
          : (isSmall ? 2 : 4),
    );
  }
}

class _AnimatedTransactionCard extends StatefulWidget {
  final Widget child;

  const _AnimatedTransactionCard({required this.child});

  @override
  State<_AnimatedTransactionCard> createState() =>
      _AnimatedTransactionCardState();
}

class _AnimatedTransactionCardState extends State<_AnimatedTransactionCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isPressed ? 4.0 : 0.0)
          ..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _isPressed ? 8 : 16,
              offset: Offset(0, _isPressed ? 4 : 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color bgColor; // Used as base or gradient start
  final Color iconColor;
  final IconData icon;

  const _OverviewCard({
    required this.label,
    required this.amount,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Create a subtle gradient based on the bgColor
    final isIncome = label.contains('Income');
    final gradientColors = isIncome
        ? [const Color(0xFFF3E8FF), const Color(0xFFEADBFF)] // Purple-ish
        : [const Color(0xFFFFEFE9), const Color(0xFFFFE0D1)]; // Peach-ish

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4), // Soften shadow
            blurRadius: 16, // Increase blur for modern look
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: Responsive.fontSize(context, 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: Responsive.fontSize(context, 13),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFF643B)
            : Colors.transparent, // Orange for selected
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
      ),
    );
  }
}
