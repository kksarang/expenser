import 'package:flutter/material.dart';
import '../models/transaction.dart';


class ExpenseProvider with ChangeNotifier {
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Puma Store',
      amount: 952.00,
      date: DateTime.now().subtract(const Duration(days: 0)), // Today
      category: 'Shopping',
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't2',
      title: 'Nike Super Store',
      amount: 475.00,
      date: DateTime.now().subtract(const Duration(days: 0)), // Today
      category: 'Shopping',
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't3',
      title: 'Food And Drinks',
      amount: 2486.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Food',
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't4',
      title: 'Salary',
      amount: 7000.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: 'Salary',
      type: TransactionType.income,
    ),
     Transaction(
      id: 't5',
      title: 'Healthcare',
      amount: 219.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Health',
      type: TransactionType.expense,
    ),
  ];

  List<Transaction> get transactions {
    return [..._transactions];
  }

  List<Transaction> get recentTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void addTransaction(Transaction tx) {
    _transactions.add(tx);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
  
  Map<String, double> get categoryBreakdown {
    Map<String, double> data = {};
    for (var tx in _transactions) {
      if (tx.type == TransactionType.expense) {
        if (data.containsKey(tx.category)) {
          data[tx.category] = data[tx.category]! + tx.amount;
        } else {
          data[tx.category] = tx.amount;
        }
      }
    }
    return data;
  }
}
