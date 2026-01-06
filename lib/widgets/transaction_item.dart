import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = isExpense ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(transaction.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: _getCategoryColor(transaction.category),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(transaction.date), // "Fri, 05 April 2022"
                  style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix\$${transaction.amount.toStringAsFixed(0)}', // Removing decimal for cleaner look as per design samples sometimes, though design has decimals.
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Credit Card', // Mock source
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Colors.orange;
      case 'food':
        return Colors.red;
      case 'salary':
        return Colors.green;
      case 'health':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
     switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
        return Icons.restaurant;
      case 'salary':
        return Icons.money;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }
}
