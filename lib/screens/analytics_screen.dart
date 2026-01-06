import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Header
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                   const Text('Total Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                   const SizedBox(width: 48), // Balance
                 ],
               ),
               const SizedBox(height: 20),
               
               // Calendar (Simplified repeat)
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                    const Text('April 2022', style: TextStyle(fontWeight: FontWeight.w500)),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 10),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                     children: [
                       _SmallDateItem('20', false),
                       SizedBox(width: 15),
                       _SmallDateItem('21', false),
                       SizedBox(width: 15),
                       _SmallDateItem('22', false),
                       SizedBox(width: 15),
                       _SmallDateItem('23', false),
                       SizedBox(width: 15),
                       _SmallDateItem('24', true),
                       SizedBox(width: 15),
                       _SmallDateItem('25', false),
                       SizedBox(width: 15),
                       _SmallDateItem('26', false),
                     ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text('You have Spend \$6,584', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('this month.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                
                const SizedBox(height: 20),
                
                // Progress Bar
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('75.78%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('24.22%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text('Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 20),
                
                // Pie Chart
                SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                          sections: [
                             PieChartSectionData(
                               color: const Color(0xFF292B4D), // Dark Blue
                               value: 35,
                               title: '35%',
                               radius: 100,
                               titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                             ),
                             PieChartSectionData(
                               color: AppColors.expense, // Orange
                               value: 45,
                               title: '45%',
                               radius: 100,
                               titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                             ),
                             PieChartSectionData(
                               color: AppColors.primary, // Purple
                               value: 20,
                               title: '20%',
                               radius: 100,
                               titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                             ),
                          ],
                        ),
                      ),
                      // Labels positioned manually (simplification for layout)
                      // Ideally we use a legend, but design has them around.
                    ],
                  ),
                ),
                
                // Legend
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem('Shopping', AppColors.expense, '\$3,762'),
                    _LegendItem('Food', Color(0xFF292B4D), '\$4,672'),
                    _LegendItem('Healthcare', AppColors.primary, '\$2,917'),
                  ],
                ),
             ],
           ),
        ),
      ),
    );
  }
}

class _SmallDateItem extends StatelessWidget {
  final String date;
  final bool isSelected;
  const _SmallDateItem(this.date, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
             color: isSelected ? AppColors.expense : Colors.transparent,
             shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Text(date, style: TextStyle(color: isSelected ? Colors.white : AppColors.lightGrey, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final String amount;
  
  const _LegendItem(this.label, this.color, this.amount);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Text(label, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
         Text(amount, style: const TextStyle(color: AppColors.lightGrey, fontSize: 12)),
      ],
    );
  }
}
