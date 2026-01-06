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
      "title": "Track Expenses",
      "text": "Manage daily expenses and income easily.",
      "image": "assets/images/onboarding1.png" // Placeholder or Icon
    },
    {
      "title": "Analyze Spending",
      "text": "View category-wise and date-wise insights.",
      "image": "assets/images/onboarding2.png"
    },
    {
      "title": "Stay Organized",
      "text": "Keep all finances in one place.",
      "image": "assets/images/onboarding3.png"
    },
  ];

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
                  icon: index == 0 ? Icons.attach_money : index == 1 ? Icons.pie_chart : Icons.check_circle_outline,
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
                    _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [


          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 200, height: 200,
              child: Lottie.network(
                _getLottieUrl(title),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                   return Icon(icon, size: 100, color: AppColors.primary);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.grey)),
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

  String _getLottieUrl(String title) {
    if (title.contains("Track")) return 'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json'; // Money/Wallet
    if (title.contains("Analyze")) return 'https://assets2.lottiefiles.com/packages/lf20_q5pk6p1k.json'; // Chart
    if (title.contains("Organize")) return 'https://assets5.lottiefiles.com/packages/lf20_V9t630.json'; // Calendar/Todo
    return 'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json';
  }
}
