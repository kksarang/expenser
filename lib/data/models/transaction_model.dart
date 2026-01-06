import 'dart:convert';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.date,
    super.note,
    required super.type,
    required super.paymentType,
    required super.account,
    super.payee,
    super.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'type': type.index,
      'paymentType': paymentType.index,
      'account': account,
      'payee': payee,
      'reference': reference,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      type: TransactionType.values[map['type']],
      paymentType: map['paymentType'] != null 
          ? PaymentType.values[map['paymentType']] 
          : PaymentType.cash, // Default backward compatibility
      account: map['account'] ?? 'Cash', // Default
      payee: map['payee'],
      reference: map['reference'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));
}
