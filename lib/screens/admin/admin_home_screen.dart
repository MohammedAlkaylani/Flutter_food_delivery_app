import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
// import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/screens/admin/menu_management_screen.dart';
import 'package:food2/screens/admin/admin_dashboard_screen.dart';
import 'package:food2/screens/admin/admin_orders_screen.dart';
import 'package:food2/screens/admin/admin_settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Admin'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Menu'),
            Tab(text: 'Orders'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          AdminDashboardScreen(),
          MenuManagementScreen(),
          AdminOrdersScreen(),
          AdminSettingsScreen(),
        ],
      ),
    );
  }
}
