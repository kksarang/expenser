import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/models/transaction_model.dart';
import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

class FirestoreService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Collection References
  CollectionReference _usersCollection() {
    return _firestore.collection('users');
  }

  CollectionReference _transactionsCollection(String userId) {
    return _usersCollection().doc(userId).collection('transactions');
  }

  // --- Transactions ---

  Future<void> saveTransaction(
    String userId,
    TransactionEntity transaction,
  ) async {
    final model = TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      date: transaction.date,
      note: transaction.note,
      type: transaction.type,
      paymentType: transaction.paymentType,
      account: transaction.account,
      payee: transaction.payee,
      reference: transaction.reference,
    );

    await _transactionsCollection(
      userId,
    ).doc(transaction.id).set(model.toMap());
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _transactionsCollection(userId).doc(transactionId).delete();
  }

  Stream<List<TransactionEntity>> getTransactionsStream(String userId) {
    return _transactionsCollection(
      userId,
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // --- Categories ---

  CollectionReference _categoriesCollection(String userId) {
    return _usersCollection().doc(userId).collection('categories');
  }

  Future<void> saveCategory(String userId, CategoryEntity category) async {
    // Assuming CategoryModel is what we want to save
    // We need to cast or convert entity to model.
    // Ideally Entity shouldn't be cast, but for simplicity here:
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      iconCodePoint: category.iconCodePoint,
      type: category.type,
    );

    await _categoriesCollection(userId).doc(category.id).set(model.toMap());
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesCollection(userId).doc(categoryId).delete();
  }

  Stream<List<CategoryEntity>> getCategoriesStream(String userId) {
    return _categoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            return CategoryModel.fromMap(doc.data() as Map<String, dynamic>);
          })
          .toList()
          .cast<CategoryEntity>();
    });
  }

  Future<void> deleteUserData(String userId) async {
    // 1. Delete all transactions
    final transactions = await _transactionsCollection(userId).get();
    for (var doc in transactions.docs) {
      await doc.reference.delete();
    }

    // 2. Delete all categories
    final categories = await _categoriesCollection(userId).get();
    for (var doc in categories.docs) {
      await doc.reference.delete();
    }

    // 3. Delete user document
    await _usersCollection().doc(userId).delete();
  }
}
