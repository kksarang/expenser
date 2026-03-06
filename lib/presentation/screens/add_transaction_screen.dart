import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import 'category_management_screen.dart';
import '../widgets/add_category_sheet.dart';

import '../../core/utils/responsive.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? initialTransaction;
  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.initialTransaction,
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

  String _selectedAccount = 'Cash'; // unified account selection
  bool _isLoading = false;
  final _payeeController = TextEditingController();
  final _referenceController = TextEditingController();

  // All account options (offline + UPI)
  final List<String> _accountOptions = [
    'Cash',
    'Card',
    'Bank',
    'GPay',
    'PhonePe',
    'Paytm',
    'CRED',
  ];

  // Icon for each account option
  IconData _accountIcon(String account) {
    switch (account) {
      case 'Cash':
        return Icons.payments_rounded;
      case 'Card':
        return Icons.credit_card_rounded;
      case 'Bank':
        return Icons.account_balance_rounded;
      case 'GPay':
        return Icons.g_mobiledata_rounded;
      case 'PhonePe':
        return Icons.phone_android_rounded;
      case 'Paytm':
        return Icons.account_balance_wallet_rounded;
      case 'CRED':
        return Icons.diamond_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  // Derive PaymentType from account string
  PaymentType _derivePaymentType(String account) {
    switch (account) {
      case 'Cash':
        return PaymentType.cash;
      case 'Card':
        return PaymentType.card;
      case 'Bank':
        return PaymentType.bankTransfer;
      default:
        return PaymentType.upiWallet; // GPay, PhonePe, Paytm, CRED
    }
  }

  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTransaction?.type ?? widget.initialType;
    if (widget.initialTransaction != null) {
      final tx = widget.initialTransaction!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;
      // Map existing account back to chips; fall back to 'Cash'
      _selectedAccount = _accountOptions.contains(tx.account)
          ? tx.account
          : 'Cash';
      _payeeController.text = tx.payee ?? '';
      _referenceController.text = tx.reference ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromExisting && widget.initialTransaction != null) {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      _selectedCategory = categoryProvider.getCategoryById(
        widget.initialTransaction!.categoryId,
      );
      _initializedFromExisting = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _payeeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _CategoryPickerSheet(
        selectedType: _selectedType,
        selectedCategory: _selectedCategory,
        onCategorySelected: (cat) {
          setState(() => _selectedCategory = cat);
          Navigator.pop(sheetCtx);
        },
        onManage: () {
          Navigator.pop(sheetCtx);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
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

                        // ── Account (replaces Payment Method + old Account dropdown) ──
                        _buildSectionHeader('Payment Method'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _accountOptions.map((option) {
                            final isSelected = _selectedAccount == option;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAccount = option),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.12)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _accountIcon(option),
                                      size: 16,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(
                                          context,
                                          13,
                                        ),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Optional Details Expansion
                        // ExpansionTile(
                        //   title: Text(
                        //     "More Details (Optional)",
                        //     style: TextStyle(
                        //       fontSize: Responsive.fontSize(context, 14),
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.grey,
                        //     ),
                        //   ),
                        //   tilePadding: EdgeInsets.zero,
                        //   children: [
                        //     TextField(
                        //       controller: _payeeController,
                        //       decoration: InputDecoration(
                        //         labelText:
                        //             _selectedType == TransactionType.expense
                        //             ? 'Payee / Merchant'
                        //             : 'Payer / Source',
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(height: 12),
                        //     TextField(
                        //       controller: _referenceController,
                        //       decoration: InputDecoration(
                        //         labelText: 'Reference No.',
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 16),

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
                            onPressed: _isLoading ? null : _saveTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.6),
                              disabledForegroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(
                                        context,
                                        18,
                                      ),
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
    final isEditing = widget.initialTransaction != null;
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

    final transaction = TransactionEntity(
      id: isEditing ? widget.initialTransaction!.id : const Uuid().v4(),
      amount: amount,
      categoryId: _selectedCategory!.id,
      date: _selectedDate,
      note: _noteController.text,
      type: _selectedType,
      paymentType: _derivePaymentType(_selectedAccount),
      account: _selectedAccount,
      payee: _payeeController.text.isEmpty ? null : _payeeController.text,
      reference: _referenceController.text.isEmpty
          ? null
          : _referenceController.text,
    );

    setState(() => _isLoading = true);

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      if (isEditing) {
        await transactionProvider.updateTransaction(transaction);
      } else {
        await transactionProvider.addTransaction(transaction);
      }

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  final TransactionType selectedType;
  final CategoryEntity? selectedCategory;
  final Function(CategoryEntity) onCategorySelected;
  final VoidCallback onManage;

  const _CategoryPickerSheet({
    required this.selectedType,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.onManage,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header with Gradient
          Container(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE5D1FF),
                  Color(0xFFF0E5FF),
                  Color(0xFFF9F9F9),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                // Handle pull
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                    Text(
                      'Select Category',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onManage,
                      child: Text(
                        'Manage',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search for Categories',
                      hintStyle: GoogleFonts.inter(color: Colors.black26),
                      icon: const Icon(Icons.search, color: Colors.black26),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid View
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                final filteredCategories = provider.categories
                    .where(
                      (c) =>
                          c.type == widget.selectedType &&
                          c.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredCategories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add Button
                      return _buildCategoryItem(
                        icon: Icons.add,
                        label: 'Add',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pop(context); // Close picker
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddCategorySheet(),
                          );
                        },
                        isPlaceholder: true,
                      );
                    }

                    final category = filteredCategories[index - 1];
                    final isSelected =
                        widget.selectedCategory?.id == category.id;

                    return _buildCategoryItem(
                      icon: IconData(
                        category.iconCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      label: category.name,
                      color: Color(category.colorValue),
                      onTap: () => widget.onCategorySelected(category),
                      isSelected: isSelected,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isPlaceholder = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isPlaceholder ? AppColors.primary : color,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.black54,
          ),
        ),
      ],
    );
  }
}
