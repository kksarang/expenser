import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildFloatingNavBar(isDark),
    );
  }

  Widget _buildFloatingNavBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[900]!.withOpacity(0.85)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0, isDark),
                _buildNavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendar', 1, isDark),
                // Center FAB
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showAddOptionsData();
                  },
                  child: AnimatedBuilder(
                    animation: _fabOffsetAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _fabOffsetAnimation.value * 0.5),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, Color(0xFF7B4FFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                _buildNavItem(Icons.pie_chart_rounded, Icons.pie_chart_outline_rounded, 'Analytics', 2, isDark),
                _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 3, isDark),
              ],
            ),
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
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 10 : 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : AppColors.grey),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : AppColors.grey),
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
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
