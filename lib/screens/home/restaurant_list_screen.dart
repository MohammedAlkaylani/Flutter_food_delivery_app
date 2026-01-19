import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/core/widgets/loading_indicator.dart';
import 'package:food2/data/providers/location_provider.dart';
import 'package:food2/models/restaurant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:food2/screens/home/menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  final String? initialCuisine;

  const RestaurantListScreen({super.key, this.initialCuisine});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  String _selectedCuisine = 'All';
  String _sortBy = 'rating';
  final List<String> _cuisines = ['All', 'American', 'Italian', 'Japanese', 'Chinese', 'Mexican', 'Indian'];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadRestaurants() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('restaurants').get();
      final docs = snap.docs;
      if (docs.isNotEmpty) {
        final loaded = docs.map((d) => Restaurant.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList();
        if (!mounted) return;
        setState(() {
          _restaurants = loaded;
          _filteredRestaurants = _restaurants;
          _isLoading = false;
        });
        if (widget.initialCuisine != null && widget.initialCuisine!.isNotEmpty) {
          _filterByCuisine(widget.initialCuisine!);
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) print('Error loading restaurants from Firestore: $e');
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _restaurants = [
        Restaurant(
          id: '1',
          name: 'Burger Palace',
          description: 'Best burgers in town with fresh ingredients',
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
          description: 'Authentic Italian pizza baked in wood-fired oven',
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
      ];
      _filteredRestaurants = _restaurants;
      _isLoading = false;
    });

    if (widget.initialCuisine != null && widget.initialCuisine!.isNotEmpty) {
      _filterByCuisine(widget.initialCuisine!);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          return restaurant.name.toLowerCase().contains(query) ||
              restaurant.cuisineType.toLowerCase().contains(query) ||
              restaurant.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _filterByCuisine(String cuisine) {
    setState(() {
      _selectedCuisine = cuisine;
      if (cuisine == 'All') {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants
            .where((restaurant) => restaurant.cuisineType == cuisine)
            .toList();
      }
    });
  }

  void _sortRestaurants(String sortBy) {
    setState(() {
      _sortBy = sortBy;

      switch (sortBy) {
        case 'rating':
          _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'deliveryTime':
          _filteredRestaurants.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
          break;
        case 'deliveryFee':
          _filteredRestaurants.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
          break;
        case 'distance':
          _filteredRestaurants.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
          break;
      }
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: AppStyles.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Sort By',
                style: AppStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Rating'),
                    selected: _sortBy == 'rating',
                    onSelected: (_) {
                      _sortRestaurants('rating');
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Delivery Time'),
                    selected: _sortBy == 'deliveryTime',
                    onSelected: (_) {
                      _sortRestaurants('deliveryTime');
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Delivery Fee'),
                    selected: _sortBy == 'deliveryFee',
                    onSelected: (_) {
                      _sortRestaurants('deliveryFee');
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Distance'),
                    selected: _sortBy == 'distance',
                    onSelected: (_) {
                      _sortRestaurants('distance');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: AppStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Open Now'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Free Delivery'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Restaurants',
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
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
        ],
      ),
      body: _isLoading
          ? const PageLoadingIndicator(message: 'Loading restaurants...')
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.backgroundColor,
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
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
                TextButton(
                  onPressed: () {
                  },
                  child: Text(
                    'Change',
                    style: AppStyles.labelLarge,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search restaurants...',
                  hintStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: AppStyles.bodyLarge,
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _cuisines.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final isSelected = _selectedCuisine == cuisine;

                return ChoiceChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  onSelected: (_) => _filterByCuisine(cuisine),
                  labelStyle: AppStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
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
                  '${_filteredRestaurants.length} restaurants found',
                  style: AppStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: _showFilterDialog,
                  child: Row(
                    children: [
                      Text(
                        'Sort: ',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _getSortLabel(),
                        style: AppStyles.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRestaurants,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _filteredRestaurants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuScreen(restaurant: restaurant),
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

  String _getSortLabel() {
    switch (_sortBy) {
      case 'rating':
        return 'Rating';
      case 'deliveryTime':
        return 'Fastest';
      case 'deliveryFee':
        return 'Cheapest';
      case 'distance':
        return 'Nearest';
      default:
        return 'Rating';
    }
  }
}

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
            // Restaurant Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 160,
                    color: AppColors.backgroundColor,
                    child: (restaurant.imageUrl.isNotEmpty)
                      ? Image.network(
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
                        )
                      : Center(
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