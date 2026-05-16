import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/location_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> init() async {
    _api.init();
    final token = await _storage.read(key: 'token');
    if (token == null) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }

    _api.setToken(token);
    try {
      final data = await _api.getMe();
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      _state = AuthState.authenticated;
      _connectSocket(token);
    } catch (_) {
      await _storage.delete(key: 'token');
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register(String phone, String password, String nickname) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.register(phone, password, nickname);
      await _handleAuthSuccess(data);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.login(phone, password);
      await _handleAuthSuccess(data);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    LocationService().stopTracking();
    SocketService().disconnect();
    await _storage.delete(key: 'token');
    _api.clearToken();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void updateUserFamily(String? familyId) {
    if (_user == null) return;
    _user = _user!.copyWith(familyId: familyId);
    notifyListeners();
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.write(key: 'token', value: token);
    _api.setToken(token);
    _state = AuthState.authenticated;
    _connectSocket(token);
    notifyListeners();
  }

  void _connectSocket(String token) {
    SocketService().connect(token);
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('409')) return '该手机号已注册';
      if (msg.contains('401')) return '手机号或密码错误';
      if (msg.contains('400')) return '请检查输入内容';
      if (msg.contains('SocketException') || msg.contains('connection')) return '网络连接失败';
    }
    return '操作失败，请重试';
  }
}
