import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'category_management_screen.dart';
import '../../presentation/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/globals.dart'; // Import for global key
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import '../../core/services/local_storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Avatar & Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      color: Theme.of(context).cardColor,
                      image: user?.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(user!.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Conditional Content based on User State
                  if (user == null || userProvider.isGuest) ...[
                    // --- GUEST UI ---
                    Text(
                      'You are using Expenser as a Guest',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Login / Sign Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    // --- LOGGED IN USER UI ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userProvider.name.isEmpty
                              ? 'User Name'
                              : userProvider.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              _showEditProfileDialog(context, userProvider),
                        ),
                      ],
                    ),
                    Text(
                      userProvider.user?.email ??
                          (userProvider.bio.isEmpty
                              ? 'Bio goes here...'
                              : userProvider.bio),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            _ProfileMenuTile(
              icon: Icons.category_outlined,
              title: 'Categories',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen(),
                ),
              ),
            ),

            // Privacy Policy
            _ProfileMenuTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://kksarang.github.io/expenser-Privacy-Policy/',
                );
                try {
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch $url');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Privacy Policy'),
                      ),
                    );
                  }
                }
              },
            ),

            //    const SizedBox(height: 10),

            // Logout (Only for Authenticated Users)
            if (user != null && !userProvider.isGuest)
              _ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: false,
                onTap: () => _showLogoutConfirmation(context, userProvider),
              ),

            // Delete Account (Only for Authenticated Users)
            if (user != null && !userProvider.isGuest)
              _ProfileMenuTile(
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () =>
                    _showDeleteAccountConfirmation(context, userProvider),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider provider) {
    final nameController = TextEditingController(text: provider.name);
    final bioController = TextEditingController(text: provider.bio);

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Edit Profile',
        icon: Icons.edit_note_rounded,
        primaryButtonText: 'Save',
        onPrimaryPressed: () {
          provider.updateProfile(nameController.text, bioController.text);
          Navigator.pop(context);
        },
        content: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Logout',
        description: 'Are you sure you want to log out?',
        icon: Icons.logout_rounded,
        primaryButtonText: 'Logout',
        secondaryButtonText: 'Cancel',
        onPrimaryPressed: () async {
          // 1. Close Dialog
          Navigator.pop(context);

          // 2. Clear Data (Stop Streams)
          final transactionProvider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          final categoryProvider = Provider.of<CategoryProvider>(
            context,
            listen: false,
          );

          await transactionProvider.clearData();
          await categoryProvider.clearData();

          // 3. Perform Logout (AuhtWrapper will handle navigation)
          await provider.logout();

          // 4. Show Success SnackBar Globally (Raw)
          // Note: Showing this AFTER logout ensures we don't show it if logout hangs/fails
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteAccountConfirmation(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        title: 'Delete Account',
        description:
            'This action is permanent. All your data will be deleted. Are you sure?',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        isDestructive: true,
        primaryButtonText: 'Delete',
        secondaryButtonText: 'Cancel',
        onPrimaryPressed: () async {
          Navigator.of(context).pop(); // close confirmation dialog

          _showLoadingDialog(context);

          try {
            final userId = userProvider.user?.uid;

            /// 1️⃣ Delete Firestore Data
            if (userId != null && !userProvider.isGuest) {
              await FirestoreService().deleteUserData(userId);
            }

            /// 2️⃣ Clear Providers (Local State)
            if (context.mounted) {
              await Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).clearData();

              await Provider.of<CategoryProvider>(
                context,
                listen: false,
              ).clearData();
            }

            /// 3️⃣ Clear Local Storage (IMPORTANT)
            await LocalStorageService.clearAll();

            /// 4️⃣ Delete Auth Account
            await userProvider.deleteAccount();

            if (!context.mounted) return;

            /// 5️⃣ Close Loading Dialog
            Navigator.of(context).pop();

            /// 6️⃣ Navigate to Login (Hard Reset)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );

            /// 7️⃣ Success SnackBar
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!context.mounted) return;

            Navigator.of(context).pop(); // close loader

            if (e.toString().contains('REAUTH_REQUIRED')) {
              _showReAuthDialog(context);
            } else {
              if (scaffoldMessengerKey.currentState != null) {
                scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete account. Try again later'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  void _showReAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Security Check Required'),
        content: const Text('Please login again to confirm account deletion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  // final Widget? trailing; // Removed unused parameter

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    // this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.lightGrey.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDestructive
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white54 : AppColors.grey,
        ),
      ),
    );
  }
}
