import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';
import 'create_wallet_screen.dart';
import 'join_wallet_screen.dart';
import 'wallet_details_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  void _showAddWalletOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEEE5FF),
                    child: Icon(Icons.add_business_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Create New Shared Wallet'),
                  subtitle: const Text('Start a new wallet to share with family or friends.'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateWalletScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEFE9),
                    child: Icon(Icons.group_add_rounded, color: Color(0xFFFF643B)),
                  ),
                  title: const Text('Join Shared Wallet'),
                  subtitle: const Text('Enter an invite code to join an existing wallet.'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinWalletScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          'My Wallets',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                
                // Personal Wallet Card
                _WalletCard(
                  name: 'My Personal Wallet',
                  membersCount: 1,
                  isSelected: provider.selectedWallet == null,
                  onTap: () {
                    provider.selectWallet(null);
                    Navigator.pop(context);
                  },
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shared Wallets',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddWalletOptions(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                if (provider.wallets.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            "No Shared Wallets", 
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create or join a wallet to start\nsharing financial tracking.", 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500)
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = provider.wallets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WalletCard(
                          name: wallet.name,
                          membersCount: wallet.members.length,
                          inviteCode: wallet.inviteCode,
                          isSelected: provider.selectedWallet?.id == wallet.id,
                          onTap: () {
                            provider.selectWallet(wallet);
                            Navigator.pop(context);
                          },
                          onInfoTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WalletDetailsScreen(wallet: wallet),
                              ),
                            );
                          },
                          icon: Icons.supervised_user_circle_rounded,
                          iconColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String name;
  final int membersCount;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;
  final IconData icon;
  final Color iconColor;
  final String? inviteCode;

  const _WalletCard({
    required this.name,
    required this.membersCount,
    required this.isSelected,
    required this.onTap,
    this.onInfoTap,
    required this.icon,
    required this.iconColor,
    this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '$membersCount ${membersCount == 1 ? 'Member' : 'Members'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (inviteCode != null && inviteCode!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.tag_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            inviteCode!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 28),
            if (onInfoTap != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onInfoTap,
                icon: Icon(Icons.info_outline_rounded, color: Colors.grey.shade600, size: 22),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
