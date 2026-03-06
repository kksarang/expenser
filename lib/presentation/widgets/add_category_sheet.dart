import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/category_entity.dart';
import '../../presentation/providers/category_provider.dart';
import '../../core/constants/app_colors.dart';
import 'icon_picker.dart';

class AddCategorySheet extends StatefulWidget {
  final CategoryEntity? initialCategory;

  const AddCategorySheet({super.key, this.initialCategory});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  late TextEditingController _nameController;
  late TransactionType _selectedType;
  late int _selectedIconCode;
  late Color _selectedColor;
  bool _isLoading = false;

  final List<Color> _colors = [
    const Color(0xFFFD3C4A), // Red
    const Color(0xFF00A86B), // Green
    const Color(0xFF0077FF), // Blue
    const Color(0xFFFFBF00), // Yellow/Amber
    const Color(0xFF7F3DFF), // Purple
    const Color(0xFFFCAC12), // Orange
    const Color(0xFF00BFA6), // Teal
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Deep Purple
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.initialCategory != null;
    _nameController = TextEditingController(
      text: isEditing ? widget.initialCategory!.name : '',
    );
    _selectedType = isEditing
        ? widget.initialCategory!.type
        : TransactionType.expense;
    _selectedIconCode = isEditing
        ? widget.initialCategory!.iconCodePoint
        : 0xe57a; // Default icon
    _selectedColor = isEditing
        ? Color(widget.initialCategory!.colorValue)
        : (_selectedType == TransactionType.expense
              ? const Color(0xFFFD3C4A)
              : const Color(0xFF00A86B));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final category = CategoryEntity(
        id: widget.initialCategory?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        iconCodePoint: _selectedIconCode,
        colorValue: _selectedColor.value,
        type: _selectedType,
        isCustom: true,
      );

      if (widget.initialCategory != null) {
        await provider.updateCategory(category);
      } else {
        await provider.addCategory(category);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialCategory != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEditing ? 'Edit Category' : 'Create Category',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a category for your income or expenses',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Segmented Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTypeButton('Expense', TransactionType.expense),
                  _buildTypeButton('Income', TransactionType.income),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Category Name',
                prefixIcon: const Icon(Icons.edit_outlined, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Preview Section
            Text(
              'Preview',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(_selectedIconCode, fontFamily: 'MaterialIcons'),
                      color: _selectedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Category Name'
                        : _nameController.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _nameController.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'Select Color',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _colors.map((color) => _buildColorChip(color)).toList(),
            ),
            const SizedBox(height: 24),

            // Icon Selection
            Text(
              'Select Icon',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            IconPicker(
              selectedIconCode: _selectedIconCode,
              selectedColor: _selectedColor,
              onIconSelected: (code) =>
                  setState(() => _selectedIconCode = code),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Create Category',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = type;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip(Color color) {
    final isSelected = _selectedColor.value == color.value;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
