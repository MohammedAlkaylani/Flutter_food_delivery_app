import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _biometricAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Settings'),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Order updates, promotions, reminders',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),
            _buildSettingItem(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark theme',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),

            _buildSectionHeader('App Settings'),
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Allow location access for better recommendations',
              trailing: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),
            _buildSettingItem(
              icon: Icons.fingerprint_outlined,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID for login',
              trailing: Switch(
                value: _biometricAuth,
                onChanged: (value) {
                  setState(() {
                    _biometricAuth = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),
            _buildSettingItem(
              icon: Icons.storage_outlined,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                  ),
                );
              },
            ),

            _buildSectionHeader('Support'),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQ, tutorials, and guides',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.chat_outlined,
              title: 'Contact Us',
              subtitle: 'Get in touch with our support team',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Share your feedback with us',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.share_outlined,
              title: 'Share App',
              subtitle: 'Tell your friends about QuickBite',
              onTap: () {},
            ),

            _buildSectionHeader('Legal'),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Learn how we handle your data',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.gavel_outlined,
              title: 'Legal Information',
              subtitle: 'Copyright and legal notices',
              onTap: () {},
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                'QuickBite v1.0.0',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: AppStyles.titleLarge.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: trailing ?? const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}