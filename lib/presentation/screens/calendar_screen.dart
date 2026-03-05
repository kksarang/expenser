import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../utils/transaction_actions.dart';
import '../../core/utils/responsive.dart';
import 'transaction_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  // Returns true if two dates are the same calendar day
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Number of days in the focused month
  int get _daysInMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

  // Weekday of the 1st of the month (Mon=1 … Sun=7), adjusted to Mon-based grid
  int get _startWeekday {
    final wd = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    return wd; // 1=Mon … 7=Sun
  }

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);

    final allTransactions = txProvider.transactions;

    // Days that have at least one transaction in focused month
    final Set<int> daysWithTx = {};
    for (final tx in allTransactions) {
      if (tx.date.year == _focusedMonth.year &&
          tx.date.month == _focusedMonth.month) {
        daysWithTx.add(tx.date.day);
      }
    }

    // Transactions for selected day
    final dailyTxs = txProvider.getTransactionsByDate(_selectedDay);

    final totalForDay = dailyTxs.fold<double>(
      0,
      (sum, tx) =>
          sum + (tx.type == TransactionType.expense ? -tx.amount : tx.amount),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Calendar view',
          style: GoogleFonts.inter(
            fontSize: Responsive.fontSize(context, 17),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Calendar Card ────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: GoogleFonts.inter(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        _NavArrow(icon: Icons.chevron_left, onTap: _prevMonth),
                        const SizedBox(width: 4),
                        _NavArrow(icon: Icons.chevron_right, onTap: _nextMonth),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Day-of-week headers
                _buildDayHeaders(context),

                const SizedBox(height: 8),

                // Calendar grid
                _buildCalendarGrid(context, daysWithTx),
              ],
            ),
          ),

          // ── Day summary + Transactions ────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Date label + total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMM').format(_selectedDay),
                        style: GoogleFonts.inter(
                          fontSize: Responsive.fontSize(context, 15),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (dailyTxs.isNotEmpty)
                        Text(
                          '${totalForDay >= 0 ? '+' : ''}₹${totalForDay.abs().toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: Responsive.fontSize(context, 15),
                            fontWeight: FontWeight.bold,
                            color: totalForDay >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Transaction list or empty state
                  if (dailyTxs.isEmpty)
                    _EmptyDay()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dailyTxs.length,
                      itemBuilder: (context, i) {
                        final tx = dailyTxs[i];
                        final cat = catProvider.getCategoryById(tx.categoryId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 1.5,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _CalendarTxTile(
                                tx: tx,
                                cat: cat,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransactionDetailScreen(
                                      transaction: tx,
                                    ),
                                  ),
                                ),
                                onEdit: () => navigateToEdit(context, tx),
                                onDelete: () =>
                                    confirmDeleteTransaction(context, tx),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Day-of-week header row (Mo Tu We Th Fr Sa Su) ─────────────
  Widget _buildDayHeaders(BuildContext context) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.fontSize(context, 13),
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Calendar grid ──────────────────────────────────────────────
  Widget _buildCalendarGrid(BuildContext context, Set<int> daysWithTx) {
    final today = DateTime.now();
    // Total cells = leading blanks + days in month, rounded up to full weeks
    final leadingBlanks = _startWeekday - 1; // Mon=0 blanks, Tue=1, etc.
    final totalCells = leadingBlanks + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > _daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final cellDate = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNum,
              );
              final isSelected = _isSameDay(cellDate, _selectedDay);
              final isToday = _isSameDay(cellDate, today);
              final hasTx = daysWithTx.contains(dayNum);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = cellDate),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Selection / today highlight
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black
                                : isToday
                                ? Colors.black12
                                : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: GoogleFonts.inter(
                              fontSize: Responsive.fontSize(context, 15),
                              fontWeight: (isSelected || isToday)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),

                        // Red dot indicator
                        if (hasTx && !isSelected)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ── Nav arrow button ───────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_rounded, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No transactions on this day',
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction tile ───────────────────────────────────────────────
class _CalendarTxTile extends StatelessWidget {
  final dynamic tx;
  final dynamic cat;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CalendarTxTile({
    required this.tx,
    required this.cat,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(cat?.colorValue ?? 0xFFEEE5FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(
                  cat?.iconCodePoint ?? 0xe5d3,
                  fontFamily: 'MaterialIcons',
                ),
                color: Color(cat?.colorValue ?? 0xFF9E9E9E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat?.name ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.fontSize(context, 15),
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('h:mm a').format(tx.date),
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: Responsive.fontSize(context, 12),
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isExpense ? '-' : '+'} ₹${tx.amount.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: Responsive.fontSize(context, 15),
                fontWeight: FontWeight.bold,
                color: isExpense ? AppColors.expense : AppColors.income,
              ),
            ),

            // 3-dot menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              padding: EdgeInsets.zero,
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
