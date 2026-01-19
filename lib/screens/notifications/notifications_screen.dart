import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('30% OFF - First Order'),
              subtitle: Text('Use code WELCOME30 to get 30% off your first order.'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('Order Update'),
              subtitle: Text('Your order ORD-12346 is on the way.'),
            ),
          ],
        ),
      ),
    );
  }
}
