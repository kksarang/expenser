import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class CategoryEntity {
  final String id;
  final String name;
  final int colorValue; // Store color as int for easy serialization
  final int iconCodePoint; // Store icon as code point
  final bool isCustom;
  final TransactionType type;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.isCustom = false,
    required this.type,
  });
}
