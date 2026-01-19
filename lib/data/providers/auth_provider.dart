import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food2/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null) {
          _loadUserFromFirebase(firebaseUser);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }

  Future<void> _loadUserFromFirebase(User firebaseUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final roleStr = (userData['role'] as String?) ?? 'user';
        final role = roleStr.toLowerCase() == 'admin' ? AuthRole.admin : AuthRole.user;

        _user = UserModel(
          id: firebaseUser.uid,
          name: userData['name'] ?? firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: userData['phone'] ?? '',
          profileImage: userData['profileImage'] ?? firebaseUser.photoURL,
          addresses: (userData['addresses'] as List<dynamic>?)
              ?.map((addr) => Address.fromJson(addr))
              .toList() ??
              [],
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          role: role,
          managedRestaurantId: userData['managedRestaurantId'] as String?,
        );
      } else {
        // Create new user in Firestore (default role: user)
        _user = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: '',
          profileImage: firebaseUser.photoURL,
          addresses: [],
          createdAt: DateTime.now(),
          role: AuthRole.user,
        );

        await _saveUserToFirestore(_user!);
      }

      _isAuthenticated = true;
      await _saveAuthData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user from Firebase: $e');
      }
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'profileImage': user.profileImage,
        'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
        'createdAt': Timestamp.fromDate(user.createdAt),
        'updatedAt': Timestamp.now(),
        'role': user.role.name,
        'managedRestaurantId': user.managedRestaurantId,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user to Firestore: $e');
      }
      rethrow;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // load full user data immediately
        await _loadUserFromFirebase(userCredential.user!);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthError(e);
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  /// Sign in and ensure the authenticated user has the required role.
  Future<bool> loginWithEmailAndRole(String email, String password, AuthRole requiredRole) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _error = 'Login failed';
        return false;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      final roleStr = (userDoc.data()?['role'] as String?) ?? 'user';
      final role = roleStr.toLowerCase() == 'admin' ? AuthRole.admin : AuthRole.user;

      if (role != requiredRole) {
        await FirebaseAuth.instance.signOut();
        _error = 'This account is not authorized as ${requiredRole.name}.';
        return false;
      }

      await _loadUserFromFirebase(firebaseUser);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthError(e);
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      if (kDebugMode) {
        print('Role login error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> signup(String name, String email, String password, String phone, {AuthRole role = AuthRole.user, String? restaurantName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        var user = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          profileImage: null,
          addresses: [],
          createdAt: DateTime.now(),
          role: role,
        );

        if (role == AuthRole.admin && restaurantName != null && restaurantName.isNotEmpty) {
          final restRef = await FirebaseFirestore.instance.collection('restaurants').add({
            'name': restaurantName,
            'ownerId': user.id,
            'description': '',
            'address': '',
            'phone': '',
            'rating': 0,
            'review_count': 0,
            'cuisine_type': '',
            'image_url': '',
            'delivery_fee': 0,
            'delivery_time': 30,
            'is_open': true,
            'tags': [],
            'location': {'latitude': 0, 'longitude': 0},
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });

          user = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            profileImage: user.profileImage,
            addresses: user.addresses,
            createdAt: user.createdAt,
            role: user.role,
            managedRestaurantId: restRef.id,
          );
        }

        await _saveUserToFirestore(user);
        _user = user;
        _isAuthenticated = true;
        await _saveAuthData();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthError(e);
      return false;
    } catch (e) {
      _error = 'Signup failed: ${e.toString()}';
      if (kDebugMode) {
        print('Signup error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        _error = 'Google sign in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _loadUserFromFirebase(userCredential.user!);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthError(e);
      return false;
    } catch (e) {
      _error = 'Google sign in failed: ${e.toString()}';
      if (kDebugMode) {
        print('Google sign in error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      await prefs.setBool('is_authenticated', true);
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }

    _user = null;
    _isAuthenticated = false;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('is_authenticated');

    notifyListeners();
  }

  String _getFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}