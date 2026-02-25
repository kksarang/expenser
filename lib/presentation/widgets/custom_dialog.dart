import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  const CustomDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    required this.primaryButtonText,
    this.secondaryButtonText = 'Cancel',
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveWidth = Responsive.width(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveWidth * 0.05,
      ), // Responsive inset
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(responsiveWidth * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary).withOpacity(
                          0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? AppColors.primary,
                        size: Responsive.fontSize(context, 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 20),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (content != null) ...[
                    const SizedBox(height: 16),
                    content!,
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                              onSecondaryPressed ??
                              () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            secondaryButtonText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.fontSize(context, 16),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPrimaryPressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isDestructive
                                ? Colors.red
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            primaryButtonText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(context, 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
