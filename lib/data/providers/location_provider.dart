import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:food2/models/user_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  Address? _currentAddress;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Position>? _positionStream;

  Position? get currentPosition => _currentPosition;
  Address? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _notify() => Future.microtask(() => notifyListeners());

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    _notify();

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          _isLoading = false;
          _notify();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied, please enable them in app settings';
        _isLoading = false;
        _notify();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      await _getAddressFromLatLng();

    } catch (e) {
      _error = 'Failed to get location: ${e.toString()}';
      if (kDebugMode) {
        print('Location error: $e');
      }
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (_currentPosition == null) return;

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = Address(
          id: 'current',
          title: 'Current Location',
          addressLine1: placemark.street ?? '',
          addressLine2: '',
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          zipCode: placemark.postalCode ?? '',
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          isDefault: true,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Geocoding error: $e');
      }
    }
  }

  void setAddress(Address address) {
    _currentAddress = address;
    _currentPosition = Position(
      longitude: address.longitude,
      latitude: address.latitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    _notify();
  }

  Future<double> calculateDistance(double lat, double lng) async {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    ) / 1000;
  }

  void startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _notify();
    });
  }

  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<bool> isWithinDeliveryRadius(double restaurantLat, double restaurantLng, double radiusKm) async {
    if (_currentPosition == null) return false;

    final distance = await calculateDistance(restaurantLat, restaurantLng);
    return distance <= radiusKm;
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}