class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final String cuisineType;
  final String imageUrl;
  final String? logoUrl;
  final double deliveryFee;
  final int deliveryTime;
  final double? distance;
  final bool isOpen;
  final List<String> tags;
  final Location location;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.cuisineType,
    required this.imageUrl,
    this.logoUrl,
    required this.deliveryFee,
    required this.deliveryTime,
    this.distance,
    required this.isOpen,
    required this.tags,
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['restaurant_id'],
      name: json['name'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      cuisineType: json['cuisine_type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      logoUrl: json['logo_url'],
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      deliveryTime: json['delivery_time'] ?? 30,
      distance: json['distance']?.toDouble(),
      isOpen: json['is_open'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] != null ? Location.fromJson(json['location']) : Location(latitude: 0, longitude: 0),
    );
  }

  factory Restaurant.fromFirestore(Map<String, dynamic> json, String docId) {
    return Restaurant(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      cuisineType: json['cuisine_type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      logoUrl: json['logo_url'],
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      deliveryTime: json['delivery_time'] ?? 30,
      distance: json['distance']?.toDouble(),
      isOpen: json['is_open'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] != null ? Location.fromJson(Map<String, dynamic>.from(json['location'])) : Location(latitude: 0, longitude: 0),
    );
  }

  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedDeliveryFee => deliveryFee == 0 ? 'Free' : '\$${deliveryFee.toStringAsFixed(2)}';
  String get formattedDeliveryTime => '$deliveryTime min';
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}