import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/core/constants/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Restaurant Admin!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
