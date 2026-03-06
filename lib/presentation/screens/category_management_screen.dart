import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category_entity.dart';

import '../../presentation/widgets/custom_dialog.dart';
import '../../core/utils/responsive.dart';
import '../widgets/add_category_sheet.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final responsiveWidth = Responsive.width(context);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(responsiveWidth * 0.04),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(category.colorValue).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Color(category.colorValue),
                  size: Responsive.fontSize(context, 24),
                ),
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: Responsive.fontSize(context, 24),
                    ),
                    onPressed: () =>
                        _showAddEditSheet(context, category: category),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: AppColors.expense,
                      size: Responsive.fontSize(context, 24),
                    ),
                    onPressed: () =>
                        _confirmDelete(context, provider, category.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Delete Category?',
        description: 'This action cannot be undone.',
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.red,
        isDestructive: true,
        primaryButtonText: 'Delete',
        onPrimaryPressed: () async {
          await provider.deleteCategory(id);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddEditSheet(BuildContext context, {CategoryEntity? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(initialCategory: category),
    );
  }
}
