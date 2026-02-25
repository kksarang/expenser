import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart'; // For TransactionType
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fabController;
  late final Animation<double> _fabOffsetAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fabOffsetAnimation = Tween<double>(begin: 4.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: AnimatedBuilder(
        animation: _fabOffsetAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _fabOffsetAnimation.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: FloatingActionButton(
          onPressed: _showAddOptionsData,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
              _buildNavItem(
                Icons.calendar_month_rounded,
                Icons.calendar_month_outlined,
                'Calendar',
                1,
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                Icons.pie_chart_rounded,
                Icons.pie_chart_outline_rounded,
                'Analytics',
                2,
              ),
              _buildNavItem(
                Icons.person_rounded,
                Icons.person_outline_rounded,
                'Profile',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionsData() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAddOption(
                    context,
                    title: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    type: TransactionType.income,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAddOption(
                    context,
                    title: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    type: TransactionType.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required TransactionType type,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close sheet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(initialType: type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ), // Increased from 20 to 30
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Increased from 12 to 16
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
