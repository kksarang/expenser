import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/bill_entity.dart';
import '../providers/bill_provider.dart';

class BillDetailsScreen extends StatefulWidget {
  final BillEntity bill;
  final bool isReadOnly;

  const BillDetailsScreen({
    super.key,
    required this.bill,
    this.isReadOnly = false,
  });

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  late TextEditingController _shopController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late List<BillItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _shopController = TextEditingController(text: widget.bill.shopName);
    _amountController = TextEditingController(text: widget.bill.totalAmount.toString());
    _categoryController = TextEditingController(text: widget.bill.category);
    _notesController = TextEditingController(text: widget.bill.notes ?? '');
    _selectedDate = widget.bill.date;
    _items = List.from(widget.bill.items);
  }

  @override
  void dispose() {
    _shopController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBill() async {
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    
    final finalBill = BillEntity(
      id: widget.bill.id,
      shopName: _shopController.text,
      date: _selectedDate,
      totalAmount: double.tryParse(_amountController.text) ?? 0.0,
      category: _categoryController.text,
      imagePath: widget.bill.imagePath,
      items: _items,
      notes: _notesController.text,
    );

    if (widget.isReadOnly) {
      await billProvider.updateBill(finalBill);
    } else {
      await billProvider.addBill(finalBill);
    }

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/');
      // Re-push wallet screen if needed or just pop back
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isReadOnly ? 'Bill Details' : 'Verify Bill Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (widget.isReadOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
              onPressed: () {
                Provider.of<BillProvider>(context, listen: false).deleteBill(widget.bill.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Image Preview
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: Image.file(File(widget.bill.imagePath)),
                    ),
                  );
                },
                child: Hero(
                  tag: widget.bill.id,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(File(widget.bill.imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.zoom_in_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Basic Info'),
            const SizedBox(height: 12),
            _buildTextField('Shop Name', _shopController, Icons.store_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Amount', _amountController, Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Category', _categoryController, Icons.category_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Items List'),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              const Text('No items detected', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F1FA))),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Text('qty: ${item.quantity}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 16),
                        Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            _buildSectionTitle('Notes'),
            const SizedBox(height: 12),
            _buildTextField('Add notes here...', _notesController, Icons.notes_rounded, maxLines: 3),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  widget.isReadOnly ? 'Save Changes' : 'Save to Wallet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      readOnly: false,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F1FA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F1FA))),
        filled: true,
        fillColor: const Color(0xFFFDFBFF),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF1F1FA)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFDFBFF),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
          ],
        ),
      ),
    );
  }
}
