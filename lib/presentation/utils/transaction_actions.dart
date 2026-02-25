import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_dialog.dart';
import '../screens/add_transaction_screen.dart';
import '../../domain/entities/transaction_entity.dart';

void navigateToEdit(BuildContext context, TransactionEntity transaction) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddTransactionScreen(
        initialType: transaction.type,
        initialTransaction: transaction,
      ),
    ),
  );
}

void confirmDeleteTransaction(
  BuildContext context,
  TransactionEntity transaction,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => CustomDialog(
      title: 'Delete Transaction?',
      description: 'This action cannot be undone.',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red,
      isDestructive: true,
      primaryButtonText: 'Delete',
      onPrimaryPressed: () {
        Navigator.pop(dialogContext);
        final provider = Provider.of<TransactionProvider>(
          context,
          listen: false,
        );
        provider.deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                Provider.of<TransactionProvider>(
                  context,
                  listen: false,
                ).addTransaction(transaction);
              },
            ),
          ),
        );
      },
    ),
  );
}
