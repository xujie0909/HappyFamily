import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/time_utils.dart';

class MemberInfoCard extends StatelessWidget {
  final UserModel member;
  final bool isMe;
  final VoidCallback onClose;

  const MemberInfoCard({
    super.key,
    required this.member,
    required this.isMe,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final loc = member.location;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isMe ? const Color(0xFF4CAF50) : const Color(0xFF1565C0),
              child: Text(
                member.nickname.isNotEmpty ? member.nickname[0] : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        isMe ? '${member.nickname}（我）' : member.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: member.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (loc != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      loc.speedText,
                      style: TextStyle(
                        color: loc.speed > 1 ? const Color(0xFF4CAF50) : Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (loc.address.isNotEmpty)
                      Text(
                        loc.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '更新于 ${TimeUtils.formatRelative(loc.updatedAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ] else
                    const Text('暂无位置信息', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
