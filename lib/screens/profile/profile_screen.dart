import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/screens/auth/login_screen.dart';
import 'package:food2/screens/profile/edit_profile_screen.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/screens/profile/payment_methods_screen.dart';
import 'package:food2/screens/profile/settings_screen.dart';
import 'package:food2/screens/order/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _completedOrders = 12;
  double _totalSpent = 856.75;

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(user),

            _buildStatsSection(),

            _buildMenuItems(),
            
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      user.profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
          ),
          
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest User',
                  style: AppStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@example.com',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                  ),
                  label: const Text('Edit Profile'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  _completedOrders.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Orders',
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '\$${_totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Spent',
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  '4.8',
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      _MenuItem(
        icon: Icons.location_on_outlined,
        title: 'Addresses',
        subtitle: 'Manage delivery addresses',
        onTap: () {
        },
      ),
      _MenuItem(
        icon: Icons.payment_outlined,
        title: 'Payment Methods',
        subtitle: 'Add or remove payment cards',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentMethodsScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        title: 'My Orders',
        subtitle: 'View order history',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        icon: Icons.favorite_outline,
        title: 'Favorites',
        subtitle: 'Your saved restaurants & items',
        onTap: () {
        },
      ),
      _MenuItem(
        icon: Icons.local_offer_outlined,
        title: 'Promotions',
        subtitle: 'Available discounts & offers',
        onTap: () {
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'FAQ, contact us, feedback',
        onTap: () {
        },
      ),
      _MenuItem(
        icon: Icons.logout_outlined,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        isLogout: true,
        onTap: _handleLogout,
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          return _buildMenuItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Column(
      children: [
        ListTile(
          onTap: item.onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isLogout
                  ? AppColors.errorColor.withOpacity(0.1)
                  : AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.isLogout
                  ? AppColors.errorColor
                  : AppColors.primaryColor,
            ),
          ),
          title: Text(
            item.title,
            style: AppStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: item.isLogout ? AppColors.errorColor : null,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: AppStyles.bodySmall.copyWith(
              color: item.isLogout
                  ? AppColors.errorColor.withOpacity(0.8)
                  : AppColors.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: item.isLogout
                ? AppColors.errorColor
                : AppColors.textSecondary,
          ),
        ),
        if (!item.isLogout)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLogout;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLogout = false,
  });
}