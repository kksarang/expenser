import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category_entity.dart';

import '../../presentation/widgets/custom_dialog.dart';
import '../../presentation/widgets/icon_picker.dart';
import '../../core/utils/responsive.dart';

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
                  color: Color(category.colorValue).withOpacity(0.2),
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
                        _showAddEditDialog(context, category: category),
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
        onPressed: () => _showAddEditDialog(context),
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
        onPrimaryPressed: () {
          provider.deleteCategory(id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {CategoryEntity? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(
      text: isEditing ? category.name : '',
    );
    TransactionType selectedType = isEditing
        ? category.type
        : TransactionType.expense;
    int selectedIconCode = isEditing ? category.iconCodePoint : 0xe57a;
    Color getColorForType(TransactionType type) {
      return type == TransactionType.expense
          ? const Color(0xFFFD3C4A)
          : const Color(0xFF00A86B);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentColor = getColorForType(selectedType);

            return CustomDialog(
              title: isEditing ? 'Edit Category' : 'New Category',
              icon: isEditing ? Icons.edit_rounded : Icons.category_rounded,
              primaryButtonText: isEditing ? 'Save' : 'Add',
              onPrimaryPressed: () {
                if (nameController.text.trim().isEmpty) return;

                final newCategory = CategoryEntity(
                  id: isEditing ? category.id : const Uuid().v4(),
                  name: nameController.text.trim(),
                  iconCodePoint: selectedIconCode,
                  colorValue: currentColor.value,
                  type: selectedType,
                  isCustom: true,
                );

                final provider = Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                );
                if (isEditing) {
                  provider.updateCategory(newCategory);
                } else {
                  provider.addCategory(newCategory);
                }
                Navigator.pop(context);
              },
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: currentColor),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TypeChip(
                          'Expense',
                          TransactionType.expense,
                          selectedType,
                          (val) => setState(() => selectedType = val),
                        ),
                        const SizedBox(width: 8),
                        _TypeChip(
                          'Income',
                          TransactionType.income,
                          selectedType,
                          (val) => setState(() => selectedType = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Icon",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconPicker(
                      selectedIconCode: selectedIconCode,
                      selectedColor: currentColor,
                      onIconSelected: (code) =>
                          setState(() => selectedIconCode = code),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final TransactionType value;
  final TransactionType groupValue;
  final ValueChanged<TransactionType> onChanged;

  const _TypeChip(this.label, this.value, this.groupValue, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
      ),
    );
  }
}
