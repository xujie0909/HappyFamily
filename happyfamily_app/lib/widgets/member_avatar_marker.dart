import 'package:flutter/material.dart';
import '../models/user_model.dart';

class MemberAvatarMarker extends StatelessWidget {
  final UserModel member;
  final bool isSelected;
  final bool isMe;
  final VoidCallback onTap;

  const MemberAvatarMarker({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = member.location != null;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMe ? const Color(0xFF4CAF50) : const Color(0xFF1565C0),
                    border: isSelected
                        ? Border.all(color: const Color(0xFFFF6F00), width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [const BoxShadow(color: Colors.orange, blurRadius: 8)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      member.nickname.isNotEmpty ? member.nickname[0] : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: member.isOnline ? Colors.green : Colors.grey,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 52,
              child: Text(
                isMe ? '我' : member.nickname,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: hasLocation ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
