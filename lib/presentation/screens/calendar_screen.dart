import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../utils/transaction_actions.dart';
import '../../core/utils/responsive.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final dailyTransactions = transactionProvider.getTransactionsByDate(
      _selectedDay ?? DateTime.now(),
    );

    final responsiveWidth = Responsive.width(context);
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 18),
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Clean White Calendar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                ),
              ),

              // Styling
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontSize: Responsive.fontSize(context, 13),
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontSize: Responsive.fontSize(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),

              calendarStyle: CalendarStyle(
                defaultTextStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: Responsive.fontSize(context, 16),
                ),
                weekendTextStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: Responsive.fontSize(context, 16),
                ),
                outsideTextStyle: GoogleFonts.inter(
                  color: AppColors.lightGrey,
                  fontSize: Responsive.fontSize(context, 16),
                ),

                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary, // Purple
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),

                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),

              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          const Divider(thickness: 1, color: AppColors.lightGrey),

          // Transactions List
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'd MMMM',
                        ).format(_selectedDay ?? DateTime.now()),
                        style: GoogleFonts.inter(
                          color: AppColors.grey,
                          fontSize: Responsive.fontSize(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: dailyTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No activities for this day',
                                  style: GoogleFonts.inter(
                                    color: AppColors.grey,
                                    fontSize: Responsive.fontSize(context, 14),
                                  ),
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
                            padding: EdgeInsets.zero,
                            itemCount: dailyTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = dailyTransactions[index];
                              final category = categoryProvider.getCategoryById(
                                transaction.categoryId,
                              );

                              // Using ListTile to match HomeScreen style exactly
                              return ListTile(
                                contentPadding: const EdgeInsets.only(
                                  bottom: 16,
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
                                    size: isSmall ? 20 : 24,
                                  ),
                                ),
                                title: Text(
                                  category?.name ?? 'Unknown',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.fontSize(context, 16),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(transaction.date),
                                      style: GoogleFonts.inter(
                                        color: AppColors.grey,
                                        fontSize: Responsive.fontSize(
                                          context,
                                          13,
                                        ),
                                      ),
                                    ),
                                    if (transaction.note != null &&
                                        transaction.note!.isNotEmpty)
                                      Text(
                                        transaction.note!,
                                        style: GoogleFonts.inter(
                                          color: AppColors.grey,
                                          fontSize: Responsive.fontSize(
                                            context,
                                            12,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${transaction.type == TransactionType.expense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(0)}',
                                      style: GoogleFonts.inter(
                                        color:
                                            transaction.type ==
                                                TransactionType.expense
                                            ? AppColors.expense
                                            : AppColors.income,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.fontSize(context, 16),
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
                                          navigateToEdit(context, transaction);
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
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
