import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
// import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/core/widgets/custom_text_field.dart';
import 'package:food2/core/widgets/custom_button.dart';
import 'package:food2/data/providers/auth_provider.dart';

class AddMenuItemScreen extends StatefulWidget {
  final String? menuItemId;
  const AddMenuItemScreen({super.key, this.menuItemId});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Main');
  final _imageUrlController = TextEditingController();
  int _prepTime = 15;
  bool _isAvailable = true;
  bool _isSaving = false;

  XFile? _pickedImage;
  String? _existingImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (file != null) {
      setState(() {
        _pickedImage = file;
      });
    }
  }

  Future<String?> _uploadImage(String restaurantId, String menuItemId) async {
    if (_pickedImage == null) return _existingImageUrl;
    final path = 'restaurants/$restaurantId/menu/$menuItemId/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      if (kDebugMode) print('Uploading image to Storage path: ${ref.fullPath}');
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(_pickedImage!.path));
      }
      final url = await ref.getDownloadURL();
      if (kDebugMode) print('Image uploaded, download URL: $url');
      return url;
    } on FirebaseException catch (e) {
      if (kDebugMode) print('Menu image upload failed: ${e.code} - ${e.message}');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: ${e.code}')));
      return null;
    } catch (e) {
      if (kDebugMode) print('Menu image upload failed: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final restaurantId = auth.user?.managedRestaurantId;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No restaurant associated with this account.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final menuRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu');

      if (widget.menuItemId != null) {
        final docRef = menuRef.doc(widget.menuItemId);
        String? imageUrl = _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null;
        if (_pickedImage != null) {
          final uploaded = await _uploadImage(restaurantId, widget.menuItemId!);
          if (uploaded != null) {
            imageUrl = uploaded;
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed — item saved without image (you can retry in edit).')));
          }
        }
        await docRef.update({
          'item_name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'image_url': imageUrl,
          'category': _categoryController.text.trim(),
          'availability_status': _isAvailable,
          'preparation_time': _prepTime,
          'updatedAt': Timestamp.now(),
        });
      } else {
        final doc = await menuRef.add({
          'item_name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'image_url': null,
          'category': _categoryController.text.trim(),
          'availability_status': _isAvailable,
          'preparation_time': _prepTime,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        String? imageUrl = _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null;
        if (_pickedImage != null) {
          if (kDebugMode) print('Attempting to upload image for new menu doc ${doc.id} (restaurant: $restaurantId)');
          final uploaded = await _uploadImage(restaurantId, doc.id);
          if (uploaded != null) {
            imageUrl = uploaded;
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed — item saved without image (you can edit to retry).')));
          }
        }

        await doc.update({
          'menu_id': doc.id,
          'image_url': imageUrl,
          'updatedAt': Timestamp.now(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu item saved.')));
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) print('Firestore operation failed: ${e.code} - ${e.message}');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed: ${e.code}')));
    } catch (e) {
      if (kDebugMode) print('Unexpected error saving menu item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.menuItemId != null) {
      _loadExistingItem();
    }
  }

  Future<void> _loadExistingItem() async {
    final auth = context.read<AuthProvider>();
    final restaurantId = auth.user?.managedRestaurantId;
    if (restaurantId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(widget.menuItemId)
          .get();

      if (!doc.exists) return;
      final data = doc.data()!;

      setState(() {
        _nameController.text = data['item_name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _priceController.text = (data['price'] ?? '').toString();
        _categoryController.text = data['category'] ?? 'Main';
        _imageUrlController.text = data['image_url'] ?? '';
        _existingImageUrl = data['image_url'] ?? '';
        _prepTime = data['preparation_time'] ?? 15;
        _isAvailable = data['availability_status'] ?? true;
      });
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Failed to load menu item ${widget.menuItemId} for restaurant $restaurantId. User: ${auth.user?.id}. Code: ${e.code}. Message: ${e.message}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot load menu item: ${e.message ?? e.code}')));
      }
      return;
    } catch (e) {
      if (kDebugMode) print('Unexpected error loading menu item: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItemId != null ? 'Edit Menu Item' : 'Add Menu Item'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Item Name',
                hint: 'e.g., Margherita Pizza',
                validator: (v) => (v == null || v.isEmpty) ? 'Enter item name' : null,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Short description',
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _priceController,
                label: 'Price',
                hint: '9.99',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final p = double.tryParse(v ?? '');
                  if (p == null) return 'Enter valid price';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'Main, Sides, Drinks',
              ),

              const SizedBox(height: 12),

              Text('Image (optional)', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_pickedImage != null) ...[
                    Image.file(File(_pickedImage!.path), width: 96, height: 96, fit: BoxFit.cover),
                  ] else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) ...[
                    Image.network(_existingImageUrl!, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 96, height: 96, color: AppColors.backgroundColor)),
                  ] else ...[
                    Container(width: 96, height: 96, color: AppColors.backgroundColor, child: const Icon(Icons.fastfood, size: 40)),
                  ],
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo),
                          label: const Text('Select Image'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: 140,
                        child: Text('Or paste an image URL below', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _imageUrlController,
                label: 'Image URL (optional)',
                hint: 'https://...',
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text('Prep time (min):'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _prepTime,
                    items: [10,15,20,25,30,40,45].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _prepTime = v);
                    },
                  ),
                  const Spacer(),
                  const Text('Available'),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              CustomButton(
                onPressed: _isSaving ? null : _handleSave,
                text: 'Add Item',
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
