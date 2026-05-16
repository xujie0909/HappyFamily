import 'user_model.dart';

class FamilyModel {
  final String id;
  final String name;
  final String inviteCode;
  final String creatorId;
  final List<UserModel> members;

  FamilyModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.creatorId,
    required this.members,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    return FamilyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      inviteCode: json['inviteCode'] ?? '',
      creatorId: json['creatorId'] ?? '',
      members: membersJson.map((m) => UserModel.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }
}
