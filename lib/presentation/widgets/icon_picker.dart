import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/responsive.dart';

class IconPicker extends StatelessWidget {
  final int? selectedIconCode;
  final ValueChanged<int> onIconSelected;
  final Color selectedColor;

  const IconPicker({
    super.key,
    required this.selectedIconCode,
    required this.onIconSelected,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmall(context);
    final isTablet = Responsive.isTablet(context);

    // 4 columns for small screens, 5 for medium, 7 for tablets/desktop
    final crossAxisCount = isSmall ? 4 : (isTablet ? 7 : 5);

    return SizedBox(
      height: 200,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: AppIcons.icons.length,
        itemBuilder: (context, index) {
          final item = AppIcons.icons[index];
          final IconData iconData = item['icon'];
          final isSelected = selectedIconCode == iconData.codePoint;

          return GestureDetector(
            onTap: () => onIconSelected(iconData.codePoint),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: selectedColor, width: 2)
                    : Border.all(color: AppColors.lightGrey),
              ),
              child: Icon(
                iconData,
                color: isSelected ? selectedColor : AppColors.grey,
                size: Responsive.fontSize(context, 24),
              ),
            ),
          );
        },
      ),
    );
  }
}
