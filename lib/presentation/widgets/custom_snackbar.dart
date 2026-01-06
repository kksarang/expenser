import 'package:flutter/material.dart';
import '../../core/utils/globals.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(
      ScaffoldMessenger.of(context),
      message,
      icon: Icons.check_circle_rounded,
      color: Colors.green.shade600,
      backgroundColor: Colors.green.shade50,
      textColor: Colors.green.shade900,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      ScaffoldMessenger.of(context),
      message,
      icon: Icons.error_rounded,
      color: Colors.red.shade600,
      backgroundColor: Colors.red.shade50,
      textColor: Colors.red.shade900,
    );
  }

  // --- Global Methods (Persist across navigation) ---

  static void showGlobalSuccess(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      _show(
        messenger,
        message,
        icon: Icons.check_circle_rounded,
        color: Colors.green.shade600,
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade900,
      );
    }
  }

  static void showGlobalError(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      _show(
        messenger,
        message,
        icon: Icons.error_rounded,
        color: Colors.red.shade600,
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    }
  }

  static void _show(
    ScaffoldMessengerState messenger,
    String message, {
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required Color textColor,
  }) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
