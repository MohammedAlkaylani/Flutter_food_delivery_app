import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/models/restaurant_model.dart';
import 'package:food2/models/menu_model.dart';
import 'package:food2/screens/home/menu_screen.dart';
import 'package:food2/screens/home/menu_item_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = [];
  List<String> _recentSearches = [
    'Burger',
    'Pizza',
    'Sushi',
    'Coffee',
    'Pasta',
  ];
  
  List<String> _popularSearches = [
    'Chicken Biryani',
    'Margherita Pizza',
    'Chocolate Cake',
    'Fresh Juice',
    'Vegan Burger',
    'Salad Bowl',
    'Ice Cream',
    'Fried Rice',
  ];
  
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _performFirebaseSearch(query);
    } else {
      setState(() {
        _restaurants.clear();
        _menuItems.clear();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _restaurants.clear();
      _menuItems.clear();
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
      _isSearching = true;
    });
    _searchFocusNode.unfocus();
    _performFirebaseSearch(query);
  }

  Future<void> _performFirebaseSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _restaurants.clear();
        _menuItems.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final searchQuery = query.toLowerCase();

      final restaurantsSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('is_open', isEqualTo: true) // Only open restaurants
          .get();

      final List<Restaurant> foundRestaurants = [];
      
      for (var doc in restaurantsSnapshot.docs) {
        final data = doc.data();
        final name = data['name']?.toString().toLowerCase() ?? '';
        final cuisineType = data['cuisine_type']?.toString().toLowerCase() ?? '';
        final tags = List<String>.from(data['tags'] ?? [])
            .map((tag) => tag.toLowerCase())
            .toList();

        if (name.contains(searchQuery) ||
            cuisineType.contains(searchQuery) ||
            tags.any((tag) => tag.contains(searchQuery))) {
          foundRestaurants.add(Restaurant.fromFirestore(data, doc.id));
        }
      }

      final menuItems = await _searchMenuItems(searchQuery, restaurantsSnapshot.docs);

      setState(() {
        _restaurants = foundRestaurants;
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<List<MenuItem>> _searchMenuItems(
    String searchQuery,
    List<QueryDocumentSnapshot> restaurantDocs,
  ) async {
    try {
      final List<MenuItem> foundItems = [];

      for (var restaurantDoc in restaurantDocs) {
        final restaurantId = restaurantDoc.id;
        final restaurantData = restaurantDoc.data() as Map<String, dynamic>;
        final restaurantName = restaurantData['name'] ?? 'Unknown Restaurant';

        final menuSnapshot = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .where('availability_status', isEqualTo: true)
            .get();

        for (var menuDoc in menuSnapshot.docs) {
          final data = menuDoc.data();

          final Map<String, dynamic> menuItemJson = {
            'menu_id': menuDoc.id,
            'item_name': data['item_name'] ?? 'Unknown Item',
            'description': data['description'] ?? '',
            'price': data['price'] ?? 0.0,
            'image_url': data['image_url'],
            'category': data['category'] ?? 'Main',
            'availability_status': data['availability_status'] ?? true,
            'preparation_time': data['preparation_time'] ?? 15,
            'customization_options': data['customization_options'] ?? [],
            'tags': data['tags'] ?? [],
            'nutritional_info': data['nutritional_info'],
          };

          final itemName = menuItemJson['item_name']?.toString().toLowerCase() ?? '';
          final description = menuItemJson['description']?.toString().toLowerCase() ?? '';
          final category = menuItemJson['category']?.toString().toLowerCase() ?? '';
          final tags = List<String>.from(menuItemJson['tags'] ?? [])
              .map((tag) => tag.toLowerCase())
              .toList();

          if (itemName.contains(searchQuery) ||
              description.contains(searchQuery) ||
              category.contains(searchQuery) ||
              tags.any((tag) => tag.contains(searchQuery))) {
            
            final menuItem = MenuItem.fromJson(menuItemJson);
            foundItems.add(menuItem);
          }
        }
      }

      return foundItems;
    } catch (e) {
      return [];
    }
  }

  List<Restaurant> get _filteredRestaurants => _restaurants;

  List<MenuItem> get _filteredMenuItems => _menuItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search restaurants, dishes, or cuisines...',
              hintStyle: AppStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: _isSearching
          ? _buildSearchResults()
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchResults() {
    final hasRestaurantResults = _filteredRestaurants.isNotEmpty;
    final hasMenuItemResults = _filteredMenuItems.isNotEmpty;
    final hasNoResults = !hasRestaurantResults && !hasMenuItemResults && !_isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading) ...[
            const SizedBox(height: 40),
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Searching...',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else if (hasNoResults) ...[
            _buildNoResults(),
          ] else ...[
            if (hasRestaurantResults) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Restaurants (${_filteredRestaurants.length})',
                  style: AppStyles.headlineSmall,
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return _buildRestaurantResult(restaurant);
                },
              ),
            ],
            
            if (hasMenuItemResults) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Menu Items (${_filteredMenuItems.length})',
                  style: AppStyles.headlineSmall,
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _filteredMenuItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredMenuItems[index];
                  return _buildMenuItemResult(item);
                },
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildRestaurantResult(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(restaurant: restaurant),
            ),
          );
        },
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: restaurant.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(restaurant.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: restaurant.imageUrl.isEmpty
                ? AppColors.backgroundColor
                : null,
          ),
          child: restaurant.imageUrl.isEmpty
              ? const Icon(
                  Icons.restaurant,
                  color: AppColors.textDisabled,
                )
              : null,
        ),
        title: Text(
          restaurant.name,
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              restaurant.cuisineType,
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.warningColor,
                ),
                const SizedBox(width: 4),
                Text(
                  restaurant.formattedRating,
                  style: AppStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' (${restaurant.reviewCount})',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.delivery_dining,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${restaurant.formattedDeliveryFee} • ${restaurant.formattedDeliveryTime}',
                  style: AppStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuItemResult(MenuItem item) {
    Restaurant? restaurantForItem;
    for (var restaurant in _restaurants) {
      break;
    }

    final restaurant = restaurantForItem ?? Restaurant(
      id: 'unknown',
      name: 'Restaurant',
      description: '',
      address: '',
      phone: '',
      rating: 0.0,
      reviewCount: 0,
      cuisineType: item.category,
      imageUrl: '',
      deliveryFee: 0.0,
      deliveryTime: 0,
      distance: 0.0,
      isOpen: true,
      tags: [],
      location: Location(latitude: 0, longitude: 0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenuItemDetail(item: item, restaurant: restaurant),
            ),
          );
        },
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundColor,
            image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: item.imageUrl == null || item.imageUrl!.isEmpty
              ? const Icon(
                  Icons.fastfood,
                  color: AppColors.textDisabled,
                )
              : null,
        ),
        title: Text(
          item.name,
          style: AppStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${restaurant.name} • ${item.category}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.formattedPrice,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return SingleChildScrollView(
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
              Icons.search_off_rounded,
              size: 60,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: AppStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try searching for something else',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () => _performSearch(search),
                backgroundColor: AppColors.backgroundColor,
                labelStyle: AppStyles.bodyMedium,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppStyles.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((search) {
                  return ActionChip(
                    label: Text(search),
                    onPressed: () => _performSearch(search),
                    backgroundColor: AppColors.backgroundColor,
                    avatar: const Icon(
                      Icons.history,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    labelStyle: AppStyles.bodyMedium,
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Popular Searches',
              style: AppStyles.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearches.map((search) {
                return ActionChip(
                  label: Text(search),
                  onPressed: () => _performSearch(search),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  labelStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Browse Categories',
              style: AppStyles.titleLarge,
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryCard('🍔', 'Burger', AppColors.primaryColor),
                _buildCategoryCard('🍕', 'Pizza', AppColors.secondaryColor),
                _buildCategoryCard('🍣', 'Sushi', AppColors.infoColor),
                _buildCategoryCard('☕', 'Coffee', AppColors.warningColor),
                _buildCategoryCard('🍰', 'Dessert', AppColors.errorColor),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String name, Color color) {
    return GestureDetector(
      onTap: () => _performSearch(name),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}