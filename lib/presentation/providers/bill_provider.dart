import 'package:flutter/foundation.dart';
import '../../domain/entities/bill_entity.dart';

class BillProvider with ChangeNotifier {
  List<BillEntity> _bills = [];

  List<BillEntity> get bills => _bills;

  Future<void> loadBills() async {
    // In the future this will load from local storage or Firebase
    // For now we just initialize an empty list
    _bills = [];
    notifyListeners();
  }

  Future<void> addBill(BillEntity bill) async {
    _bills.insert(0, bill); // Add to top
    // Save to storage
    notifyListeners();
  }

  Future<void> updateBill(BillEntity updatedBill) async {
    final index = _bills.indexWhere((b) => b.id == updatedBill.id);
    if (index >= 0) {
      _bills[index] = updatedBill;
      // Save to storage
      notifyListeners();
    }
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    // Save to storage
    notifyListeners();
  }

  // Monthly Insights logic
  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    return _bills
        .where((b) => b.date.year == now.year && b.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.totalAmount);
  }
}
