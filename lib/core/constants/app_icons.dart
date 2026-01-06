import 'package:flutter/material.dart';

class AppIcons {
  static const List<Map<String, dynamic>> icons = [
    {'icon': Icons.fastfood_rounded, 'name': 'Food'},       // Burger
    {'icon': Icons.shopping_bag_rounded, 'name': 'Shopping'}, // Bag
    {'icon': Icons.directions_car_rounded, 'name': 'Travel'}, // Car
    {'icon': Icons.home_rounded, 'name': 'Rent'},           // Home
    {'icon': Icons.work_rounded, 'name': 'Salary'},         // Briefcase
    {'icon': Icons.receipt_long_rounded, 'name': 'Bills'},    // Receipt
    {'icon': Icons.movie_creation_rounded, 'name': 'Entertainment'}, // Movie
    {'icon': Icons.medical_services_rounded, 'name': 'Medical'}, // Cross
    {'icon': Icons.school_rounded, 'name': 'Education'},    // Hat
    {'icon': Icons.fitness_center_rounded, 'name': 'Health'}, // Dumbbell
    {'icon': Icons.pets_rounded, 'name': 'Pets'},           // Paw
    {'icon': Icons.card_giftcard_rounded, 'name': 'Gifts'},   // Gift
    {'icon': Icons.savings_rounded, 'name': 'Savings'},     // Piggy
    {'icon': Icons.trending_up_rounded, 'name': 'Invest'},  // Chart
    {'icon': Icons.more_horiz_rounded, 'name': 'Other'},    // More
  ];
  
  static IconData getIcon(int codePoint) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
