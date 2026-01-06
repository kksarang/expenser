import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/analytics_preview_chart.dart';
import '../widgets/transaction_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE5FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const Text(
                      'Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Balance Card
                Consumer<ExpenseProvider>(
                  builder: (context, provider, _) {
                    return BalanceCard(balance: provider.totalBalance);
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Analytics Chart
                const AnalyticsPreviewChart(),

                const SizedBox(height: 30),

                // Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(color: AppColors.lightGrey),
                      ),
                    ),
                  ],
                ),
                
                // Transactions List
                Consumer<ExpenseProvider>(
                  builder: (context, provider, _) {
                    final recent = provider.recentTransactions;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        return TransactionItem(transaction: recent[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 80), // Space for FAB/BottomNav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
