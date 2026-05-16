import 'dart:async';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';
import 'socket_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  StreamSubscription<Map<String, Object>>? _subscription;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    final granted = await requestPermission();
    if (!granted) return;

    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.setApiKey(AppConstants.amapAndroidKey, AppConstants.amapIosKey);

    _locationPlugin.setLocationOption(AMapLocationOption(
      onceLocation: false,
      needAddress: true,
      locationInterval: AppConstants.locationUpdateInterval.inMilliseconds,
      locationMode: AMapLocationMode.Hight_Accuracy,
    ));

    _subscription = _locationPlugin.onLocationChanged().listen((result) {
      final lat = result['latitude'] as double?;
      final lng = result['longitude'] as double?;
      if (lat == null || lng == null) return;

      final speed = (result['speed'] as double?) ?? 0.0;
      final heading = (result['bearing'] as double?) ?? 0.0;
      final accuracy = (result['accuracy'] as double?) ?? 0.0;
      final address = result['address'] as String? ?? '';

      SocketService().sendLocation(
        latitude: lat,
        longitude: lng,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
        address: address,
      );
    });

    _locationPlugin.startLocation();
    _isTracking = true;
  }

  void stopTracking() {
    _locationPlugin.stopLocation();
    _subscription?.cancel();
    _subscription = null;
    _isTracking = false;
  }

  void dispose() {
    stopTracking();
    _locationPlugin.destroy();
  }
}
