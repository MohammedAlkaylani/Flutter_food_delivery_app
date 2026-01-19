import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<TrackingStep> _trackingSteps = [];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeTrackingSteps();
  }

  void _initializeTrackingSteps() {
    _trackingSteps = [
      TrackingStep(
        title: 'Order Placed',
        description: 'Your order has been received',
        isCompleted: true,
        time: widget.order.createdAt,
        icon: Icons.shopping_bag_outlined,
      ),
      TrackingStep(
        title: 'Order Confirmed',
        description: 'Restaurant has accepted your order',
        isCompleted: widget.order.status.index >= OrderStatus.confirmed.index,
        time: widget.order.createdAt.add(const Duration(minutes: 5)),
        icon: Icons.check_circle_outline,
      ),
      TrackingStep(
        title: 'Preparing Food',
        description: 'Chef is cooking your delicious meal',
        isCompleted: widget.order.status.index >= OrderStatus.preparing.index,
        time: widget.order.createdAt.add(const Duration(minutes: 15)),
        icon: Icons.restaurant,
      ),
      TrackingStep(
        title: 'Ready for Pickup',
        description: 'Your order is ready for delivery',
        isCompleted: widget.order.status.index >= OrderStatus.ready.index,
        time: widget.order.createdAt.add(const Duration(minutes: 25)),
        icon: Icons.done_all,
      ),
      TrackingStep(
        title: 'Picked Up',
        description: 'Delivery partner picked up your order',
        isCompleted: widget.order.status.index >= OrderStatus.pickedUp.index,
        time: widget.order.createdAt.add(const Duration(minutes: 30)),
        icon: Icons.delivery_dining,
      ),
      TrackingStep(
        title: 'On the Way',
        description: 'Your food is on its way to you',
        isCompleted: widget.order.status.index >= OrderStatus.onTheWay.index,
        time: widget.order.createdAt.add(const Duration(minutes: 35)),
        icon: Icons.directions_bike,
      ),
      TrackingStep(
        title: 'Delivered',
        description: 'Your order has been delivered',
        isCompleted: widget.order.status == OrderStatus.delivered,
        time: widget.order.estimatedDeliveryTime,
        icon: Icons.check_circle,
      ),
    ];

    for (int i = 0; i < _trackingSteps.length; i++) {
      if (!_trackingSteps[i].isCompleted) {
        _currentStepIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Track Order',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),

            _buildTrackingTimeline(),

            if (widget.order.deliveryInfo.driverId != null)
              _buildDriverInfo(),

            _buildEstimatedTime(),

            _buildHelpSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Order #${widget.order.id}',
            style: AppStyles.headlineSmall.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.restaurantName,
            style: AppStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated delivery in 20-30 minutes',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        children: [
          Text(
            'Order Tracking',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 20),
          ..._trackingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCurrentStep = index == _currentStepIndex;
            final isLastStep = index == _trackingSteps.length - 1;
            
            return _buildTimelineStep(
              step: step,
              isCurrentStep: isCurrentStep,
              isLastStep: isLastStep,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required TrackingStep step,
    required bool isCurrentStep,
    required bool isLastStep,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line and Icon
        Column(
          children: [
            // Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrentStep
                    ? AppColors.primaryColor
                    : step.isCompleted
                        ? AppColors.successColor
                        : AppColors.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCompleted || isCurrentStep
                      ? Colors.transparent
                      : AppColors.borderColor,
                  width: 2,
                ),
              ),
              child: Icon(
                step.icon,
                size: 20,
                color: step.isCompleted || isCurrentStep
                    ? Colors.white
                    : AppColors.textDisabled,
              ),
            ),

            if (!isLastStep)
              Container(
                width: 2,
                height: 60,
                color: step.isCompleted
                    ? AppColors.successColor
                    : AppColors.borderColor,
              ),
          ],
        ),
        
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCurrentStep
                      ? AppColors.primaryColor
                      : step.isCompleted
                          ? AppColors.successColor
                          : AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                step.description,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              if (step.time != null) ...[
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
                      _formatTime(step.time!),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (isCurrentStep && step.title == 'On the Way') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_bike,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your delivery partner is on the way to your location',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    final driver = widget.order.deliveryInfo;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
            'Your Delivery Partner',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Driver Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: (driver.driverImage != null && driver.driverImage!.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          driver.driverImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primaryColor,
                      ),
              ),
              
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.driverName ?? 'Delivery Partner',
                      style: AppStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (driver.vehicleType != null)
                      Text(
                        driver.vehicleType!,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rating',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedTime() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          Icon(
            Icons.access_time_filled_rounded,
            color: AppColors.primaryColor,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery Time',
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.estimatedDeliveryTime != null
                      ? '${widget.order.formattedEstimatedDelivery} (± 5 mins)'
                      : 'Calculating...',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.order.deliveryInfo.estimatedArrival != null)
            Text(
              '20 min',
              style: AppStyles.displaySmall.copyWith(
                color: AppColors.primaryColor,
                fontSize: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
            'Need Help?',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Call support
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Support'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Chat support
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Live Chat'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class TrackingStep {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? time;
  final IconData icon;

  TrackingStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    this.time,
    required this.icon,
  });
}