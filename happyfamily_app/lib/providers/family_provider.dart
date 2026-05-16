import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../models/user_model.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'auth_provider.dart';

class FamilyProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  FamilyModel? _family;
  bool _isLoading = false;
  String? _errorMessage;

  FamilyModel? get family => _family;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFamily => _family != null;

  List<UserModel> get members => _family?.members ?? [];

  void _setupSocketListeners() {
    SocketService().onLocationUpdated = (userId, location) {
      _updateMemberLocation(userId, location);
    };
    SocketService().onMemberStatusChanged = (userId, isOnline, lastSeen) {
      _updateMemberStatus(userId, isOnline, lastSeen);
    };
    SocketService().onLocationsInit = (locationsData) {
      for (final item in locationsData) {
        if (item is Map<String, dynamic>) {
          final userId = item['userId'] as String;
          final location = LocationModel.fromJson(item);
          _updateMemberLocation(userId, location);
        }
      }
    };
  }

  Future<void> loadFamily() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.getMyFamily();
      _family = FamilyModel.fromJson(data['family'] as Map<String, dynamic>);
      _setupSocketListeners();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404')) {
        _family = null;
      } else {
        _errorMessage = '加载家庭信息失败';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createFamily(String name, AuthProvider authProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.createFamily(name);
      _family = FamilyModel.fromJson(data['family'] as Map<String, dynamic>);
      authProvider.updateUserFamily(_family!.id);
      _setupSocketListeners();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '创建家庭失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinFamily(String inviteCode, AuthProvider authProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.joinFamily(inviteCode);
      _family = FamilyModel.fromJson(data['family'] as Map<String, dynamic>);
      authProvider.updateUserFamily(_family!.id);
      _setupSocketListeners();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404')) {
        _errorMessage = '邀请码无效';
      } else if (msg.contains('400')) {
        _errorMessage = '您已加入家庭';
      } else {
        _errorMessage = '加入家庭失败';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveFamily(AuthProvider authProvider) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.leaveFamily();
      _family = null;
      authProvider.updateUserFamily(null);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _updateMemberLocation(String userId, LocationModel location) {
    if (_family == null) return;
    final idx = _family!.members.indexWhere((m) => m.id == userId);
    if (idx == -1) return;
    final updated = _family!.members[idx].copyWith(location: location, isOnline: true);
    final newMembers = List<UserModel>.from(_family!.members);
    newMembers[idx] = updated;
    _family = FamilyModel(
      id: _family!.id,
      name: _family!.name,
      inviteCode: _family!.inviteCode,
      creatorId: _family!.creatorId,
      members: newMembers,
    );
    notifyListeners();
  }

  void _updateMemberStatus(String userId, bool isOnline, DateTime? lastSeen) {
    if (_family == null) return;
    final idx = _family!.members.indexWhere((m) => m.id == userId);
    if (idx == -1) return;
    final updated = _family!.members[idx].copyWith(isOnline: isOnline, lastSeen: lastSeen);
    final newMembers = List<UserModel>.from(_family!.members);
    newMembers[idx] = updated;
    _family = FamilyModel(
      id: _family!.id,
      name: _family!.name,
      inviteCode: _family!.inviteCode,
      creatorId: _family!.creatorId,
      members: newMembers,
    );
    notifyListeners();
  }
}
