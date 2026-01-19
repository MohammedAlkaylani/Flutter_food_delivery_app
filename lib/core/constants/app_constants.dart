class AppConstants {
  static const String apiBaseUrl = 'https://api.quickbite.com/v1';
  static const String apiTimeout = '30s';
  static const int apiMaxRetries = 3;

  static const String appName = 'QuickBite';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  static const String restaurantsEndpoint = '/restaurants';
  static const String restaurantDetailEndpoint = '/restaurants/:id';
  static const String restaurantMenuEndpoint = '/restaurants/:id/menu';

  static const String ordersEndpoint = '/orders';
  static const String orderDetailEndpoint = '/orders/:id';
  static const String orderHistoryEndpoint = '/orders/history';
  static const String orderCancelEndpoint = '/orders/:id/cancel';

  static const String cartEndpoint = '/cart';
  static const String cartAddItemEndpoint = '/cart/items';
  static const String cartUpdateItemEndpoint = '/cart/items/:id';
  static const String cartRemoveItemEndpoint = '/cart/items/:id';

  static const String addressesEndpoint = '/addresses';
  static const String paymentMethodsEndpoint = '/payment-methods';
  static const String createPaymentEndpoint = '/payments/create';

  static const String reviewsEndpoint = '/reviews';
  static const String submitReviewEndpoint = '/reviews/:order_id';

  static const String webSocketUrl = 'wss://api.quickbite.com/ws';
  static const int webSocketReconnectInterval = 5000; // 5 seconds

  static const int defaultPageSize = 20;
  static const int restaurantPageSize = 10;
  static const int menuPageSize = 50;
  static const int orderHistoryPageSize = 10;

  static const int cacheDuration = 300; // 5 minutes in seconds
  static const int imageCacheDuration = 604800; // 7 days in seconds
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB

  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;
  static const double defaultDeliveryRadius = 10.0; // 10 km
  static const int locationUpdateInterval = 10000; // 10 seconds

  static const double defaultDeliveryFee = 2.99;
  static const double defaultServiceFee = 1.99;
  static const double taxRate = 0.08; // 8%
  static const int estimatedPreparationTime = 20; // minutes
  static const int orderExpirationTime = 900; // 15 minutes in seconds

  static const List<String> supportedPaymentMethods = [
    'card',
    'cash',
    'paypal',
    'apple_pay',
    'google_pay'
  ];
  static const String currency = 'USD';
  static const String currencySymbol = '\$';

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration debounceDuration = Duration(milliseconds: 500);

  static const bool enablePushNotifications = true;
  static const bool enableLocationTracking = true;
  static const bool enableSocialLogin = true;
  static const bool enableGuestCheckout = true;
  static const bool enableMultipleAddresses = true;
  static const bool enableOrderScheduling = true;
  static const bool enableRatings = true;

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String cartDataKey = 'cart_data';
  static const String selectedAddressKey = 'selected_address';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String fcmTokenKey = 'fcm_token';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 200);

  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unauthorizedError = 'Session expired. Please login again';
  static const String timeoutError = 'Request timed out. Please try again';
  static const String unknownError = 'An unexpected error occurred';
  static const String locationError = 'Unable to get location. Please enable location services';
  static const String cartEmptyError = 'Your cart is empty';
  static const String paymentError = 'Payment failed. Please try again';

  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String orderSuccess = 'Order placed successfully';
  static const String paymentSuccess = 'Payment successful';
  static const String reviewSuccess = 'Thank you for your review';

  static const String defaultProfileImage =
      'https://ui-avatars.com/api/?name=Guest&background=FF6B35&color=fff';
  static const String defaultRestaurantImage =
      'https://picsum.photos/400/300?restaurant';
  static const String defaultMenuItemImage =
      'https://picsum.photos/200/150?food';

  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const double mapZoomLevel = 15.0;
  static const double mapPadding = 50.0;

  static const String orderChannelId = 'order_notifications';
  static const String orderChannelName = 'Order Updates';
  static const String orderChannelDescription = 'Notifications for order status updates';

  static const String promotionChannelId = 'promotion_notifications';
  static const String promotionChannelName = 'Promotions';
  static const String promotionChannelDescription = 'Special offers and promotions';

  static const String facebookUrl = 'https://facebook.com/quickbite';
  static const String instagramUrl = 'https://instagram.com/quickbite';
  static const String twitterUrl = 'https://twitter.com/quickbite';
  static const String supportEmail = 'support@quickbite.com';
  static const String privacyPolicyUrl = 'https://quickbite.com/privacy';
  static const String termsOfServiceUrl = 'https://quickbite.com/terms';

  static const String appStoreUrl = 'https://apps.apple.com/app/quickbite';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.quickbite';

  static const String demoEmail = 'demo@quickbite.com';
  static const String demoPassword = 'demo123';
}