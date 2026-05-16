import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';
import '../models/location_model.dart';

typedef LocationCallback = void Function(String userId, LocationModel location);
typedef OnlineStatusCallback = void Function(String userId, bool isOnline, DateTime? lastSeen);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  LocationCallback? onLocationUpdated;
  OnlineStatusCallback? onMemberStatusChanged;
  Function(List<dynamic>)? onLocationsInit;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.on('locations:init', (data) {
      onLocationsInit?.call(data as List<dynamic>);
    });

    _socket!.on('location:updated', (data) {
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String;
        final location = LocationModel.fromJson(data);
        onLocationUpdated?.call(userId, location);
      }
    });

    _socket!.on('member:online', (data) {
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String;
        final isOnline = data['isOnline'] as bool;
        final lastSeenStr = data['lastSeen'] as String?;
        final lastSeen = lastSeenStr != null ? DateTime.parse(lastSeenStr) : null;
        onMemberStatusChanged?.call(userId, isOnline, lastSeen);
      }
    });

    _socket!.connect();
  }

  void sendLocation({
    required double latitude,
    required double longitude,
    double speed = 0,
    double heading = 0,
    double accuracy = 0,
    String address = '',
  }) {
    if (!isConnected) return;
    _socket!.emit('location:update', {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'address': address,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
