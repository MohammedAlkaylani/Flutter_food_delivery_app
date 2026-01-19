import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/data/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: AppStyles.headlineSmall.copyWith(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Dismissible(
                        key: ValueKey(item.menuItemId + item.customizationsDescription),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.errorColor,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => cart.removeItem(item.menuItemId, item.customizations),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                ? Image.network(item.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                                : const Icon(Icons.fastfood),
                            title: Text(item.name, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(item.customizationsDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.formattedPrice, style: AppStyles.titleMedium.copyWith(color: AppColors.primaryColor)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(onPressed: () => cart.updateQuantity(item.menuItemId, item.customizations, item.quantity - 1), icon: const Icon(Icons.remove)),
                                    Text(item.quantity.toString()),
                                    IconButton(onPressed: () => cart.updateQuantity(item.menuItemId, item.customizations, item.quantity + 1), icon: const Icon(Icons.add)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          Text('\$${cart.subtotal.toStringAsFixed(2)}', style: AppStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery', style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          Text('\$${cart.deliveryFee.toStringAsFixed(2)}', style: AppStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax', style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          Text('\$${cart.tax.toStringAsFixed(2)}', style: AppStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Simulate checkout
                            final total = cart.total;
                            cart.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed • Total: \$${total.toStringAsFixed(2)}')));
                            Navigator.pushReplacementNamed(context, '/orders');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
