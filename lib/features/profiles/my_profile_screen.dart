import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/profile_image_picker.dart';
import '../../core/widgets/avatar_image.dart';
import '../../services/auth_service.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../services/mock_data_service.dart';
import '../auth/login_screen.dart';
import '../cart/contact_cart_screen.dart';
import '../contacts/contact_us_screen.dart';
import '../home/notifications_screen.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final MockDataService mockData;
  final VoidCallback? onBackToHome;

  const MyProfileScreen({
    super.key,
    required this.mockData,
    this.onBackToHome,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _handleDirectPhotoPick() async {
    final result = await pickProfileImage();
    if (result != null) {
      setState(() => _isUploadingPhoto = true);

      // 1. Immediately apply image bytes to active user so it renders instantly
      final user = widget.mockData.currentUser;
      final immediateUpdate = user.copyWith(imageBytes: result.bytes);
      widget.mockData.updateUserProfile(immediateUpdate);
      AuthService().updateCurrentUserAccount(
        name: user.name,
        phone: user.phone,
        email: user.email,
        gender: user.gender,
        imageBytes: result.bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('${result.fileName} Cloudflare R2-ல் பதிவேற்றப்படுகிறது...')),
              ],
            ),
            backgroundColor: const Color(0xFF7A132B),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 2. Upload to Cloudflare R2 bucket matrimony-profile-images / profiles/
      try {
        final r2Url = await CloudflareR2Service().uploadProfileImage(
          imageBytes: result.bytes,
          fileName: result.fileName,
          userId: user.id.isNotEmpty ? user.id : (user.phone.isNotEmpty ? user.phone : 'user'),
          oldImageUrl: user.profileImageUrl,
        );

        setState(() => _isUploadingPhoto = false);

        final r2Updated = widget.mockData.currentUser.copyWith(
          imageBytes: result.bytes,
          profileImageUrl: r2Url,
        );
        widget.mockData.updateUserProfile(r2Updated);
        AuthService().updateCurrentUserAccount(
          name: user.name,
          phone: user.phone,
          email: user.email,
          gender: user.gender,
          imageBytes: result.bytes,
          profileImageUrl: r2Url,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('சுயவிவரப் படம் Cloudflare R2-ல் வெற்றிகரமாக சேமிக்கப்பட்டது! ✓')),
                ],
              ),
              backgroundColor: Color(0xFF1B6B38),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() => _isUploadingPhoto = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('R2 பதிவேற்றம் பிழை: $e'),
              backgroundColor: const Color(0xFFC81E1E),
            ),
          );
        }
      }
    }
  }

  void _openEditTab(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          mockData: widget.mockData,
          initialTabIndex: tabIndex,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("வெளியேறுதல் / Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("கணக்கிலிருந்து நிச்சயமாக வெளியேற விரும்புகிறீர்களா?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("இல்லை"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A132B), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().logout();
              widget.mockData.syncWithAuth(null);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("வெளியேறு"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
        final user = widget.mockData.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            foregroundColor: Colors.white,
            leading: (widget.onBackToHome != null || (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)))
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    tooltip: "முகப்புக்கு செல்க / Back to Home",
                    onPressed: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else if (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'எனது கணக்கு / My Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: "அமைப்புகள் / Settings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(mockData: widget.mockData),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. User Identity & Quick Action Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEDE0D5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A132B).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingPhoto ? null : _handleDirectPhotoPick,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                AvatarImage(
                                  seed: user.avatarSeed,
                                  name: user.name,
                                  size: 76,
                                  isVerified: true,
                                  gender: user.gender,
                                  imageBytes: user.imageBytes,
                                  imageUrl: user.profileImageUrl,
                                ),
                                if (_isUploadingPhoto)
                                  Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.45),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7A132B),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C161A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF1B6B38), width: 0.7),
                                  ),
                                  child: const Text(
                                    "Verified ✓",
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Profile ID: ${user.id} • ${AppConstants.communityName}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A132B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.phone,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B5458),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF0E5DC)),
                  const SizedBox(height: 14),

                  // Convenience Action Button: Edit Profile
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditTab(0),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF7A132B)),
                      label: const Text(
                        'சுயவிவரம் திருத்து / Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A132B), fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7A132B), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Convenience Quick Services & Settings
            const Text(
              "வசதிகள் & அமைப்புகள் / Quick Convenience",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF580B23),
              ),
            ),
            const SizedBox(height: 8),

            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEDE0D5)),
              ),
              child: Column(
                children: [
                  _buildConvenienceTile(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF1B6B38),
                    title: "எனது கட்டணங்கள் & தொடர்புகள்",
                    subtitle: "Payment Requests & Unlocked Contacts",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactCartScreen(
                            mockData: widget.mockData,
                            initialTabIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF3EAE0)),
                  _buildConvenienceTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: const Color(0xFFE65100),
                    title: "முக்கிய அறிவிப்புகள்",
                    subtitle: "Notifications & Approvals",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(mockData: widget.mockData),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF3EAE0)),
                  _buildConvenienceTile(
                    icon: Icons.security_rounded,
                    iconColor: const Color(0xFF2C7BE5),
                    title: "தனியுரிமை & கணக்கு அமைப்புகள்",
                    subtitle: "Privacy, Password & Preferences",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(mockData: widget.mockData),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF3EAE0)),
                  _buildConvenienceTile(
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFF6A1B9A),
                    title: "உதவி & தொடர்பு மையம்",
                    subtitle: "Help Center • 94884 46677",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Logout Button
            OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
              label: const Text(
                "வெளியேறு / Logout",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFFFFF5F5),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
      },
    );
  }



  Widget _buildConvenienceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C161A)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 10.5, color: Color(0xFF7E6F72)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
      onTap: onTap,
    );
  }
}
