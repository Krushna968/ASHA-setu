import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../providers/area_map_provider.dart';
import '../providers/app_state_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _workerName = 'Krushna Rasal';
  String _employeeId = 'ASHA-2024-089';
  String _village = 'Airoli Sector 4, Navi Mumbai';
  int _totalHouses = 42;
  String _lastSyncTime = 'JUST NOW';
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  bool _isSyncing = false;
  
  // Stats variables (mapped from /worker/stats)
  int _completedToday = 0;
  int _targetToday = 0;
  int _highRiskCount = 0;

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
          
          _completedToday = stats['completedToday'] ?? 0;
          _targetToday = stats['targetToday'] ?? 8;
          _highRiskCount = stats['highRiskCount'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Load Error: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString()}'), 
          backgroundColor: MyTheme.criticalRed,
        ));
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(),
            Transform.translate(
              offset: const Offset(0, -15), // Reduced negative offset to prevent overlap
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildCoveragePremium(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('ACCOUNT MANAGEMENT'),
                    const SizedBox(height: 12),
                    _buildSettingsList([
                      _SettingItem(
                        icon: Icons.language_rounded,
                        bg: Colors.blue.shade50,
                        color: Colors.blue.shade700,
                        title: 'Change Language',
                        subtitle: 'Select your preferred language',
                        onTap: () => _showLanguageSelector(context),
                      ),
                      _SettingItem(
                        icon: Icons.cloud_sync_rounded,
                        bg: Colors.teal.shade50,
                        color: Colors.teal.shade700,
                        title: 'Sync Now',
                        subtitle: _isSyncing ? 'Syncing...' : 'Last synced: $_lastSyncTime',
                        trailing: _isSyncing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                        onTap: _isSyncing ? null : _handleManualSync,
                      ),
                      _SettingItem(
                        icon: Icons.notifications_active_outlined,
                        bg: Colors.orange.shade50,
                        color: Colors.orange.shade700,
                        title: 'Push Notifications',
                        subtitle: 'Manage app permissions',
                        onTap: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('SUPPORT & INFO'),
                    const SizedBox(height: 12),
                    _buildSettingsList([
                      _SettingItem(
                        icon: Icons.help_center_outlined,
                        bg: Colors.grey.shade100,
                        color: Colors.grey.shade700,
                        title: 'Help & Support Center',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.verified_user_outlined,
                        bg: Colors.grey.shade100,
                        color: Colors.grey.shade700,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.info_outline_rounded,
                        bg: Colors.grey.shade100,
                        color: Colors.grey.shade700,
                        title: 'App Version 2.10.4',
                        showArrow: false,
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 40),
                    _buildPremiumLogout(context),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MyTheme.primaryBlue, Color(0xFF1565C0)],
        ),
        // Removed bottom border radius to make it square shaped
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Clean Solid Border Ring
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // Profile Photo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyTheme.primaryBlue.withOpacity(0.1),
                    ),
                    child: ClipOval(
                      child: _profileImageUrl != null
                          ? Image.network(_profileImageUrl!, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 50, color: MyTheme.primaryBlue.withOpacity(0.5)))
                          : Icon(Icons.person, size: 50, color: MyTheme.primaryBlue.withOpacity(0.5)),
                    ),
                  ),
                  // Edit Button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: _isUploadingImage 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt_rounded, size: 18, color: MyTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              child: Column(
                children: [
                  Text(
                    _workerName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: $_employeeId',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Added buffer space to prevent card overlap
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Tasks', '$_completedToday', Icons.task_alt_rounded, Colors.green),
            _buildStatItem('Target', '$_targetToday', Icons.flag_rounded, Colors.blue),
            _buildStatItem('High Risk', '$_highRiskCount', Icons.warning_amber_rounded, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark)),
        Text(label, style: TextStyle(fontSize: 11, color: MyTheme.textLight, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCoveragePremium() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=Airoli+Sector+4+Navi+Mumbai+boundary');
          if (!await launchUrl(url)) {
            debugPrint('Could not launch map');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyTheme.primaryBlue,
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
              opacity: 0.1,
            ),
            boxShadow: [
              BoxShadow(color: MyTheme.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.map_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AREA OF COVERAGE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(_village, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('$_totalHouses Houses Assigned', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsList(List<_SettingItem> items) {
    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          children: items.map((item) {
            final isLast = item == items.last;
            return Column(
              children: [
                ListTile(
                  onTap: item.onTap,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  trailing: item.trailing ?? (item.showArrow ? const Icon(Icons.arrow_forward_ios_rounded, size: 14) : null),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                if (!isLast) const Divider(indent: 70, height: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPremiumLogout(BuildContext context) {
    return FadeInUp(
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10)],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('Log Out From System'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF5F5),
            foregroundColor: MyTheme.criticalRed,
            elevation: 0,
            side: BorderSide(color: MyTheme.criticalRed.withOpacity(0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);
    try {
      // Sync both providers
      await Future.wait([
        context.read<AreaMapProvider>().refreshArea(),
        context.read<AppStateProvider>().fetchAllData(),
      ]);
      if (mounted) {
        setState(() {
          _lastSyncTime = 'Just Now';
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data synced successfully!'), backgroundColor: MyTheme.successGreen)
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    ];

    final currentLocaleCode = context.read<AppStateProvider>().locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Change Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final bool isCurrent = lang['code'] == currentLocaleCode;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrent ? MyTheme.primaryBlue.withOpacity(0.1) : Colors.grey.shade100,
                    child: Text(lang['code']!.toUpperCase(), style: TextStyle(color: isCurrent ? MyTheme.primaryBlue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  title: Text(
                    lang['native']!,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                      fontSize: 16,
                      color: isCurrent ? MyTheme.primaryBlue : MyTheme.textDark,
                    ),
                  ),
                  trailing: isCurrent ? const Icon(Icons.check_circle, color: MyTheme.primaryBlue) : null,
                  onTap: () {
                    context.read<AppStateProvider>().setLocale(Locale(lang['code']!));
                    Navigator.pop(bottomSheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit the application? Offline data will remain safe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MyTheme.criticalRed, foregroundColor: Colors.white, elevation: 0),
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
  }
}

class _SettingItem {
  final IconData icon;
  final Color bg;
  final Color color;
  final String title;
  final String? subtitle;
  final bool showArrow;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.bg,
    required this.color,
    required this.title,
    this.subtitle,
    this.showArrow = true,
    this.trailing,
    this.onTap,
  });
}
