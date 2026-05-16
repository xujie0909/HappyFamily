class AppConstants {
  // Change to your server IP/domain in production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String socketUrl = 'http://10.0.2.2:3000';

  static const String amapAndroidKey = '66abd2c63b7fce84b61c4de51370ad03';
  static const String amapIosKey = 'YOUR_AMAP_IOS_KEY';

  static const Duration locationUpdateInterval = Duration(seconds: 5);
}

class AppColors {
  static const primary = 0xFF4CAF50;
  static const primaryDark = 0xFF388E3C;
  static const accent = 0xFF66BB6A;
  static const background = 0xFFF5F5F5;
  static const surface = 0xFFFFFFFF;
  static const error = 0xFFF44336;
  static const textPrimary = 0xFF212121;
  static const textSecondary = 0xFF757575;
}
