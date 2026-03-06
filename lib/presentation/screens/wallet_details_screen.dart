import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';

class WalletDetailsScreen extends StatefulWidget {
  final WalletEntity wallet;

  const WalletDetailsScreen({super.key, required this.wallet});

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, String> _memberNames = {};
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberNames();
  }

  Future<void> _fetchMemberNames() async {
    setState(() => _isLoadingMembers = true);
    final names = await _firestoreService.getUserProfiles(widget.wallet.members);
    if (mounted) {
      setState(() {
        _memberNames = names;
        _isLoadingMembers = false;
      });
    }
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.wallet.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard!')),
    );
  }

  void _shareInvite() {
    Share.share(
      'Join my shared wallet "${widget.wallet.name}" on Expenser!\nUse this code to join: ${widget.wallet.inviteCode}',
      subject: 'Invite to Shared Wallet',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(
          widget.wallet.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<TransactionEntity>>(
        stream: _firestoreService.getTransactionsStream(widget.wallet.createdBy, walletId: widget.wallet.id),
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? [];
          final income = transactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, item) => sum + item.amount);
          final expense = transactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, item) => sum + item.amount);
          final totalBalance = income - expense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invite Code Card
                _buildInviteCard(),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      'Total Balance',
                      '₹${totalBalance.toStringAsFixed(0)}',
                      Icons.account_balance_wallet_rounded,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Transactions',
                      transactions.length.toString(),
                      Icons.receipt_long_rounded,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Members',
                  widget.wallet.members.length.toString(),
                  Icons.people_alt_rounded,
                  AppColors.income,
                  isFullWidth: true,
                ),
                const SizedBox(height: 32),

                // Members List
                _buildMembersList(),
                
                const SizedBox(height: 32),
                
                // Recent activity header
                if (transactions.isNotEmpty) ...[
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ...transactions.take(5).map((t) => _buildTransactionItem(t)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Invite Code',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            widget.wallet.inviteCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInviteActionButton(Icons.copy_rounded, 'Copy', _copyInviteCode),
              const SizedBox(width: 20),
              _buildInviteActionButton(Icons.share_rounded, 'Share', _shareInvite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    return isFullWidth ? content : Expanded(child: content);
  }

  Widget _buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wallet Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoadingMembers
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.wallet.members.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100, indent: 64),
                  itemBuilder: (context, index) {
                    final uid = widget.wallet.members[index];
                    final name = _memberNames[uid] ?? 'Unknown User';
                    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
                    final isCreator = uid == widget.wallet.createdBy;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          firstLetter,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: isCreator
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Owner',
                                style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionEntity transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isExpense ? AppColors.expense : AppColors.income,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (transaction.note == null || transaction.note!.isEmpty) ? 'Transaction' : transaction.note!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}₹${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}
