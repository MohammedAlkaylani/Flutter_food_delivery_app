import 'package:flutter/material.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_app_bar.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/models/user_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Address> _addresses = [
    Address(
      id: '1',
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
      id: '2',
      title: 'Work',
      addressLine1: '456 Broadway',
      addressLine2: 'Floor 12',
      city: 'New York',
      state: 'NY',
      zipCode: '10013',
      latitude: 40.7209,
      longitude: -74.0007,
      isDefault: false,
    ),
    Address(
      id: '3',
      title: 'Mom\'s House',
      addressLine1: '789 Park Avenue',
      addressLine2: '',
      city: 'New York',
      state: 'NY',
      zipCode: '10021',
      latitude: 40.7685,
      longitude: -73.9654,
      isDefault: false,
    ),
  ];

  void _setDefaultAddress(String addressId) {
    setState(() {
      for (var i = 0; i < _addresses.length; i++) {
        final address = _addresses[i];
        _addresses[i] = address.copyWith(isDefault: address.id == addressId);
      }
    });
  }

  void _deleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((addr) => addr.id == addressId);
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deleted successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewAddress() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Addresses',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressCard(address);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              onPressed: _addNewAddress,
              text: 'Add New Address',
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primaryColor
              : AppColors.borderColor,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? AppColors.primaryColor
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAddressIcon(address.title),
                      size: 14,
                      color: address.isDefault ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      address.title,
                      style: AppStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: address.isDefault ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              
              const Spacer(),
              
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _setDefaultAddress(address.id),
                    child: const Row(
                      children: [
                        Icon(Icons.star_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // Edit address
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => _deleteAddress(address.id),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: AppColors.errorColor),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            address.addressLine1,
            style: AppStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          if (address.addressLine2.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address.addressLine2,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          const SizedBox(height: 4),
          
          Text(
            '${address.city}, ${address.state} ${address.zipCode}',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAddressIcon(String title) {
    switch (title.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }
}