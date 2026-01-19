import 'package:flutter/foundation.dart';
import 'package:food2/models/menu_model.dart';
import 'package:food2/models/order_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _deliveryFee = 2.99;
  double _taxRate = 0.08;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(
      0,
          (sum, item) => sum + (item.price * item.quantity) + item.customizationsTotal
  );

  double get deliveryFee => _deliveryFee;
  double get tax => subtotal * _taxRate;
  double get total => subtotal + deliveryFee + tax;

  void addItem(
      MenuItem menuItem, {
        int quantity = 1,
        List<SelectedCustomization> customizations = const [],
      }) {
    final existingIndex = _items.indexWhere(
          (item) => item.menuItemId == menuItem.id &&
          listEquals(item.customizations, customizations),
    );

    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        imageUrl: menuItem.imageUrl,
        price: menuItem.price,
        quantity: quantity,
        customizations: customizations,
        category: menuItem.category,
      ));
    }

    notifyListeners();
  }

  void removeItem(String menuItemId, List<SelectedCustomization> customizations) {
    _items.removeWhere(
          (item) => item.menuItemId == menuItemId &&
          listEquals(item.customizations, customizations),
    );
    notifyListeners();
  }

  void updateQuantity(
      String menuItemId,
      List<SelectedCustomization> customizations,
      int quantity,
      ) {
    final index = _items.indexWhere(
          (item) => item.menuItemId == menuItemId &&
          listEquals(item.customizations, customizations),
    );

    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool containsItem(String menuItemId, List<SelectedCustomization> customizations) {
    return _items.any(
          (item) => item.menuItemId == menuItemId &&
          listEquals(item.customizations, customizations),
    );
  }

  int getItemQuantity(String menuItemId, List<SelectedCustomization> customizations) {
    final item = _items.firstWhere(
          (item) => item.menuItemId == menuItemId &&
          listEquals(item.customizations, customizations),
      orElse: () => CartItem(
        menuItemId: '',
        name: '',
        price: 0,
        quantity: 0,
        customizations: [],
        category: '',
      ),
    );
    return item.quantity;
  }
}

class CartItem {
  final String menuItemId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final List<SelectedCustomization> customizations;
  final String category;

  CartItem({
    required this.menuItemId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.customizations,
    required this.category,
  });

  CartItem copyWith({
    String? menuItemId,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
    List<SelectedCustomization>? customizations,
    String? category,
  }) {
    return CartItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      category: category ?? this.category,
    );
  }

  double get customizationsTotal => customizations.fold(
      0,
          (sum, customization) => sum + (customization.additionalPrice ?? 0)
  );

  double get totalPrice => (price + customizationsTotal) * quantity;

  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';

  String get customizationsDescription {
    if (customizations.isEmpty) return '';
    return customizations
        .map((c) => '${c.optionName}: ${c.choiceName}')
        .join(', ');
  }
}