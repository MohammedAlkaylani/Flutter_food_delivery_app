import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food2/screens/order/order_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/data/providers/cart_provider.dart';
import 'package:food2/data/providers/location_provider.dart';
import 'package:food2/screens/auth/login_screen.dart';
import 'package:food2/screens/auth/signup_screen.dart';
import 'package:food2/screens/home/home_screen.dart';
import 'package:food2/screens/onboarding/onboarding_screen.dart';
import 'package:food2/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'QuickBite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _initializationComplete = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize location provider
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocation();

      // Check if user is new (first time opening app)
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;

      // Simulate some initialization delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _initializationComplete = true;
      });

      _navigateToNextScreen(isFirstTime);

    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        _errorMessage = 'Failed to initialize app';
        _initializationComplete = true;
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToNextScreen(bool isFirstTime) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      if (isFirstTime) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          // Background decoration
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.9),
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 70,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'QuickBite',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Food delivered to your doorstep',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (!_initializationComplete)
                      _buildLoadingIndicator()
                    else if (_errorMessage != null)
                      _buildErrorMessage()
                    else
                      _buildInitializedIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Preparing your food experience...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _navigateToLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Continue Anyway'),
        ),
      ],
    );
  }

  Widget _buildInitializedIndicator() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(height: 12),
        Text(
          'Ready!',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}