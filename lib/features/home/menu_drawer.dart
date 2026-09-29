import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../auth/login_screen.dart';
import '../auth/splash_screen.dart';
import '../contacts/contact_us_screen.dart';
import '../search/search_filter_screen.dart';
import 'notifications_screen.dart';
import 'success_stories_screen.dart';
import '../../core/widgets/horoscope_comparison_dialog.dart';

class AppMenuDrawer extends StatelessWidget {
  final MockDataService mockData;
  final Function(int)? onNavigateToTab;

  const AppMenuDrawer({
    super.key,
    required this.mockData,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFBF6),
      child: Column(
        children: [
          // Drawer Header with Founder Photo
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              18,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7A132B),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/founder_arumugam.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.2),
                    cacheWidth: 120,
                    filterQuality: FilterQuality.low,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appNameTamil,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        AppConstants.appNameEnglish,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Color(0xFFF0D68A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: "முகப்பு / Home",
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateToTab != null) onNavigateToTab!(0);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.celebration_rounded,
                  title: "அறிமுக மண மாலை / Welcome Screen",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SplashScreen(isWelcomeMode: true),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: "எங்களை பற்றி / About Us",
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.search_rounded,
                  title: "மணமக்கள் தேடல் / Search Matches",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchFilterScreen(mockData: mockData),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.favorite_rounded,
                  title: "விருப்பப்பட்ட வரன்கள் / Shortlisted Profiles",
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(3);
                    }
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.compare_arrows_rounded,
                  title: "இரு ஜாதகப் பொருத்தம் / 10 Poruthams Match",
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(2);
                    } else {
                      HoroscopeComparisonDialog.show(
                        context,
                        mockData: mockData,
                        initialShowUpload: true,
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.handshake_outlined,
                  title: "வெற்றிக் கதைகள் / Success Stories",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuccessStoriesScreen(mockData: mockData),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.phone_in_talk_outlined,
                  title: "தொடர்பு கொள்ள / Contact Us",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactUsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFFEADBCE), indent: 16, endIndent: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: "அறிவிப்புகள் / Notifications",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsScreen(mockData: mockData),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: "அமைப்புகள் / Settings",
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: "வெளியேறு / Logout",
                  color: const Color(0xFFC62828),
                  onTap: () {
                    AuthService().logout();
                    mockData.syncWithAuth(null);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom note
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Chennimalai Arumugam • 15+ Years Service",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? const Color(0xFF2A1518);
    return ListTile(
      leading: Icon(icon, color: effectiveColor, size: 21),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: effectiveColor,
        ),
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      onTap: onTap,
    );
  }

  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF6),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFF7A132B)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "எங்களை பற்றி / About Us",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/founder_arumugam.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.2),
                  cacheWidth: 120,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                AppConstants.founderName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A1518)),
              ),
            ),
            const Center(
              child: Text(
                AppConstants.serviceCenterTamil,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF7A132B), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              AppConstants.experienceText,
              style: TextStyle(fontSize: 11.5, color: Color(0xFF4C3E41), height: 1.3),
            ),
            const SizedBox(height: 8),
            const Text(
              "📍 ${AppConstants.addressTamil}",
              style: TextStyle(fontSize: 10.5, color: Color(0xFF6E5D62)),
            ),
            const SizedBox(height: 4),
            const Text(
              "📞 ${AppConstants.phoneDisplay}",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("சரி / Close", style: TextStyle(color: Color(0xFF7A132B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
