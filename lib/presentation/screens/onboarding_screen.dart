import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Track Your Money Easily",
      "text": "Record your daily income and expenses in seconds and always know where your money goes.",
      "lottieUrl": "https://lottie.host/5b736737-25e4-4d8b-9694-874e4776b7e0/6Jq6S8p0uQ.json", 
      "icon": "Icons.attach_money"
    },
    {
      "title": "Understand Your Spending",
      "text": "Visual reports help you understand your spending habits and manage your budget better.",
      "lottieUrl": "https://lottie.host/760ce81d-e6a8-444a-a9f4-3079963e6eac/nUuQY4S4vF.json",
      "icon": "Icons.pie_chart"
    },
    {
      "title": "Stay in Control",
      "text": "Monitor your financial activity and make smarter spending decisions every day.",
      "lottieUrl": "https://lottie.host/5a2d67a9-8588-436c-94cc-40853754d924/oD0NnF4WfQ.json",
      "icon": "Icons.security"
    },
    {
      "title": "Achieve Financial Clarity",
      "text": "Build better financial habits and stay organized with all your transactions in one place.",
      "lottieUrl": "https://lottie.host/6770ded4-0130-4e5c-bd87-b95764d7c046/S7u6W5U5V6.json",
      "icon": "Icons.check_circle_outline"
    },
  ];

  IconData _getFallbackIcon(int index) {
    switch (index) {
      case 0: return Icons.attach_money;
      case 1: return Icons.pie_chart_outline_rounded;
      case 2: return Icons.account_balance_wallet_rounded;
      case 3: return Icons.check_circle_outline_rounded;
      default: return Icons.star_border_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _buildPage(
                  title: _onboardingData[index]['title']!,
                  text: _onboardingData[index]['text']!,
                  lottieUrl: _onboardingData[index]['lottieUrl']!,
                  icon: _getFallbackIcon(index),
                ),
              ),
            ),
            
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentPage == _onboardingData.length - 1 
                      ? _completeOnboarding 
                      : () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 ? 'Start Your Journey' : 'Continue',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String text, required String lottieUrl, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05), // using withValues per recent updates
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 240, height: 240,
              child: Lottie.network(
                lottieUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                   return Icon(icon, size: 100, color: AppColors.primary);
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 600),
            child: Text(
              title, 
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w800, 
                color: Colors.black87,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 800),
            child: Text(
              text, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                fontSize: 16, 
                height: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}
