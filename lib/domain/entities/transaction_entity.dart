import 'category_entity.dart';

enum PaymentType { cash, card, bankTransfer, upiWallet }

class TransactionEntity {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final TransactionType type;
  
  // New Payment Details
  final PaymentType paymentType;
  final String account; // e.g., "Cash", "HDFC", "Credit Card"
  final String? payee; // Merchant or Source
  final String? reference; // Transaction ID

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    required this.type,
    required this.paymentType,
    required this.account,
    this.payee,
    this.reference,
  });
}
