import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final family = context.watch<FamilyProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        children: [
          // Profile section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4CAF50),
                  child: Text(
                    user?.nickname.isNotEmpty == true ? user!.nickname[0] : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.nickname ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user?.phone ?? '', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Family section
          if (family.hasFamily) ...[
            _SectionHeader(title: '我的家庭'),
            _SettingsTile(
              icon: Icons.home,
              title: family.family!.name,
              subtitle: '家庭名称',
            ),
            _SettingsTile(
              icon: Icons.group,
              title: '${family.members.length} 位成员',
              subtitle: '家庭成员',
            ),
            _SettingsTile(
              icon: Icons.vpn_key,
              title: family.family!.inviteCode,
              subtitle: '邀请码（点击复制）',
              onTap: () {
                // handled in map screen
              },
            ),
            _SettingsTile(
              icon: Icons.exit_to_app,
              title: '退出家庭',
              titleColor: Colors.red,
              onTap: () => _confirmLeaveFamily(context),
            ),
          ],

          const SizedBox(height: 12),

          // Account section
          _SectionHeader(title: '账号'),
          _SettingsTile(
            icon: Icons.logout,
            title: '退出登录',
            titleColor: Colors.red,
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmLeaveFamily(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出家庭'),
        content: const Text('退出后将无法看到家庭成员的位置，确定退出吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              await context.read<FamilyProvider>().leaveFamily(auth);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? const Color(0xFF4CAF50)),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
        trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
      ),
    );
  }
}
