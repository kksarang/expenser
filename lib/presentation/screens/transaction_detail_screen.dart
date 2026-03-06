import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/transaction_actions.dart';
import '../widgets/custom_dialog.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final category = categoryProvider.getCategoryById(transaction.categoryId);

    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+ ₹' : '- ₹';

    // Gradient colors for the hero card
    final gradientColors = isIncome
        ? [const Color(0xFF00BFA6), const Color(0xFF008C7A)]
        : [const Color(0xFFFD3C4A), const Color(0xFFC92833)];

    final categoryColor = Color(category?.colorValue ?? 0xFF7F3DFF);
    final categoryIcon = IconData(
      category?.iconCodePoint ?? 0xe59c,
      fontFamily: 'MaterialIcons',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: Column(
        children: [
          // Hero top section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 18),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              navigateToEdit(context, transaction);
                            } else if (val == 'delete') {
                              _confirmDelete(context);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Transaction Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      children: [
                        // Category Icon Circle
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              categoryIcon,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category Name
                        Text(
                          category?.name ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Amount – Big and Bold
                        Text(
                          '$amountPrefix${transaction.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.fontSize(context, 42),
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Date
                        Text(
                          DateFormat(
                            'dd MMM yyyy • hh:mm a',
                          ).format(transaction.date),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: Responsive.fontSize(context, 13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          iconBgColor: amountColor.withValues(alpha: 0.1),
                          iconColor: amountColor,
                          label: 'Transaction Type',
                          value: isIncome ? 'Income' : 'Expense',
                          valueColor: amountColor,
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: categoryIcon,
                          iconBgColor: categoryColor.withValues(alpha: 0.1),
                          iconColor: categoryColor,
                          label: 'Category',
                          value: category?.name ?? 'Unknown',
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                          iconColor: AppColors.primary,
                          label: 'Date',
                          value: DateFormat(
                            'EEE, dd MMM yyyy',
                          ).format(transaction.date),
                        ),
                        _Divider(),
                        _DetailRow(
                          icon: _getPaymentIcon(transaction.paymentType),
                          iconBgColor: const Color(0xFFFCAC12).withValues(alpha: 0.1),
                          iconColor: const Color(0xFFFCAC12),
                          label: 'Payment Method',
                          value: _getPaymentLabel(transaction.paymentType),
                        ),
                        _Divider(),
                        Consumer<WalletProvider>(
                          builder: (context, walletProvider, _) {
                            final walletId = transaction.walletId;
                            String walletLabel = 'Personal: ${transaction.account}';
                            
                            if (walletId != null) {
                              final foundWallet = walletProvider.wallets.where((w) => w.id == walletId).toList();
                              if (foundWallet.isNotEmpty) {
                                walletLabel = 'Group: ${foundWallet.first.name}';
                              } else {
                                walletLabel = 'Group Wallet';
                              }
                            }

                            return _DetailRow(
                              icon: Icons.account_balance_wallet_rounded,
                              iconBgColor: Colors.teal.withValues(alpha: 0.1),
                              iconColor: Colors.teal,
                              label: 'Wallet',
                              value: walletLabel,
                            );
                          },
                        ),
                        if (transaction.payee != null &&
                            transaction.payee!.isNotEmpty) ...[
                          _Divider(),
                          _DetailRow(
                            icon: isIncome
                                ? Icons.person_rounded
                                : Icons.store_rounded,
                            iconBgColor: Colors.indigo.withValues(alpha: 0.1),
                            iconColor: Colors.indigo,
                            label: isIncome
                                ? 'Payer / Source'
                                : 'Payee / Merchant',
                            value: transaction.payee!,
                          ),
                        ],
                        if (transaction.reference != null &&
                            transaction.reference!.isNotEmpty) ...[
                          _Divider(),
                          _DetailRow(
                            icon: Icons.receipt_long_rounded,
                            iconBgColor: Colors.brown.withValues(alpha: 0.1),
                            iconColor: Colors.brown,
                            label: 'Reference No.',
                            value: transaction.reference!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Notes Section
                  if (transaction.note != null &&
                      transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notes_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              transaction.note!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed bottom buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Edit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          initialType: transaction.type,
                          initialTransaction: transaction,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Delete Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.expense,
                    side: const BorderSide(
                      color: AppColors.expense,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        title: 'Delete Transaction?',
        description:
            'Are you sure you want to delete this transaction? This action cannot be undone.',
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.red,
        isDestructive: true,
        primaryButtonText: 'Delete',
        onPrimaryPressed: () async {
          Navigator.pop(dialogContext); // Close dialog
          final provider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          final deleted = transaction;
          await provider.deleteTransaction(transaction.id);

          if (context.mounted) {
            HapticService.triggerMedium(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transaction deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).addTransaction(deleted);
                  },
                ),
              ),
            );

            Navigator.pop(context); // Go back to home screen
          }
        },
      ),
    );
  }

  IconData _getPaymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.payments_rounded;
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentType.upiWallet:
        return Icons.phone_android_rounded;
    }
  }

  String _getPaymentLabel(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.card:
        return 'Card';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
      case PaymentType.upiWallet:
        return 'UPI / Wallet';
    }
  }
}

// ---- Helper Widgets ----

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0,
      indent: 56,
      endIndent: 16,
      color: Color(0xFFF1F1FA),
    );
  }
}
