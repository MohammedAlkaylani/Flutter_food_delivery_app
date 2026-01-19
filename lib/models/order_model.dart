import 'package:food2/models/restaurant_model.dart';
import 'package:food2/models/user_model.dart';

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final OrderStatus status;
  final double totalAmount;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final List<OrderItem> items;
  final Address deliveryAddress;
  final PaymentInfo paymentInfo;
  final DeliveryInfo deliveryInfo;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final String? specialInstructions;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.status,
    required this.totalAmount,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.items,
    required this.deliveryAddress,
    required this.paymentInfo,
    required this.deliveryInfo,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.specialInstructions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['order_id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      restaurantImage: json['restaurant_image'],
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['order_status'],
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      deliveryAddress: Address.fromJson(json['delivery_address']),
      paymentInfo: PaymentInfo.fromJson(json['payment_info']),
      deliveryInfo: DeliveryInfo.fromJson(json['delivery_info']),
      createdAt: DateTime.parse(json['created_at']),
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      specialInstructions: json['special_instructions'],
    );
  }

  String get formattedTotalAmount => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedDate => _formatDate(createdAt);
  String get formattedTime => _formatTime(createdAt);
  String get formattedEstimatedDelivery =>
      estimatedDeliveryTime != null ? _formatTime(estimatedDeliveryTime!) : '';

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) return 'Today';
    if (orderDate == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
}

class OrderItem {
  final String menuItemId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final List<SelectedCustomization> customizations;

  OrderItem({
    required this.menuItemId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.customizations,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menu_id'],
      name: json['item_name'],
      imageUrl: json['image_url'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      customizations: (json['customizations'] as List<dynamic>?)
          ?.map((customization) => SelectedCustomization.fromJson(customization))
          .toList() ?? [],
    );
  }

  double get totalPrice => price * quantity;
}

class SelectedCustomization {
  final String optionName;
  final String choiceName;
  final double? additionalPrice;

  SelectedCustomization({
    required this.optionName,
    required this.choiceName,
    this.additionalPrice,
  });

  factory SelectedCustomization.fromJson(Map<String, dynamic> json) {
    return SelectedCustomization(
      optionName: json['option_name'],
      choiceName: json['choice_name'],
      additionalPrice: json['additional_price']?.toDouble(),
    );
  }
}

class PaymentInfo {
  final String id;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final DateTime? paidAt;
  final String? transactionId;

  PaymentInfo({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    this.paidAt,
    this.transactionId,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['payment_id'],
      method: PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last == json['payment_method'],
        orElse: () => PaymentMethod.card,
      ),
      status: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      transactionId: json['transaction_id'],
    );
  }
}

enum PaymentMethod {
  card,
  cash,
  paypal,
  applePay,
  googlePay,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

class DeliveryInfo {
  final String id;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverImage;
  final String? vehicleType;
  final DeliveryStatus status;
  final Location? currentLocation;
  final DateTime? estimatedArrival;
  final DateTime? actualDeliveryTime;

  DeliveryInfo({
    required this.id,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverImage,
    this.vehicleType,
    required this.status,
    this.currentLocation,
    this.estimatedArrival,
    this.actualDeliveryTime,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      id: json['delivery_id'],
      driverId: json['driver_id'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverImage: json['driver_image'],
      vehicleType: json['vehicle_type'],
      status: DeliveryStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['delivery_status'],
        orElse: () => DeliveryStatus.pending,
      ),
      currentLocation: json['current_location'] != null
          ? Location.fromJson(json['current_location'])
          : null,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'])
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'])
          : null,
    );
  }
}

enum DeliveryStatus {
  pending,
  assigned,
  pickedUp,
  onTheWay,
  arrived,
  delivered,
}