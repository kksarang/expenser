import 'package:uuid/uuid.dart';

class BillItemEntity {
  final String id;
  final String itemName;
  final int quantity;
  final double price;
  final double total;

  BillItemEntity({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory BillItemEntity.fromMap(Map<String, dynamic> map) {
    return BillItemEntity(
      id: map['id'] ?? const Uuid().v4(),
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: map['price']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
    );
  }
}

class BillEntity {
  final String id;
  final String shopName;
  final DateTime date;
  final double totalAmount;
  final String category;
  final String imagePath;
  final List<BillItemEntity> items;
  final String? notes;

  BillEntity({
    required this.id,
    required this.shopName,
    required this.date,
    required this.totalAmount,
    required this.category,
    required this.imagePath,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'category': category,
      'imagePath': imagePath,
      'items': items.map((x) => x.toMap()).toList(),
      'notes': notes,
    };
  }

  factory BillEntity.fromMap(Map<String, dynamic> map) {
    return BillEntity(
      id: map['id'] ?? const Uuid().v4(),
      shopName: map['shopName'] ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      imagePath: map['imagePath'] ?? '',
      items: map['items'] != null
          ? List<BillItemEntity>.from(
              map['items']?.map((x) => BillItemEntity.fromMap(x)))
          : [],
      notes: map['notes'],
    );
  }
}
