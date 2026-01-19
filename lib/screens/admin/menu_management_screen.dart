import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/screens/admin/add_menu_item_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final restaurantId = auth.user?.managedRestaurantId;

    if (restaurantId == null) {
      return Center(child: Text('No restaurant linked to this account.', style: AppStyles.bodyLarge));
    }

    final menuRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: menuRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No menu items yet. Use + to add.', style: AppStyles.bodyLarge));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return ListTile(
                leading: (data['image_url'] != null && (data['image_url'] as String).isNotEmpty)
                    ? Image.network(data['image_url'], width: 56, height: 56, fit: BoxFit.cover)
                    : Container(width: 56, height: 56, color: AppColors.backgroundColor, child: const Icon(Icons.fastfood)),
                title: Text(data['item_name'] ?? 'Untitled'),
                subtitle: Text('\$${(data['price'] ?? 0).toString()} • ${data['category'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddMenuItemScreen(menuItemId: docs[index].id)));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete menu item'),
                            content: const Text('Are you sure you want to delete this item?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await docs[index].reference.delete();
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMenuItemScreen())),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
