import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../widgets/member_avatar_marker.dart';
import '../widgets/member_info_card.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  AMapController? _mapController;
  UserModel? _selectedMember;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Permission.locationWhenInUse.request();
      context.read<FamilyProvider>().loadFamily();
    });
  }

  void _onMapCreated(AMapController controller) {
    _mapController = controller;
  }

  void _centerOnMember(UserModel member) {
    if (member.location == null || _mapController == null) return;
    _mapController!.moveCamera(
      CameraUpdate.newLatLng(LatLng(member.location!.latitude, member.location!.longitude)),
    );
    setState(() => _selectedMember = member);
  }

  void _centerOnAllMembers(List<UserModel> members) {
    final withLocation = members.where((m) => m.location != null).toList();
    if (withLocation.isEmpty || _mapController == null) return;

    if (withLocation.length == 1) {
      _centerOnMember(withLocation.first);
      return;
    }

    double minLat = withLocation.first.location!.latitude;
    double maxLat = minLat;
    double minLng = withLocation.first.location!.longitude;
    double maxLng = minLng;

    for (final m in withLocation) {
      minLat = minLat < m.location!.latitude ? minLat : m.location!.latitude;
      maxLat = maxLat > m.location!.latitude ? maxLat : m.location!.latitude;
      minLng = minLng < m.location!.longitude ? minLng : m.location!.longitude;
      maxLng = maxLng > m.location!.longitude ? maxLng : m.location!.longitude;
    }

    _mapController!.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        100,
      ),
    );
  }

  Set<Marker> _buildMarkers(List<UserModel> members, String? myId) {
    return members
        .where((m) => m.location != null && m.id != myId)
        .map<Marker>((m) => Marker(
              position: LatLng(m.location!.latitude, m.location!.longitude),
              infoWindow: InfoWindow(title: m.nickname, snippet: m.location!.speedText),
              onTap: (_) => setState(() => _selectedMember = m),
            ))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final familyProvider = context.watch<FamilyProvider>();
    final family = familyProvider.family;
    final members = familyProvider.members;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map
          AMapWidget(
            apiKey: const AMapApiKey(
              androidKey: '66abd2c63b7fce84b61c4de51370ad03',
            ),
            privacyStatement: const AMapPrivacyStatement(
              hasContains: true,
              hasShow: true,
              hasAgree: true,
            ),
            onMapCreated: _onMapCreated,
            markers: _buildMarkers(members, auth.user?.id),
            myLocationStyleOptions: MyLocationStyleOptions(true),
            onLocationChanged: (location) {
              if (location.latLng.latitude == 0.0 && location.latLng.longitude == 0.0) return;
              SocketService().sendLocation(
                latitude: location.latLng.latitude,
                longitude: location.latLng.longitude,
                speed: location.speed,
                heading: location.bearing,
                accuracy: location.accuracy,
                address: '',
              );
            },
          ),

          // Top app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.home_filled, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          family?.name ?? 'HappyFamily',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (family != null)
                        IconButton(
                          icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                          onPressed: () => _centerOnAllMembers(members),
                          tooltip: '查看全部成员',
                        ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom member list
          if (family != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected member info card
                  if (_selectedMember != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MemberInfoCard(
                        member: _selectedMember!,
                        isMe: _selectedMember!.id == auth.user?.id,
                        onClose: () => setState(() => _selectedMember = null),
                      ),
                    ),

                  // Horizontal scrollable member avatars
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: members.length,
                          itemBuilder: (_, i) {
                            final m = members[i];
                            final isSelected = _selectedMember?.id == m.id;
                            final isMe = m.id == auth.user?.id;
                            return MemberAvatarMarker(
                              member: m,
                              isSelected: isSelected,
                              isMe: isMe,
                              onTap: () => _centerOnMember(m),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Invite code button
          if (family != null)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton.small(
                heroTag: 'invite',
                backgroundColor: Colors.white,
                onPressed: () => _showInviteCode(context, family.inviteCode),
                child: const Icon(Icons.share, color: Color(0xFF4CAF50)),
              ),
            ),
        ],
      ),
    );
  }

  void _showInviteCode(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('邀请码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('将此邀请码分享给家人：', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('邀请码已复制')),
              );
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
