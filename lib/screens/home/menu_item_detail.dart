import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/data/providers/cart_provider.dart';
import 'package:food2/models/menu_model.dart';
import 'package:food2/models/restaurant_model.dart';

import '../../models/order_model.dart';

class MenuItemDetail extends StatefulWidget {
  final MenuItem item;
  final Restaurant restaurant;

  const MenuItemDetail({
    super.key,
    required this.item,
    required this.restaurant,
  });

  @override
  State<MenuItemDetail> createState() => _MenuItemDetailState();
}

class _MenuItemDetailState extends State<MenuItemDetail> {
  int _quantity = 1;
  final Map<String, List<String>> _selectedCustomizations = {};
  double _additionalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    for (final option in widget.item.customizationOptions) {
      if (option.isRequired) {
        final defaultChoice = option.choices.firstWhere(
              (choice) => choice.isDefault,
          orElse: () => option.choices.first,
        );
        _selectedCustomizations[option.id] = [defaultChoice.id];
        if (defaultChoice.additionalPrice != null) {
          _additionalPrice += defaultChoice.additionalPrice!;
        }
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _onCustomizationChanged(
      CustomizationOption option, CustomizationChoice choice, bool selected) {
    setState(() {
      if (selected) {
        if (option.maxChoices == 1) {
          final previousSelection = _selectedCustomizations[option.id];
          if (previousSelection != null && previousSelection.isNotEmpty) {
            final previousChoiceId = previousSelection.first;
            final previousChoice = option.choices
                .firstWhere((c) => c.id == previousChoiceId);
            if (previousChoice.additionalPrice != null) {
              _additionalPrice -= previousChoice.additionalPrice!;
            }
          }
          _selectedCustomizations[option.id] = [choice.id];
        } else {
          final selections = _selectedCustomizations[option.id] ?? [];
          if (!selections.contains(choice.id) &&
              selections.length < option.maxChoices) {
            selections.add(choice.id);
            _selectedCustomizations[option.id] = selections;
          }
        }

        if (choice.additionalPrice != null) {
          _additionalPrice += choice.additionalPrice!;
        }
      } else {
        final selections = _selectedCustomizations[option.id];
        if (selections != null) {
          selections.remove(choice.id);
          if (selections.isEmpty && option.isRequired) {
            final defaultChoice = option.choices.first;
            selections.add(defaultChoice.id);
            if (defaultChoice.additionalPrice != null) {
              _additionalPrice += defaultChoice.additionalPrice!;
            }
          }
        }

        if (choice.additionalPrice != null) {
          _additionalPrice -= choice.additionalPrice!;
        }
      }
    });
  }

  bool _isChoiceSelected(String optionId, String choiceId) {
    return _selectedCustomizations[optionId]?.contains(choiceId) ?? false;
  }

  double get _totalPrice => (widget.item.price + _additionalPrice) * _quantity;

  String get _customizationsSummary {
    final summaries = <String>[];
    for (final option in widget.item.customizationOptions) {
      final selectedIds = _selectedCustomizations[option.id];
      if (selectedIds != null && selectedIds.isNotEmpty) {
        for (final choiceId in selectedIds) {
          final choice = option.choices.firstWhere((c) => c.id == choiceId);
          summaries.add('${option.name}: ${choice.name}');
        }
      }
    }
    return summaries.join(', ');
  }

  void _addToCart() {
    final cartProvider = context.read<CartProvider>();

    final selectedCustomizations = <SelectedCustomization>[];
    for (final option in widget.item.customizationOptions) {
      final selectedIds = _selectedCustomizations[option.id];
      if (selectedIds != null && selectedIds.isNotEmpty) {
        for (final choiceId in selectedIds) {
          final choice = option.choices.firstWhere((c) => c.id == choiceId);
          selectedCustomizations.add(SelectedCustomization(
            optionName: option.name,
            choiceName: choice.name,
            additionalPrice: choice.additionalPrice,
          ));
        }
      }
    }

    cartProvider.addItem(
      widget.item,
      quantity: _quantity,
      customizations: selectedCustomizations,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${_quantity}x ${widget.item.name} to cart',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildItemImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildItemDetails(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildItemImage() {
    return Stack(
      children: [
        Container(
          height: 300,
          color: AppColors.backgroundColor,
          child: (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
              ? Image.network(
                  widget.item.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 80,
                      color: AppColors.textDisabled,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: AppColors.textDisabled,
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.item.name,
                  style: AppStyles.displaySmall.copyWith(
                    fontSize: 24,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '\$${(widget.item.price + _additionalPrice).toStringAsFixed(2)}',
                style: AppStyles.displaySmall.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            widget.item.description,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.item.nutritionalInfo != null) ...[
            _buildNutritionalInfo(),
            const SizedBox(height: 24),
          ],

          if (widget.item.customizationOptions.isNotEmpty) ...[
            Text(
              'Customize your order',
              style: AppStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...widget.item.customizationOptions.map(_buildCustomizationOption),
            const SizedBox(height: 24),
          ],

          if (widget.item.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.item.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preparation Time',
                        style: AppStyles.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready in ${widget.item.preparationTime} minutes',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity',
                  style: AppStyles.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decrementQuantity,
                      style: IconButton.styleFrom(
                        backgroundColor: _quantity > 1
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _quantity > 1
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.remove,
                        color: _quantity > 1
                            ? AppColors.primaryColor
                            : AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _quantity.toString(),
                      style: AppStyles.headlineSmall.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _incrementQuantity,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNutritionalInfo() {
    final info = widget.item.nutritionalInfo!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutritional Information',
            style: AppStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutritionItem('Calories', '${info.calories}'),
              _buildNutritionItem('Protein', '${info.protein}g'),
              _buildNutritionItem('Carbs', '${info.carbs}g'),
              _buildNutritionItem('Fat', '${info.fat}g'),
            ],
          ),
          if (info.allergens.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Allergens: ${info.allergens.join(', ')}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppStyles.titleLarge.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationOption(CustomizationOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              option.name,
              style: AppStyles.titleLarge,
            ),
            if (option.isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppStyles.titleLarge.copyWith(
                  color: AppColors.errorColor,
                ),
              ),
            ],
            const Spacer(),
            if (option.maxChoices > 1)
              Text(
                'Select up to ${option.maxChoices}',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        if (option.maxChoices == 1) ...[
          const SizedBox(height: 12),
          Column(
            children: option.choices.map((choice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    _onCustomizationChanged(option, choice, true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isChoiceSelected(option.id, choice.id)
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isChoiceSelected(option.id, choice.id)
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isChoiceSelected(option.id, choice.id)
                                  ? AppColors.primaryColor
                                  : AppColors.textDisabled,
                              width: 1.5,
                            ),
                          ),
                          child: _isChoiceSelected(option.id, choice.id)
                              ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                choice.name,
                                style: AppStyles.bodyLarge,
                              ),
                              if (choice.additionalPrice != null &&
                                  choice.additionalPrice! > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '+ \$${choice.additionalPrice!.toStringAsFixed(2)}',
                                  style: AppStyles.bodySmall.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (choice.isDefault) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: AppStyles.labelSmall.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.choices.map((choice) {
              return GestureDetector(
                onTap: () {
                  final selected = _isChoiceSelected(option.id, choice.id);
                  if (!selected ||
                      (_selectedCustomizations[option.id]?.length ?? 0) <
                          option.maxChoices) {
                    _onCustomizationChanged(option, choice, !selected);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isChoiceSelected(option.id, choice.id)
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isChoiceSelected(option.id, choice.id)
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _isChoiceSelected(option.id, choice.id)
                                ? AppColors.primaryColor
                                : AppColors.textDisabled,
                            width: 1.5,
                          ),
                          color: _isChoiceSelected(option.id, choice.id)
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                        child: _isChoiceSelected(option.id, choice.id)
                            ? const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        choice.name,
                        style: AppStyles.bodyMedium.copyWith(
                          color: _isChoiceSelected(option.id, choice.id)
                              ? AppColors.primaryColor
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (choice.additionalPrice != null &&
                          choice.additionalPrice! > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+ \$${choice.additionalPrice!.toStringAsFixed(2)}',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: AppStyles.displaySmall.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_customizationsSummary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _customizationsSummary,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            CustomButton(
              onPressed: _addToCart,
              text: 'Add to Cart - \$${_totalPrice.toStringAsFixed(2)}',
              backgroundColor: AppColors.primaryColor,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }
}