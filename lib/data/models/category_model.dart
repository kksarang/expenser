import 'dart:convert';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.colorValue,
    required super.iconCodePoint,
    super.isCustom,
    required super.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'isCustom': isCustom,
      'type': type.index,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      colorValue: map['colorValue'],
      iconCodePoint: map['iconCodePoint'],
      isCustom: map['isCustom'],
      type: TransactionType.values[map['type']],
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) => CategoryModel.fromMap(json.decode(source));
}
