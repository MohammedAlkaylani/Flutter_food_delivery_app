import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/screens/admin/edit_restaurant_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: AppStyles.headlineSmall),
          const SizedBox(height: 12),
          ListTile(
            title: Text(auth.user?.name ?? ''),
            subtitle: Text(auth.user?.email ?? ''),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditRestaurantScreen()));
            },
            child: const Text('Edit Restaurant'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
