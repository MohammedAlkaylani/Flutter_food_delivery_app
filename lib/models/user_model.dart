enum AuthRole { user, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<Address> addresses;
  final DateTime createdAt;
  final AuthRole role;
  final String? managedRestaurantId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.addresses,
    required this.createdAt,
    this.role = AuthRole.user,
    this.managedRestaurantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleString = (json['role'] as String?) ?? 'user';
    final role = roleString.toLowerCase() == 'admin' ? AuthRole.admin : AuthRole.user;

    return UserModel(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image_url'],
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((address) => Address.fromJson(address))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      role: role,
      managedRestaurantId: json['managedRestaurantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImage,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'role': role.name,
      'managedRestaurantId': managedRestaurantId,
    };
  }
}

class Address {
  final String id;
  final String title;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isDefault: json['is_default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? title,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress {
    return '$addressLine1, $addressLine2, $city, $state $zipCode';
  }
}