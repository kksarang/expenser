import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'expenses_screen.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpensesScreen(),
    const Center(child: Text('Add')),      // Placeholder for FAB
    const AnalyticsScreen(),
    const Center(child: Text('Profile')),  // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: _currentIndex == 0 ? AppColors.primary : AppColors.lightGrey),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              IconButton(
                icon: Icon(Icons.account_balance_wallet, color: _currentIndex == 1 ? AppColors.primary : AppColors.lightGrey),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Icon(Icons.pie_chart, color: _currentIndex == 3 ? AppColors.primary : AppColors.lightGrey),
                onPressed: () => setState(() => _currentIndex = 3),
              ),
              IconButton(
                icon: Icon(Icons.person, color: _currentIndex == 4 ? AppColors.primary : AppColors.lightGrey),
                onPressed: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
