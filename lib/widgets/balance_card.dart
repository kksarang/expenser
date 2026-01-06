import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F3152), // Lighter dark
            AppColors.darkCard, // Darker
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2644  7545  3867  1965',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              // Mastercard logo simulation
              Row(
                children: [
                   CircleAvatar(
                     radius: 10,
                     backgroundColor: Colors.red.withOpacity(0.8),
                   ),
                   Transform.translate(
                     offset: const Offset(-8, 0),
                     child: CircleAvatar(
                       radius: 10,
                       backgroundColor: Colors.orange.withOpacity(0.8),
                     ),
                   )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
