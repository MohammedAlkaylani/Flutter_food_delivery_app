import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/data/providers/cart_provider.dart';
import 'package:food2/data/providers/location_provider.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/screens/home/restaurant_list_screen.dart';
import 'package:food2/screens/notifications/notifications_screen.dart';
import 'package:food2/screens/home/menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food2/screens/search/search_screen.dart';
import 'package:food2/screens/order/order_history_screen.dart';
import 'package:food2/screens/profile/profile_screen.dart';
import 'package:food2/screens/admin/add_menu_item_screen.dart';

import '../../models/menu_model.dart';
import '../../models/restaurant_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const RestaurantListScreen(),
    const SearchScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              indicatorColor: Colors.transparent,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.textDisabled,
              labelStyle: AppStyles.labelSmall,
              tabs: [
                Tab(
                  icon: Icon(
                    _currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    size: 24,
                  ),
                  text: 'Home',
                ),
                Tab(
                  icon: Icon(
                    _currentIndex == 1
                        ? Icons.restaurant_rounded
                        : Icons.restaurant_outlined,
                    size: 24,
                  ),
                  text: 'Restaurants',
                ),
                Tab(
                  icon: Icon(
                    _currentIndex == 2
                        ? Icons.search_rounded
                        : Icons.search_outlined,
                    size: 24,
                  ),
                  text: 'Search',
                ),
                Tab(
                  icon: Badge(
                    isLabelVisible: cartProvider.itemCount > 0,
                    label: Text(cartProvider.itemCount.toString()),
                    child: Icon(
                      _currentIndex == 3
                          ? Icons.shopping_bag_rounded
                          : Icons.shopping_bag_outlined,
                      size: 24,
                    ),
                  ),
                  text: 'Orders',
                ),
                Tab(
                  icon: Icon(
                    _currentIndex == 4
                        ? Icons.person_rounded
                        : Icons.person_outlined,
                    size: 24,
                  ),
                  text: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      floatingActionButton: authProvider.user?.role == AuthRole.admin && authProvider.user?.managedRestaurantId != null ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMenuItemScreen()));
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ) : null,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authProvider.user?.name.split(' ').first ?? 'Guest'}!',
              style: AppStyles.headlineMedium.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () async {
                // Show simple address selection
                final selected = await showModalBottomSheet<Address?>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    final mockAddresses = [
                      Address(
                        id: 'home',
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
                      Address(
                        id: 'work',
                        title: 'Work',
                        addressLine1: '789 Corporate Ave',
                        addressLine2: '',
                        city: 'New York',
                        state: 'NY',
                        zipCode: '10002',
                        latitude: 40.7138,
                        longitude: -74.0010,
                        isDefault: false,
                      ),
                    ];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Text('Select Delivery Address', style: AppStyles.titleLarge),
                        const SizedBox(height: 12),
                        ...mockAddresses.map((a) => ListTile(
                              title: Text(a.title),
                              subtitle: Text(a.addressLine1),
                              onTap: () => Navigator.pop(context, a),
                            )),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );

                if (selected != null) {
                  final locationProvider = context.read<LocationProvider>();
                  locationProvider.setAddress(selected);
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationProvider.currentAddress?.fullAddress ??
                          'Select delivery address',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: Badge(
              isLabelVisible: true,
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search restaurants or dishes...',
                  hintStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: AppStyles.bodyLarge,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '30% OFF',
                            style: AppStyles.labelLarge.copyWith(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'First Order Special',
                          style: AppStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use code: WELCOME30',
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Categories',
              style: AppStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RestaurantListScreen(initialCuisine: category.name)),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            category.icon,
                            size: 32,
                            color: category.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: AppStyles.labelSmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Restaurants',
                  style: AppStyles.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: AppStyles.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('restaurants').orderBy('rating', descending: true).limit(3).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return RestaurantCard(
                        restaurant: _restaurants[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenuScreen(
                                restaurant: _restaurants[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                final docs = snapshot.data!.docs;
                final restList = docs.map((d) => Restaurant.fromFirestore(d.data(), d.id)).toList();

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: restList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final r = restList[index];
                    return RestaurantCard(
                      restaurant: r,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuScreen(restaurant: r),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.name,
    required this.icon,
    required this.color,
  });
}

final _categories = [
  Category(
    name: 'Burger',
    icon: Icons.fastfood,
    color: AppColors.primaryColor,
  ),
  Category(
    name: 'Pizza',
    icon: Icons.local_pizza,
    color: AppColors.secondaryColor,
  ),
  Category(
    name: 'Sushi',
    icon: Icons.set_meal,
    color: AppColors.infoColor,
  ),
  Category(
    name: 'Coffee',
    icon: Icons.coffee,
    color: AppColors.warningColor,
  ),
  Category(
    name: 'Dessert',
    icon: Icons.cake,
    color: AppColors.errorColor,
  ),
];

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 160,
                    color: AppColors.backgroundColor,
                    child: Image.network(
                      restaurant.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.successColor.withOpacity(0.9)
                            : AppColors.errorColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'OPEN' : 'CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: AppStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.formattedRating,
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${restaurant.reviewCount})',
                            style: AppStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisineType,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.formattedDeliveryFee} • ${restaurant.formattedDeliveryTime}',
                        style: AppStyles.bodySmall,
                      ),
                      if (restaurant.distance != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${restaurant.distance!.toStringAsFixed(1)} km',
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularItemCard extends StatelessWidget {
  final MenuItem item;

  const PopularItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              height: 86,
              color: AppColors.backgroundColor,
              child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 40,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                      color: AppColors.textDisabled,
                    ),
                  ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.formattedPrice,
                        style: AppStyles.titleLarge.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final cart = context.read<CartProvider>();
                          cart.addItem(item, quantity: 1);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${item.name} to cart')));
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _restaurants = [
  Restaurant(
    id: '1',
    name: 'Burger Palace',
    description: 'Best burgers in town',
    address: '123 Main St, New York',
    phone: '+1234567890',
    rating: 4.5,
    reviewCount: 124,
    cuisineType: 'American',
    imageUrl: 'https://picsum.photos/400/300?food=1',
    deliveryFee: 2.99,
    deliveryTime: 25,
    distance: 1.5,
    isOpen: true,
    tags: ['Burger', 'Fast Food', 'American'],
    location: Location(latitude: 40.7128, longitude: -74.0060),
  ),
  Restaurant(
    id: '2',
    name: 'Pizza Heaven',
    description: 'Authentic Italian pizza',
    address: '456 Broadway, New York',
    phone: '+1234567891',
    rating: 4.7,
    reviewCount: 89,
    cuisineType: 'Italian',
    imageUrl: 'https://picsum.photos/400/300?food=2',
    deliveryFee: 3.99,
    deliveryTime: 30,
    distance: 2.1,
    isOpen: true,
    tags: ['Pizza', 'Italian', 'Pasta'],
    location: Location(latitude: 40.7580, longitude: -73.9855),
  ),
  Restaurant(
    id: '3',
    name: 'Sushi Zen',
    description: 'Fresh sushi and Japanese cuisine',
    address: '789 Park Ave, New York',
    phone: '+1234567892',
    rating: 4.9,
    reviewCount: 156,
    cuisineType: 'Japanese',
    imageUrl: 'https://picsum.photos/400/300?food=3',
    deliveryFee: 4.99,
    deliveryTime: 35,
    distance: 3.2,
    isOpen: true,
    tags: ['Sushi', 'Japanese', 'Asian'],
    location: Location(latitude: 40.7505, longitude: -73.9934),
  ),
];
