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

  // Initial "Seed" Categories (Only used on very first run / missing category sync)
  final List<CategoryModel> _seedCategories = [
    // ── Income Categories ──────────────────────────────────────
    CategoryModel(
      id: 'inc_01',
      name: 'Salary',
      colorValue: 0xFF00A86B,
      iconCodePoint: 0xe943, // Icons.work
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_02',
      name: 'Business',
      colorValue: 0xFF2196F3,
      iconCodePoint: 0xe8d1, // Icons.store
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_03',
      name: 'Freelance',
      colorValue: 0xFF009688,
      iconCodePoint: 0xe30a, // Icons.computer
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_04',
      name: 'Investment',
      colorValue: 0xFF4CAF50,
      iconCodePoint: 0xe6de, // Icons.trending_up
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_05',
      name: 'Bonus',
      colorValue: 0xFFFCAC12,
      iconCodePoint: 0xe838, // Icons.star
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_06',
      name: 'Rental',
      colorValue: 0xFF795548,
      iconCodePoint: 0xe88a, // Icons.home
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_07',
      name: 'Interest',
      colorValue: 0xFF607D8B,
      iconCodePoint: 0xe84f, // Icons.account_balance
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_08',
      name: 'Gift',
      colorValue: 0xFFE91E63,
      iconCodePoint: 0xe8f6, // Icons.card_giftcard
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_09',
      name: 'Refund',
      colorValue: 0xFF00BCD4,
      iconCodePoint: 0xe5d5, // Icons.refresh
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'inc_10',
      name: 'Other Income',
      colorValue: 0xFF9E9E9E,
      iconCodePoint: 0xe5d3, // Icons.more_horiz
      type: TransactionType.income,
    ),

    // ── Expense Categories ──────────────────────────────────────
    CategoryModel(
      id: 'exp_01',
      name: 'Food',
      colorValue: 0xFFFD3C4A,
      iconCodePoint: 0xe56c, // Icons.restaurant
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_02',
      name: 'Groceries',
      colorValue: 0xFF8BC34A,
      iconCodePoint: 0xe556, // Icons.local_grocery_store
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_03',
      name: 'Shopping',
      colorValue: 0xFFFCAC12,
      iconCodePoint: 0xe8cc, // Icons.shopping_cart
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_04',
      name: 'Personal Care',
      colorValue: 0xFFE91E63,
      iconCodePoint: 0xe87c, // Icons.face
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_05',
      name: 'Clothing',
      colorValue: 0xFF9C27B0,
      iconCodePoint: 0xe8d8, // Icons.style
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_06',
      name: 'Rent',
      colorValue: 0xFF795548,
      iconCodePoint: 0xe88a, // Icons.home
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_07',
      name: 'Utilities',
      colorValue: 0xFFFF9800,
      iconCodePoint: 0xea14, // Icons.bolt
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_08',
      name: 'Maintenance',
      colorValue: 0xFF607D8B,
      iconCodePoint: 0xe869, // Icons.build
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_09',
      name: 'Fuel',
      colorValue: 0xFF455A64,
      iconCodePoint: 0xe546, // Icons.local_gas_station
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_10',
      name: 'Transport',
      colorValue: 0xFF7F3DFF,
      iconCodePoint: 0xe531, // Icons.directions_car
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_11',
      name: 'Travel',
      colorValue: 0xFF03A9F4,
      iconCodePoint: 0xe195, // Icons.flight
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_12',
      name: 'Taxi / Ride',
      colorValue: 0xFFFFC107,
      iconCodePoint: 0xe534, // Icons.local_taxi
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_13',
      name: 'Bills',
      colorValue: 0xFFFD3C4A,
      iconCodePoint: 0xef6e, // Icons.receipt_long
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_14',
      name: 'EMI / Loan',
      colorValue: 0xFFFF5722,
      iconCodePoint: 0xe84f, // Icons.account_balance
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_15',
      name: 'Insurance',
      colorValue: 0xFF009688,
      iconCodePoint: 0xe32a, // Icons.security
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_16',
      name: 'Entertainment',
      colorValue: 0xFF673AB7,
      iconCodePoint: 0xe54e, // Icons.movie
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_17',
      name: 'Subscriptions',
      colorValue: 0xFFE91E63,
      iconCodePoint: 0xe8f9, // Icons.subscriptions
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_18',
      name: 'Medical',
      colorValue: 0xFF4CAF50,
      iconCodePoint: 0xe548, // Icons.local_hospital
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_19',
      name: 'Pharmacy',
      colorValue: 0xFF2196F3,
      iconCodePoint: 0xe549, // Icons.local_pharmacy
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_20',
      name: 'Education',
      colorValue: 0xFF3F51B5,
      iconCodePoint: 0xe80c, // Icons.school
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'exp_21',
      name: 'Other',
      colorValue: 0xFF9E9E9E,
      iconCodePoint: 0xe5d3, // Icons.more_horiz
      type: TransactionType.expense,
    ),
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
              _categories = cloudCats;
              _syncMissingSeeds(); // Add any new default categories not yet present
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
        _syncMissingSeeds(); // Add any new default categories not yet present
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

  /// Adds any seed categories that are not yet present (by ID).
  /// Safe to call at any time — never overwrites or removes existing categories.
  void _syncMissingSeeds() {
    final existingIds = _categories.map((c) => c.id).toSet();
    for (final seed in _seedCategories) {
      if (!existingIds.contains(seed.id)) {
        addCategory(seed); // addCategory handles Firestore or local save
      }
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
