import 'location_model.dart';

class UserModel {
  final String id;
  final String phone;
  final String nickname;
  final String avatar;
  final String? familyId;
  final bool isOnline;
  final DateTime? lastSeen;
  LocationModel? location;

  UserModel({
    required this.id,
    required this.phone,
    required this.nickname,
    required this.avatar,
    this.familyId,
    this.isOnline = false,
    this.lastSeen,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      phone: json['phone'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      familyId: json['familyId'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : null,
    );
  }

  UserModel copyWith({
    String? nickname,
    String? avatar,
    String? familyId,
    bool? isOnline,
    DateTime? lastSeen,
    LocationModel? location,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      familyId: familyId ?? this.familyId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
    );
  }
}
