import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:food2/core/constants/app_colors.dart';
import 'package:food2/core/constants/app_styles.dart';
import 'package:food2/data/providers/auth_provider.dart';
import 'package:food2/models/restaurant_model.dart';

class EditRestaurantScreen extends StatefulWidget {
  const EditRestaurantScreen({super.key});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  Restaurant? _restaurant;

  // form fields
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _cuisineCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();

  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    final auth = context.read<AuthProvider>();
    final restId = auth.user?.managedRestaurantId;
    if (restId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('restaurants').doc(restId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final r = Restaurant.fromFirestore(data, doc.id);
        if (!mounted) return;
        setState(() {
          _restaurant = r;
          _nameCtrl.text = r.name;
          _descCtrl.text = r.description;
          _addressCtrl.text = r.address;
          _phoneCtrl.text = r.phone;
          _cuisineCtrl.text = r.cuisineType;
          _tagsCtrl.text = r.tags.join(', ');
          _latCtrl.text = r.location.latitude.toString();
          _lngCtrl.text = r.location.longitude.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading restaurant: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (file != null) {
      setState(() {
        _pickedImage = file;
      });
    }
  }

  Future<String?> _uploadImage(String restaurantId) async {
    if (_pickedImage == null) return _restaurant?.imageUrl;
    final path = 'restaurants/$restaurantId/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(File(_pickedImage!.path));
      await uploadTask.whenComplete(() {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final restId = auth.user?.managedRestaurantId;
    if (restId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No restaurant associated with this account')));
      return;
    }

    setState(() { _isSaving = true; });

    try {
      String? imageUrl = _restaurant?.imageUrl;
      if (_pickedImage != null) {
        final uploaded = await _uploadImage(restId);
        if (uploaded != null) imageUrl = uploaded;
      }

      final lat = double.tryParse(_latCtrl.text) ?? 0.0;
      final lng = double.tryParse(_lngCtrl.text) ?? 0.0;
      final tags = _tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      await FirebaseFirestore.instance.collection('restaurants').doc(restId).update({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'cuisine_type': _cuisineCtrl.text.trim(),
        'tags': tags,
        'location': {'latitude': lat, 'longitude': lng},
        'image_url': imageUrl ?? '',
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant updated')));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) print('Error saving restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save restaurant')));
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Restaurant'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: _restaurant == null ? Center(child: Text('No restaurant found for this account', style: AppStyles.titleLarge)) : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Info', style: AppStyles.headlineSmall),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Restaurant name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cuisineCtrl,
                  decoration: const InputDecoration(labelText: 'Cuisine Type'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Latitude'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _lngCtrl, decoration: const InputDecoration(labelText: 'Longitude'))),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Image', style: AppStyles.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_pickedImage != null) ...[
                      Image.file(File(_pickedImage!.path), width: 96, height: 96, fit: BoxFit.cover),
                    ] else if (_restaurant?.imageUrl != null && _restaurant!.imageUrl.isNotEmpty) ...[
                      Image.network(_restaurant!.imageUrl, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 96, height: 96, color: AppColors.backgroundColor)),
                    ] else ...[
                      Container(width: 96, height: 96, color: AppColors.backgroundColor, child: const Icon(Icons.restaurant, size: 40)),
                    ],
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Select Image')),
                        const SizedBox(height: 8),
                        Text('Tip: use a square image', style: AppStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving ? const CircularProgressIndicator() : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
