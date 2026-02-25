import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

enum AnalyticsType { week, month, year, custom }

class AnalyticsService {
  double getTotalIncome(List<TransactionEntity> list) {
    return list
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(List<TransactionEntity> list) {
    return list
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance(List<TransactionEntity> list) {
    return getTotalIncome(list) - getTotalExpense(list);
  }

  double getSavingsRate(List<TransactionEntity> list) {
    double income = getTotalIncome(list);
    if (income == 0) return 0.0;
    double balance = getBalance(list);
    return (balance / income) * 100;
  }

  Map<String, double> getCategoryWiseExpense(List<TransactionEntity> list) {
    final expenses = list.where((t) => t.type == TransactionType.expense);
    final map = <String, double>{};
    for (var expense in expenses) {
      map[expense.categoryId] = (map[expense.categoryId] ?? 0) + expense.amount;
    }
    return map;
  }

  List<TransactionEntity> filterTransactions(
    List<TransactionEntity> list,
    AnalyticsType type,
    DateTime selectedDate, {
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    switch (type) {
      case AnalyticsType.week:
        // Start of week (Monday)
        final startOfWeek = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return _filterByDateRange(list, startOfWeek, endOfWeek);

      case AnalyticsType.month:
        final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
        final endOfMonth = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );
        return _filterByDateRange(list, startOfMonth, endOfMonth);

      case AnalyticsType.year:
        final startOfYear = DateTime(selectedDate.year, 1, 1);
        final endOfYear = DateTime(selectedDate.year, 12, 31, 23, 59, 59);
        return _filterByDateRange(list, startOfYear, endOfYear);

      case AnalyticsType.custom:
        if (customStartDate != null && customEndDate != null) {
          final end = DateTime(
            customEndDate.year,
            customEndDate.month,
            customEndDate.day,
            23,
            59,
            59,
          );
          return _filterByDateRange(list, customStartDate, end);
        }
        return list;
    }
  }

  List<TransactionEntity> _filterByDateRange(
    List<TransactionEntity> list,
    DateTime start,
    DateTime end,
  ) {
    return list.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  Map<DateTime, double> getDailyExpenses(List<TransactionEntity> list) {
    final expenses = list.where((t) => t.type == TransactionType.expense);
    final map = <DateTime, double>{};
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      map[date] = (map[date] ?? 0) + expense.amount;
    }
    return map;
  }

  Map<int, double> getMonthlyExpenses(List<TransactionEntity> list) {
    final map = <int, double>{};
    for (var expense in list.where((t) => t.type == TransactionType.expense)) {
      map[expense.date.month] = (map[expense.date.month] ?? 0) + expense.amount;
    }
    return map;
  }
}
