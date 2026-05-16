import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _familyNameCtrl = TextEditingController();
  final _inviteCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _familyNameCtrl.dispose();
    _inviteCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    if (!_createFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final family = context.read<FamilyProvider>();
    final success = await family.createFamily(_familyNameCtrl.text.trim(), auth);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(family.errorMessage ?? '创建失败'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _joinFamily() async {
    if (!_joinFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final family = context.read<FamilyProvider>();
    final success = await family.joinFamily(_inviteCodeCtrl.text.trim().toUpperCase(), auth);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(family.errorMessage ?? '加入失败'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FamilyProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('加入家庭'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('退出登录', style: TextStyle(color: Colors.white)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: '创建家庭'), Tab(text: '加入家庭')],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create family tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _createFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.family_restroom, size: 64, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                  const Text('创建您的家庭群组', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('创建后会生成邀请码，分享给家人即可加入', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _familyNameCtrl,
                    decoration: const InputDecoration(
                      labelText: '家庭名称',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '例如：王家、李家',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '请输入家庭名称' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _createFamily,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('创建家庭', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),

          // Join family tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _joinFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.group_add, size: 64, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                  const Text('加入家庭群组', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('请向家庭创建者索取6位邀请码', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _inviteCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: '邀请码（6位）',
                      prefixIcon: Icon(Icons.vpn_key),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'XXXXXX',
                    ),
                    style: const TextStyle(letterSpacing: 4, fontSize: 18),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '请输入邀请码';
                      if (v.trim().length != 6) return '邀请码为6位';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _joinFamily,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('加入家庭', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
