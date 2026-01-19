import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
// import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/core/widgets/custom_text_field.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/screens/admin/admin_home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.loginWithEmailAndRole(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      AuthRole.admin,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'admin@restaurant.com',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              CustomButton(
                onPressed: _handleAdminLogin,
                text: 'Sign in as Admin',
                isLoading: authProvider.isLoading,
                height: 52,
              ),

              if (authProvider.error != null) ...[
                const SizedBox(height: 12),
                Text(authProvider.error!, style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
