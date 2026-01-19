import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/models/order_model.dart';
import 'package:food2/screens/order/order_tracking_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderStatusCard(),

            _buildRestaurantInfo(),

            _buildDeliveryAddress(),

            _buildOrderItems(),

            _buildPaymentSummary(),

            _buildActionButtons(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            size: 40,
            color: statusColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppStyles.headlineSmall.copyWith(
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(order.status),
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (order.estimatedDeliveryTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated delivery: ${order.formattedEstimatedDelivery}',
                        style: AppStyles.bodyMedium.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(order.restaurantImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName,
                  style: AppStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${order.id}',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed on ${order.formattedDate} at ${order.formattedTime}',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.phone,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Delivery Address',
                style: AppStyles.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.deliveryAddress.title,
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.deliveryAddress.fullAddress,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items.length})',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return _buildOrderItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundColor,
            image: item.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: item.imageUrl == null
              ? const Icon(
                  Icons.fastfood,
                  size: 30,
                  color: AppColors.textDisabled,
                )
              : null,
        ),
        
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                'Quantity: ${item.quantity}',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              if (item.customizations.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: item.customizations.map((customization) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${customization.optionName}: ${customization.choiceName}',
                        style: AppStyles.labelSmall.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        Text(
          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildPaymentRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),

          _buildPaymentRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),

          _buildPaymentRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
          
          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppStyles.headlineSmall,
              ),
              Text(
                order.formattedTotalAmount,
                style: AppStyles.headlineSmall.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(order.paymentInfo.method),
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid with ${_getPaymentMethodText(order.paymentInfo.method)}',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.paymentInfo.status == PaymentStatus.completed
                            ? 'Payment completed'
                            : 'Payment pending',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: order.paymentInfo.status == PaymentStatus.completed
                      ? AppColors.successColor
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (order.status.index <= OrderStatus.onTheWay.index)
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(order: order),
                  ),
                );
              },
              text: 'Track Order',
              backgroundColor: AppColors.primaryColor,
              height: 56,
            ),
          
          const SizedBox(height: 12),
          
          if (order.status == OrderStatus.delivered)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reorder functionality
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Reorder',
                      style: AppStyles.titleLarge.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Rate Order'),
                  ),
                ),
              ],
            ),
          
          if (order.status == OrderStatus.cancelled)
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Order Again'),
            ),
          
          const SizedBox(height: 12),
          
          TextButton(
            onPressed: () {
            },
            child: Text(
              'Need help with this order?',
              style: AppStyles.labelLarge.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return AppColors.warningColor;
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        return AppColors.infoColor;
      case OrderStatus.delivered:
        return AppColors.successColor;
      case OrderStatus.cancelled:
        return AppColors.errorColor;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing Your Order';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.shopping_bag_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.done_all;
      case OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case OrderStatus.onTheWay:
        return Icons.directions_bike;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been received and is being processed';
      case OrderStatus.confirmed:
        return 'Restaurant has accepted your order';
      case OrderStatus.preparing:
        return 'Chef is preparing your delicious meal';
      case OrderStatus.ready:
        return 'Your order is ready for pickup';
      case OrderStatus.pickedUp:
        return 'Delivery partner has picked up your order';
      case OrderStatus.onTheWay:
        return 'Your food is on its way to you';
      case OrderStatus.delivered:
        return 'Your order has been delivered successfully';
      case OrderStatus.cancelled:
        return 'This order has been cancelled';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.paypal:
        return Icons.payment;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.android;
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit Card';
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }
}