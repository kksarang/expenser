import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

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
                    const SizedBox(width: 40), // Placeholder for balance
                    const Text(
                      'Expenses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                        ]
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 20),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Calendar Strip (Simplified Visual)
                const _CalendarStrip(),

                const SizedBox(height: 30),

                // Total Cards
                Consumer<ExpenseProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Salary',
                            amount: provider.totalIncome,
                            color: AppColors.primary,
                            icon: Icons.account_balance_wallet,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Expense',
                            amount: provider.totalExpense,
                            color: AppColors.expense,
                            icon: Icons.list_alt,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Expenses Header
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expenses', // Typo in design "Expences", fixing it here
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

                // Budget Item (Hardcoded for demo based on design)
                const _BudgetItem(
                  category: 'Food And Drinks',
                  spend: 2486,
                  budget: 3000,
                  color: AppColors.primary, // Purple bar on design? No, purple bar. Green text.
                  icon: Icons.shopping_cart,
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
            const Text('April 2022', style: TextStyle(fontWeight: FontWeight.w500)), // Static for design match
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DateItem('M', '20'),
            _DateItem('T', '21'),
            _DateItem('W', '22'),
            _DateItem('T', '23'),
            _DateItem('F', '24', isSelected: true),
            _DateItem('S', '25'),
            _DateItem('S', '26'),
          ],
        ),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  const _DateItem(this.day, this.date, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(color: AppColors.lightGrey, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.expense : Colors.transparent, // Orange selected
            shape: BoxShape.circle,
          ),
          child: Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isSelected) 
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CircleAvatar(radius: 2, backgroundColor: AppColors.expense),
          )
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
             '\$${amount.toStringAsFixed(2)}',
             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final String category;
  final double spend;
  final double budget;
  final Color color;
  final IconData icon;

  const _BudgetItem({
    required this.category,
    required this.spend,
    required this.budget,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (spend / budget).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('April 2022', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Spend', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                  Text('\$$spend', style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Budget', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                  Text('\$$budget', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
           const SizedBox(height: 12),
           ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: LinearProgressIndicator(
               value: percent,
               backgroundColor: AppColors.background,
               color: AppColors.primary,
               minHeight: 12,
             ),
           ),
           const SizedBox(height: 8),
           Align(
             alignment: Alignment.centerRight,
             child: Text('${(percent * 100).toStringAsFixed(2)}%', style: const TextStyle(color: AppColors.lightGrey, fontSize: 12)),
           ),
        ],
      ),
    );
  }
}
