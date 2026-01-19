import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/core/widgets/loading_indicator.dart';
import 'package:food2/models/order_model.dart';
import 'package:food2/screens/order/order_detail_screen.dart';

import '../../models/user_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<String> _filterOptions = ['All', 'Active', 'Completed', 'Cancelled'];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    setState(() {
      _orders = [
        Order(
          id: 'ORD-12345',
          userId: 'user1',
          restaurantId: 'rest1',
          restaurantName: 'Burger Palace',
          restaurantImage: 'https://picsum.photos/400/300?restaurant=1',
          status: OrderStatus.delivered,
          totalAmount: 24.99,
          subtotal: 21.99,
          deliveryFee: 2.99,
          tax: 0.99,
          items: [
            OrderItem(
              menuItemId: 'item1',
              name: 'Classic Cheeseburger',
              imageUrl: 'https://picsum.photos/200/150?burger=1',
              price: 12.99,
              quantity: 1,
              customizations: [],
            ),
            OrderItem(
              menuItemId: 'item2',
              name: 'French Fries',
              imageUrl: 'https://picsum.photos/200/150?fries=1',
              price: 4.99,
              quantity: 1,
              customizations: [],
            ),
          ],
          deliveryAddress: Address(
            id: 'addr1',
            title: 'Home',
            addressLine1: '123 Main Street',
            addressLine2: 'Apt 4B',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            latitude: 40.7128,
            longitude: -74.0060,
            isDefault: true,
          ),
          paymentInfo: PaymentInfo(
            id: 'pay1',
            method: PaymentMethod.card,
            status: PaymentStatus.completed,
            amount: 24.99,
            paidAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          deliveryInfo: DeliveryInfo(
            id: 'del1',
            driverId: 'driver1',
            driverName: 'John Smith',
            driverPhone: '+1234567890',
            status: DeliveryStatus.delivered,
            actualDeliveryTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          estimatedDeliveryTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        ),
        Order(
          id: 'ORD-12346',
          userId: 'user1',
          restaurantId: 'rest2',
          restaurantName: 'Pizza Heaven',
          restaurantImage: 'https://picsum.photos/400/300?restaurant=2',
          status: OrderStatus.onTheWay,
          totalAmount: 32.50,
          subtotal: 28.50,
          deliveryFee: 3.99,
          tax: 1.99,
          items: [
            OrderItem(
              menuItemId: 'item3',
              name: 'Margherita Pizza',
              imageUrl: 'https://picsum.photos/200/150?pizza=1',
              price: 18.50,
              quantity: 1,
              customizations: [],
            ),
            OrderItem(
              menuItemId: 'item4',
              name: 'Garlic Bread',
              imageUrl: 'https://picsum.photos/200/150?bread=1',
              price: 6.50,
              quantity: 1,
              customizations: [],
            ),
          ],
          deliveryAddress: Address(
            id: 'addr1',
            title: 'Home',
            addressLine1: '123 Main Street',
            addressLine2: 'Apt 4B',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            latitude: 40.7128,
            longitude: -74.0060,
            isDefault: true,
          ),
          paymentInfo: PaymentInfo(
            id: 'pay2',
            method: PaymentMethod.paypal,
            status: PaymentStatus.completed,
            amount: 32.50,
            paidAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          deliveryInfo: DeliveryInfo(
            id: 'del2',
            driverId: 'driver2',
            driverName: 'Mike Johnson',
            driverPhone: '+1234567891',
            status: DeliveryStatus.onTheWay,
            estimatedArrival: DateTime.now().add(const Duration(minutes: 20)),
          ),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 20)),
        ),
        Order(
          id: 'ORD-12347',
          userId: 'user1',
          restaurantId: 'rest3',
          restaurantName: 'Sushi Zen',
          restaurantImage: 'https://picsum.photos/400/300?restaurant=3',
          status: OrderStatus.preparing,
          totalAmount: 45.75,
          subtotal: 40.75,
          deliveryFee: 4.99,
          tax: 2.99,
          items: [
            OrderItem(
              menuItemId: 'item5',
              name: 'Rainbow Roll',
              imageUrl: 'https://picsum.photos/200/150?sushi=1',
              price: 24.75,
              quantity: 1,
              customizations: [],
            ),
            OrderItem(
              menuItemId: 'item6',
              name: 'Miso Soup',
              imageUrl: 'https://picsum.photos/200/150?soup=1',
              price: 4.50,
              quantity: 1,
              customizations: [],
            ),
          ],
          deliveryAddress: Address(
            id: 'addr1',
            title: 'Home',
            addressLine1: '123 Main Street',
            addressLine2: 'Apt 4B',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            latitude: 40.7128,
            longitude: -74.0060,
            isDefault: true,
          ),
          paymentInfo: PaymentInfo(
            id: 'pay3',
            method: PaymentMethod.card,
            status: PaymentStatus.completed,
            amount: 45.75,
            paidAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          deliveryInfo: DeliveryInfo(
            id: 'del3',
            status: DeliveryStatus.pending,
          ),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 40)),
        ),
      ];
      _isLoading = false;
    });
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;
    
    return _orders.where((order) {
      switch (_selectedFilter) {
        case 'Active':
          return order.status.index <= OrderStatus.onTheWay.index;
        case 'Completed':
          return order.status == OrderStatus.delivered;
        case 'Cancelled':
          return order.status == OrderStatus.cancelled;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Orders',
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const PageLoadingIndicator(message: 'Loading orders...')
          : Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filterOptions[index];
                      final isSelected = _selectedFilter == filter;
                      
                      return ChoiceChip(
                        label: Text(
                          filter,
                          style: AppStyles.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppColors.backgroundColor,
                        selectedColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredOrders.length} orders',
                        style: AppStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_filteredOrders.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Sort orders
                          },
                          child: Row(
                            children: [
                              Text(
                                'Recent',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: _filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredOrders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return OrderCard(
                                order: order,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(order: order),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No orders yet',
              style: AppStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When you place orders, they will appear here',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Browse Restaurants'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName,
                          style: AppStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.formattedDate,
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.id,
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: AppStyles.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              Column(
                children: order.items.take(2).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
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
                                  size: 20,
                                  color: AppColors.textDisabled,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: AppStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              if (order.items.length > 2) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 52, top: 4),
                  child: Text(
                    '+ ${order.items.length - 2} more items',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.formattedTotalAmount,
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (order.status == OrderStatus.delivered)
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 64),
                            child: OutlinedButton(
                              onPressed: () {
                                // Reorder functionality
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Reorder',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (order.status.index <= OrderStatus.onTheWay.index)
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 64),
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Track Order'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
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
        return Icons.access_time;
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
}