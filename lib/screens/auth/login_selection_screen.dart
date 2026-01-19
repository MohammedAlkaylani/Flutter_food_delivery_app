import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/screens/auth/login_screen.dart';
import 'package:food2/screens/auth/signup_screen.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/screens/auth/admin_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Login'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text('User Login', style: AppStyles.bodyLarge.copyWith(color: Colors.white)),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                );
              },
              child: Text('Restaurant Admin Login', style: AppStyles.bodyLarge),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                // Go to signup preselected as Admin
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen(initialRole: AuthRole.admin)),
                );
              },
              child: Text('Create Admin Account', style: AppStyles.bodyMedium.copyWith(color: AppColors.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
