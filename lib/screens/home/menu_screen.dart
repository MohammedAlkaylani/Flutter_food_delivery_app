import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/loading_indicator.dart';
import 'package:food2/data/providers/cart_provider.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/models/user_model.dart';
import 'package:food2/models/menu_model.dart';
import 'package:food2/screens/admin/add_menu_item_screen.dart';
import 'package:food2/models/restaurant_model.dart';
import 'package:food2/screens/home/menu_item_detail.dart';
import 'package:food2/screens/cart/cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  final List<MenuCategory> _categories = [];
  bool _isLoading = true;
  double _appBarHeight = 200;
  double _scrollOffset = 0;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _showAppBarTitle = _scrollOffset > _appBarHeight - 100;
    });
  }

  Future<void> _loadMenuData() async {
    try {
      final menuSnap = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurant.id)
          .collection('menu')
          .get();

      if (menuSnap.docs.isNotEmpty) {
        final Map<String, List<MenuItem>> groups = {};
        for (var doc in menuSnap.docs) {
          final data = doc.data();
          try {
            final item = MenuItem.fromJson(data);
            groups.putIfAbsent(item.category, () => []).add(item);
          } catch (_) {
          }
        }

        final categories = groups.entries.map((e) => MenuCategory(
          id: e.key,
          name: e.key,
          description: null,
          items: e.value,
        )).toList();

        setState(() {
          _categories.clear();
          _categories.addAll(categories);
          _isLoading = false;
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );

          for (var c in _categories) {
            _categoryKeys[c.name] = GlobalKey();
          }
        });
        return;
      }
    } catch (e) {
    }

    await Future.delayed(const Duration(seconds: 1));
    final mockCategories = [
      MenuCategory(
        id: '1',
        name: 'Main Course',
        description: 'Hearty main dishes',
        items: [
          MenuItem(
            id: '201',
            name: 'Classic Cheeseburger',
            description: 'Beef patty with cheese, lettuce, tomato, and special sauce',
            price: 12.99,
            imageUrl: 'https://picsum.photos/200/150?burger=1',
            category: 'Main Course',
            isAvailable: true,
            preparationTime: 15,
            customizationOptions: [],
            tags: ['Popular', 'Beef', 'Cheese'],
          ),
        ],
      ),
    ];

    setState(() {
      _categories.clear();
      _categories.addAll(mockCategories);
      _isLoading = false;
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
      );

      for (var category in _categories) {
        _categoryKeys[category.name] = GlobalKey();
      }
    });
  }

  void _scrollToCategory(String categoryName) {
    final key = _categoryKeys[categoryName];
    if (key != null) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      body: _isLoading
          ? const PageLoadingIndicator(message: 'Loading menu...')
          : NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _appBarHeight,
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: _showAppBarTitle
                  ? AppColors.textPrimary
                  : Colors.white,
              title: _showAppBarTitle
                  ? Text(
                widget.restaurant.name,
                style: AppStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              )
                  : null,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: _showAppBarTitle
                      ? AppColors.textPrimary
                      : Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Builder(builder: (context) {
                  final authProvider = context.watch<AuthProvider>();
                  final isAdminForThisRestaurant = authProvider.user?.role == AuthRole.admin && authProvider.user?.managedRestaurantId == widget.restaurant.id;
                  if (isAdminForThisRestaurant) {
                    return IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMenuItemScreen()));
                      },
                      icon: const Icon(Icons.add),
                      color: _showAppBarTitle ? AppColors.textPrimary : Colors.white,
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildAppBarContent(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      _scrollToCategory(_categories[index].name);
                    },
                    indicatorColor: AppColors.primaryColor,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppStyles.titleMedium,
                    unselectedLabelStyle: AppStyles.titleMedium,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabs: _categories
                        .map((category) => Tab(text: category.name))
                        .toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((category) {
            return SingleChildScrollView(
              key: _categoryKeys[category.name],
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.description != null) ...[
                    Text(
                      category.description!,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: category.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = category.items[index];
                      return MenuItemCard(
                        item: item,
                        restaurant: widget.restaurant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenuItemDetail(
                                item: item,
                                restaurant: widget.restaurant,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: cartProvider.itemCount > 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: Badge(
          label: Text(cartProvider.itemCount.toString()),
          backgroundColor: Colors.white,
          textColor: AppColors.primaryColor,
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        label: Text(
          'View Cart • \$${cartProvider.subtotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        image: DecorationImage(
          image: NetworkImage(widget.restaurant.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.restaurant.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.warningColor,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.restaurant.formattedRating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' (${widget.restaurant.reviewCount} reviews)',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.delivery_dining,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.restaurant.formattedDeliveryFee} • ${widget.restaurant.formattedDeliveryTime}',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.restaurant.cuisineType,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.containsItem(item.id, []);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
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
                    ? Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 40,
                    color: AppColors.textDisabled,
                  ),
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
                      style: AppStyles.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.preparationTime} min',
                          style: AppStyles.bodySmall,
                        ),
                        if (item.tags.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          ...item.tags.take(2).map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: AppStyles.labelSmall.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.formattedPrice,
                          style: AppStyles.titleLarge.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        if (isInCart)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cartProvider.updateQuantity(
                                      item.id,
                                      [],
                                      cartProvider.getItemQuantity(item.id, []) - 1,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    cartProvider.getItemQuantity(item.id, []).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    cartProvider.addItem(item, quantity: 1);
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () {
                              cartProvider.addItem(item, quantity: 1);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
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
}