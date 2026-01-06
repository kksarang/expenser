import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/models/transaction_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

enum Timeframe { week, month, year }

class TransactionProvider with ChangeNotifier {
  List<TransactionEntity> _transactions = [];
  final FirestoreService _firestoreService = FirestoreService();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  List<TransactionEntity> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense;

  StreamSubscription? _transactionSubscription;

  TransactionProvider() {
    loadTransactions();
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      final auth = _auth;
      if (auth != null) {
        auth.authStateChanges().listen((user) {
          _transactionSubscription?.cancel(); // Cancel previous stream
          if (user != null) {
            // Switch to Firestore
            _transactionSubscription = _firestoreService
                .getTransactionsStream(user.uid)
                .listen(
                  (transactions) {
                    _transactions = transactions;
                    notifyListeners();
                  },
                  onError: (e) {
                    print(
                      "Transaction Stream Error (Expected during logout): $e",
                    );
                  },
                );
          } else {
            // Fallback to local
            loadTransactions();
          }
        });
      } else {
        loadTransactions();
      }
    } catch (e) {
      print("Auth listener init failed: $e");
      loadTransactions();
    }
  }

  Future<void> loadTransactions() async {
    try {
      if (_auth?.currentUser != null) return; // Managed by stream
    } catch (e) {
      // Ignore
    }

    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> decodedList = json.decode(transactionsJson);
      _transactions = List<TransactionEntity>.from(
        decodedList.map((item) => TransactionModel.fromMap(item)),
      );
      notifyListeners();
    }
  }

  User? get _safeUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    final user = _safeUser;
    if (user != null) {
      try {
        await _firestoreService.saveTransaction(user.uid, transaction);
        // Stream will update local list automatically if successful
      } catch (e) {
        print("Firestore save failed: $e");
        rethrow;
      }
    } else {
      _transactions.add(transaction);
      await _saveLocalTransactions();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final user = _safeUser;
    if (user != null) {
      await _firestoreService.deleteTransaction(user.uid, id);
    } else {
      _transactions.removeWhere((t) => t.id == id);
      await _saveLocalTransactions();
      notifyListeners();
    }
  }

  Future<void> _saveLocalTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList = _transactions.map((t) {
      final model = TransactionModel(
        id: t.id,
        amount: t.amount,
        categoryId: t.categoryId,
        date: t.date,
        note: t.note,
        type: t.type,
        paymentType: t.paymentType,
        account: t.account,
        payee: t.payee,
        reference: t.reference,
      );
      return model.toMap();
    }).toList();

    await prefs.setString('transactions', json.encode(mapList));
  }

  List<TransactionEntity> getTransactionsByDate(DateTime date) {
    return _transactions.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  List<Map<String, double>> getSummary(Timeframe timeframe) {
    List<Map<String, double>> summary = [];
    DateTime now = DateTime.now();

    if (timeframe == Timeframe.week) {
      // Last 7 Days (Daily breakdown)
      for (int i = 6; i >= 0; i--) {
        DateTime day = now.subtract(Duration(days: i));
        summary.add(_calculateDaySum(day));
      }
    } else if (timeframe == Timeframe.month) {
      // Days of Current Month
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        DateTime day = DateTime(now.year, now.month, i);
        // Optimization: Only add valid days if we want to skip future days?
        // Or show entire month. Let's show entire month structure.
        summary.add(_calculateDaySum(day));
      }
    } else if (timeframe == Timeframe.year) {
      // Months of Current Year
      for (int i = 1; i <= 12; i++) {
        double income = 0;
        double expense = 0;
        for (var t in _transactions) {
          if (t.date.year == now.year && t.date.month == i) {
            if (t.type == TransactionType.income)
              income += t.amount;
            else
              expense += t.amount;
          }
        }
        summary.add({'income': income, 'expense': expense});
      }
    }

    return summary;
  }

  Map<String, double> _calculateDaySum(DateTime day) {
    double income = 0;
    double expense = 0;
    for (var t in _transactions) {
      if (t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day) {
        if (t.type == TransactionType.income)
          income += t.amount;
        else
          expense += t.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }

  // Legacy support if needed, but we can replace usage
  List<Map<String, double>> getWeeklySummary() => getSummary(Timeframe.week);

  Future<void> clearData() async {
    await _transactionSubscription?.cancel();
    _transactionSubscription = null;
    _transactions = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
