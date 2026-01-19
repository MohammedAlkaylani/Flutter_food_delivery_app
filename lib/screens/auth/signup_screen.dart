import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/core/widgets/custom_text_field.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/screens/auth/login_screen.dart';
import 'package:food2/screens/home/home_screen.dart';
import 'package:food2/screens/admin/admin_home_screen.dart';

class SignupScreen extends StatefulWidget {
  final AuthRole? initialRole;
  const SignupScreen({super.key, this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  AuthRole _selectedRole = AuthRole.user;
  final _restaurantNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? AuthRole.user;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _restaurantNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to Terms & Conditions',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _phoneController.text.trim(),
        role: _selectedRole,
        restaurantName: _selectedRole == AuthRole.admin ? _restaurantNameController.text.trim() : null,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! 🎉',
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

  Future<void> _handleGoogleSignUp() async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signInWithGoogle();
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
    }
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
                    AppColors.secondaryColor,
                    const Color(0xFF7EE0DA),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                              Icons.person_add_alt_1,
                              size: 50,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Create Account',
                            style: AppStyles.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join QuickBite food community',
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
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              prefixIcon: const Icon(Icons.person_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (value.length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

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
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Create a strong password',
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
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                ChoiceChip(
                                  label: Text('User'),
                                  selected: _selectedRole == AuthRole.user,
                                  onSelected: (_) => setState(() => _selectedRole = AuthRole.user),
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: Text('Restaurant Admin'),
                                  selected: _selectedRole == AuthRole.admin,
                                  onSelected: (_) => setState(() => _selectedRole = AuthRole.admin),
                                ),
                              ],
                            ),

                            if (_selectedRole == AuthRole.admin) ...[
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _restaurantNameController,
                                label: 'Restaurant Name',
                                hint: 'Your restaurant name',
                                prefixIcon: const Icon(Icons.restaurant),
                                validator: (value) {
                                  if (_selectedRole == AuthRole.admin) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your restaurant name';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _agreeToTerms
                                            ? AppColors.secondaryColor
                                            : AppColors.textDisabled,
                                        width: 1.5,
                                      ),
                                      color: _agreeToTerms
                                          ? AppColors.secondaryColor
                                          : Colors.transparent,
                                    ),
                                    child: _agreeToTerms
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I agree to the ',
                                      style: AppStyles.bodyMedium,
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: AppStyles.bodyMedium.copyWith(
                                            color: AppColors.secondaryColor,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          // You can add onTap here if needed
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: AppStyles.bodyMedium.copyWith(
                                            color: AppColors.secondaryColor,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            CustomButton(
                              onPressed: _handleSignup,
                              text: 'Create Account',
                              isLoading: authProvider.isLoading,
                              height: 56,
                              backgroundColor: AppColors.secondaryColor,
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
                                    'or sign up with',
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
                                    onPressed: _handleGoogleSignUp,
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Apple Sign Up coming soon!'),
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
                                  'Already have an account? ',
                                  style: AppStyles.bodyMedium,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: AppStyles.labelLarge.copyWith(
                                      color: AppColors.secondaryColor,
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

                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Benefits of joining:',
                            style: AppStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBenefit('🎯', 'Personalized recommendations'),
                          _buildBenefit('⚡', 'Fast checkout & saved addresses'),
                          _buildBenefit('🎁', 'Exclusive offers & discounts'),
                          _buildBenefit('📦', 'Track orders in real-time'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}