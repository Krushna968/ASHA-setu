import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _workerName = 'Loading...';
  String _employeeId = '...';
  String _village = 'Loading Data...';
  String _lastSyncTime = 'JUST NOW';
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final stats = await ApiService.get('/worker/stats');
      if (mounted && !stats.containsKey('error')) {
        setState(() {
          _workerName = stats['name'] ?? 'ASHA Worker';
          _employeeId = stats['employeeId'] ?? 'Unknown ID';
          _village = stats['village'] ?? 'Local Village';
          _profileImageUrl = stats['profileImage'];
          _lastSyncTime = DateFormat('hh:mm a').format(DateTime.now());
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return; // User canceled

    setState(() => _isUploadingImage = true);

    try {
      // Send directly to Postgres Backend via Multipart
      final response = await ApiService.postMultipart(
        '/worker/update-profile', 
        pickedFile.path, 
        'profileImage'
      );
      
      if (!response.containsKey('error')) {
        setState(() {
          _profileImageUrl = response['profileImage'];
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated successfully!', style: TextStyle(color: Colors.white)), backgroundColor: MyTheme.successGreen));
        }
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      debugPrint('UPLOAD ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString()}', maxLines: 3, overflow: TextOverflow.ellipsis), 
          backgroundColor: MyTheme.criticalRed,
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Worker Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: MyTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: MyTheme.textDark, size: 28),
                onPressed: () {},
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: MyTheme.criticalRed, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildCoverageCard(),
            const SizedBox(height: 24),
            _buildSectionLabel('ACCOUNT SETTINGS'),
            const SizedBox(height: 8),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.translate,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: MyTheme.primaryBlue,
                title: 'Language Change',
                subtitle: 'Hindi (हिन्दी)',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.cloud_off,
                iconBg: const Color(0xFFFFEFEF),
                iconColor: MyTheme.criticalRed,
                title: 'Offline Settings',
                subtitle: 'Sync data & storage management',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionLabel('SUPPORT'),
            const SizedBox(height: 8),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.help_outline,
                iconBg: const Color(0xFFF5F5F5),
                iconColor: Colors.grey.shade600,
                title: 'Help & Support',
                subtitle: null,
                showArrow: false,
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.info_outline,
                iconBg: const Color(0xFFF5F5F5),
                iconColor: Colors.grey.shade600,
                title: 'About App v2.4.0',
                subtitle: null,
                showArrow: false,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDE8FF), width: 4),
                color: const Color(0xFF77B5D9),
              ),
              child: ClipOval(
                child: _profileImageUrl != null
                    ? Image.network(_profileImageUrl!, fit: BoxFit.cover, width: 110, height: 110,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 64, color: Colors.white))
                    : const Icon(Icons.person, size: 64, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _isUploadingImage ? null : _pickAndUploadImage,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _isUploadingImage ? Colors.grey : MyTheme.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isUploadingImage 
                    ? const Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _workerName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MyTheme.textDark),
        ),
        const SizedBox(height: 4),
        Text(
          'ASHA ID: $_employeeId',
          style: const TextStyle(fontSize: 14, color: MyTheme.primaryBlue, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1FAE5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: MyTheme.successGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                'SYNCED: $_lastSyncTime',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: MyTheme.successGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE8FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AREA OF COVERAGE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.8),
                ),
                const SizedBox(height: 2),
                Text(
                  _village.toUpperCase(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyTheme.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final bool isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: MyTheme.textDark),
                ),
                subtitle: item.subtitle != null
                    ? Text(item.subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
                    : null,
                trailing: item.showArrow
                    ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
                    : null,
              ),
              if (!isLast)
                Divider(height: 1, indent: 72, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Are you sure you want to logout from the system?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: MyTheme.criticalRed),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                    }
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: MyTheme.criticalRed, size: 20),
        label: const Text(
          'Logout from System',
          style: TextStyle(color: MyTheme.criticalRed, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFCDD2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFFFF5F5),
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.showArrow = true,
    required this.onTap,
  });
}
