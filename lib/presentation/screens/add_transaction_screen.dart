import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import 'category_management_screen.dart';

import '../../core/utils/responsive.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late TransactionType _selectedType;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  // New State variables
  PaymentType _selectedPaymentType = PaymentType.cash;
  final _accountController = TextEditingController(
    text: 'Cash',
  ); // Default account
  final _payeeController = TextEditingController();
  final _referenceController = TextEditingController();

  // Helper for Account Selection logic
  final List<String> _accountOptions = [
    'Cash',
    'Bank Account',
    'Credit Card',
    'Wallet',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _accountController.dispose();
    _payeeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet() {
    final responsiveHeight = Responsive.height(context);

    final isTablet = Responsive.isTablet(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories
              .where((c) => c.type == _selectedType)
              .toList();
          return Container(
            padding: const EdgeInsets.all(24),
            height: responsiveHeight * 0.7,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings_rounded,
                        size: Responsive.fontSize(context, 20),
                      ),
                      label: const Text('Manage'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: isTablet ? 30 : 20,
                              backgroundColor: Color(
                                category.colorValue,
                              ).withOpacity(0.2),
                              child: Icon(
                                IconData(
                                  category.iconCodePoint,
                                  fontFamily: 'MaterialIcons',
                                ),
                                color: Color(category.colorValue),
                                size: isTablet ? 32 : 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOption(String title, TransactionType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedCategory = null; // Reset category when type changes
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gradient Setup
    final isIncome = _selectedType == TransactionType.income;
    final gradientColors = isIncome
        ? [const Color(0xFF00BFA6), const Color(0xFF008C7A)] // Greenish
        : [const Color(0xFFFD3C4A), const Color(0xFFC92833)]; // Reddish

    final responsiveWidth = Responsive.width(context);
    final responsiveHeight = Responsive.height(context);
    final isSmall = Responsive.isSmall(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth * 0.04,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 18),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance centering
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Amount Input (Giant)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How much?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹ ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.fontSize(context, 64),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 100),
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.fontSize(context, 64),
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  filled: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SizedBox(height: responsiveHeight * 0.01),

            // SizedBox(height: responsiveHeight * 0.01),
            SizedBox(height: responsiveHeight * 0.01),

            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(responsiveWidth * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Type Selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTypeOption(
                                  'Expense',
                                  TransactionType.expense,
                                ),
                              ),
                              Expanded(
                                child: _buildTypeOption(
                                  'Income',
                                  TransactionType.income,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Category Selector
                        GestureDetector(
                          onTap: _showCategoryBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightGrey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (_selectedCategory != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Icon(
                                          IconData(
                                            _selectedCategory!.iconCodePoint,
                                            fontFamily: 'MaterialIcons',
                                          ),
                                          color: Color(
                                            _selectedCategory!.colorValue,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      _selectedCategory?.name ??
                                          'Select Category',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(
                                          context,
                                          16,
                                        ),
                                        color: _selectedCategory == null
                                            ? AppColors.grey
                                            : Colors.black,
                                        fontWeight: _selectedCategory == null
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.lightGrey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.lightGrey,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Selector
                        _buildSectionHeader('Payment Method'),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: PaymentType.values.map((type) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_getPaymentTypeLabel(type)),
                                  selected: _selectedPaymentType == type,
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(
                                        () => _selectedPaymentType = type,
                                      );
                                  },
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  labelStyle: TextStyle(
                                    color: _selectedPaymentType == type
                                        ? AppColors.primary
                                        : Colors.black,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: _selectedPaymentType == type
                                          ? AppColors.primary
                                          : AppColors.lightGrey,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Account Selector
                        _buildSectionHeader('Account'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value:
                              _accountOptions.contains(_accountController.text)
                              ? _accountController.text
                              : null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text("Select Account"),
                          items: _accountOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _accountController.text = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Optional Details Expansion
                        ExpansionTile(
                          title: Text(
                            "More Details (Optional)",
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 14),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          tilePadding: EdgeInsets.zero,
                          children: [
                            TextField(
                              controller: _payeeController,
                              decoration: InputDecoration(
                                labelText:
                                    _selectedType == TransactionType.expense
                                    ? 'Payee / Merchant'
                                    : 'Payer / Source',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _referenceController,
                              decoration: InputDecoration(
                                labelText: 'Reference No.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date Picker
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => _selectedDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightGrey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_selectedDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.card:
        return 'Card';
      case PaymentType.bankTransfer:
        return 'Bank';
      case PaymentType.upiWallet:
        return 'UPI/Wallet';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select amount and category')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_accountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: _selectedCategory!.id,
      date: _selectedDate,
      note: _noteController.text,
      type: _selectedType,
      paymentType: _selectedPaymentType,
      account: _accountController.text,
      payee: _payeeController.text.isEmpty ? null : _payeeController.text,
      reference: _referenceController.text.isEmpty
          ? null
          : _referenceController.text,
    );

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      // Perform the save (don't await if offline to prevent blocking?
      // Actually, with persistence, await should be fine, but we give immediate feedback)
      // We await it to ensure no validation errors, but we trust persistence.
      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);

        if (isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🌐 Offline Mode: Your expense has been saved locally. It will automatically sync to your account once you are back online.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          // Optional: Show standard success message if needed, or rely on default behavior
          // User asked for specific offline message.
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
