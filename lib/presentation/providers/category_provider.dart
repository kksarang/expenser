import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/models/category_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class CategoryProvider with ChangeNotifier {
  List<CategoryEntity> _categories = [];
  StreamSubscription? _categorySubscription;

  // Initial "Seed" Categories (Only used on very first run)
  final List<CategoryModel> _seedCategories = [
    CategoryModel(
      id: '1',
      name: 'Food',
      colorValue: 0xFFFD3C4A,
      iconCodePoint: 0xe57a,
      type: TransactionType.expense,
    ), // Fastfood
    CategoryModel(
      id: '2',
      name: 'Shopping',
      colorValue: 0xFFFCAC12,
      iconCodePoint: 0xe59c,
      type: TransactionType.expense,
    ), // Shopping Bag
    CategoryModel(
      id: '3',
      name: 'Travel',
      colorValue: 0xFF7F3DFF,
      iconCodePoint: 0xe531,
      type: TransactionType.expense,
    ), // Car
    CategoryModel(
      id: '4',
      name: 'Salary',
      colorValue: 0xFF00A86B,
      iconCodePoint: 0xe941,
      type: TransactionType.income,
    ), // Work
    CategoryModel(
      id: '5',
      name: 'Bills',
      colorValue: 0xFFFD3C4A,
      iconCodePoint: 0xef6e,
      type: TransactionType.expense,
    ), // Receipt
  ];

  List<CategoryEntity> get categories => _categories;

  CategoryProvider() {
    loadCategories();
    _initAuthListener();
  }

  final FirestoreService _firestoreService = FirestoreService();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  void _initAuthListener() {
    try {
      final auth = _auth;
      if (auth != null) {
        auth.authStateChanges().listen((user) {
          _categorySubscription?.cancel();
          if (user != null) {
            // Reload triggers stream logic in loadCategories, but we need to manage subscription there too.
            // Actually, loadCategories handles the logic. Let's make sure loadCategories manages the subscription.
            loadCategories();
          } else {
            loadCategories();
          }
        });
      }
    } catch (e) {
      loadCategories();
    }
  }

  Future<void> loadCategories() async {
    _categorySubscription?.cancel();
    final user = _safeUser;

    if (user != null) {
      // Load from Firestore
      _categorySubscription = _firestoreService
          .getCategoriesStream(user.uid)
          .listen(
            (cloudCats) {
              _categories =
                  cloudCats; // Firestore is source of truth when logged in
              if (_categories.isEmpty) {
                // Seed Firestore if empty
                for (var cat in _seedCategories) {
                  addCategory(cat);
                }
              }
              notifyListeners();
            },
            onError: (e) {
              print("Category Stream Error (Expected during logout): $e");
            },
          );
    } else {
      // Local Handling
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString('all_categories');

      if (categoriesJson != null) {
        // Load existing
        final List<dynamic> decodedList = json.decode(categoriesJson);
        _categories = decodedList
            .map((item) => CategoryModel.fromMap(item))
            .toList()
            .cast<CategoryEntity>();
      } else {
        // First Run: Seed Data
        _categories = List<CategoryEntity>.from(_seedCategories);
        await _saveLocalCategories();
      }
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

  Future<void> addCategory(CategoryEntity category) async {
    final user = _safeUser;
    if (user != null) {
      try {
        await _firestoreService.saveCategory(user.uid, category);
      } catch (e) {
        rethrow;
      }
    } else {
      // Convert to Model ensuring runtime type compatibility if list was inferred as List<CategoryModel>
      final model = CategoryModel(
        id: category.id,
        name: category.name,
        colorValue: category.colorValue,
        iconCodePoint: category.iconCodePoint,
        type: category.type,
        isCustom: category.isCustom,
      );
      _categories.add(model);
      await _saveLocalCategories();
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    final user = _safeUser;
    if (user != null) {
      // Firestore uses save for update too (set with merge)
      await _firestoreService.saveCategory(user.uid, category);
    } else {
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        await _saveLocalCategories();
        notifyListeners();
      }
    }
  }

  Future<void> deleteCategory(String id) async {
    final user = _safeUser;
    if (user != null) {
      await _firestoreService.deleteCategory(user.uid, id);
    } else {
      _categories.removeWhere((c) => c.id == id);
      await _saveLocalCategories();
      notifyListeners();
    }
  }

  Future<void> _saveLocalCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList = _categories
        .map(
          (c) => CategoryModel(
            id: c.id,
            name: c.name,
            colorValue: c.colorValue,
            iconCodePoint: c.iconCodePoint,
            isCustom: c.isCustom,
            type: c.type,
          ).toMap(),
        )
        .toList();
    await prefs.setString('all_categories', json.encode(mapList));
  }

  CategoryEntity? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearData() async {
    await _categorySubscription?.cancel();
    _categorySubscription = null;
    _categories = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('all_categories');
    // Note: We don't re-seed here because this is for account deletion/logout.
    // Seed happens on fresh load if empty.
    notifyListeners();
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }
}
