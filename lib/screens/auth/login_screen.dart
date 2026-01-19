import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/core/widgets/custom_text_field.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/screens/auth/signup_screen.dart';
import 'package:food2/screens/auth/login_selection_screen.dart';
import 'package:food2/screens/home/home_screen.dart';
import 'package:food2/screens/admin/admin_home_screen.dart';
import 'package:food2/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'test@gmail.com';
    _passwordController.text = '12345678';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome back! 🎉',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );

        final user = authProvider.user;
        if (user?.role == AuthRole.admin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signInWithGoogle();
      
      if (success && mounted) {
        final user = authProvider.user;
        if (user?.role == AuthRole.admin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: AppStyles.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: TextEditingController(),
              label: 'Email Address',
              hint: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppStyles.bodyMedium,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password reset link sent! 📧',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor,
                    const Color(0xFFFF8B5C),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 50,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Welcome Back!',
                              style: AppStyles.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your food journey',
                              style: AppStyles.bodyLarge.copyWith(
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'Enter your email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _rememberMe
                                                  ? AppColors.primaryColor
                                                  : AppColors.textDisabled,
                                              width: 1.5,
                                            ),
                                            color: _rememberMe
                                                ? AppColors.primaryColor
                                                : Colors.transparent,
                                          ),
                                          child: _rememberMe
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Remember me',
                                          style: AppStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: _handleForgotPassword,
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppStyles.labelLarge.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              CustomButton(
                                onPressed: _handleLogin,
                                text: 'Sign In',
                                isLoading: authProvider.isLoading,
                                height: 56,
                              ),

                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                                  );
                                },
                                child: Text(
                                  'Login as Restaurant Admin',
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),

                              if (authProvider.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.errorColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.error!,
                                          style: AppStyles.bodyMedium.copyWith(
                                            color: AppColors.errorColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.dividerColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'or continue with',
                                      style: AppStyles.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.dividerColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _handleGoogleSignIn,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(
                                          color: AppColors.borderColor,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.g_translate,
                                        color: AppColors.textPrimary,
                                      ),
                                      label: Text(
                                        'Google',
                                        style: AppStyles.titleMedium,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // Apple Sign In - Implement later
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Apple Sign In coming soon!'),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(
                                          color: AppColors.borderColor,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.apple,
                                        color: AppColors.textPrimary,
                                      ),
                                      label: Text(
                                        'Apple',
                                        style: AppStyles.titleMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppStyles.bodyMedium,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Create Account',
                                      style: AppStyles.labelLarge.copyWith(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}