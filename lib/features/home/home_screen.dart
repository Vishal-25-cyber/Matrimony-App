import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/cloudflare_r2_service.dart';
import '../cart/contact_cart_screen.dart';


import 'menu_drawer.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final MockDataService mockData;
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.mockData,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      drawer: AppMenuDrawer(
        mockData: mockData,
        onNavigateToTab: onNavigateToTab,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/founder_arumugam.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.2),
                cacheWidth: 100,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appNameTamil,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppConstants.appNameEnglish,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFFF0D68A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(mockData: mockData),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Hero Wedding Banner
                    _buildHeroBanner(context),

                    const SizedBox(height: 10),

                    // 2. Community Key Statistics Strip
                    _buildCommunityStatsStrip(),

                    const SizedBox(height: 10),

                    // 3. Mini Member Dashboard (Personal Activity)
                    _buildMiniMemberDashboard(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 1. HERO WEDDING BANNER
  // ==========================================
  Widget _buildHeroBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => onNavigateToTab(1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        height: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEADCCE)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF580B23).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/images/tamil_wedding_banner.jpg',
          fit: BoxFit.cover,
          cacheWidth: 800,
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }

  // ==========================================
  // 2. COMMUNITY STATS STRIP
  // ==========================================
  Widget _buildCommunityStatsStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatPill("🏛️", "8,000+", "வரன்கள் / Profiles")),
          Container(width: 1, height: 26, color: const Color(0xFFDAC7B8)),
          Expanded(child: _buildStatPill("💍", "1,500+", "திருமணங்கள் / Marriages")),
          Container(width: 1, height: 26, color: const Color(0xFFDAC7B8)),
          Expanded(child: _buildStatPill("🌟", "15+", "ஆண்டு சேவை / Years")),
        ],
      ),
    );
  }

  Widget _buildStatPill(String emoji, String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                count,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A132B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B585C),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. MINI MEMBER DASHBOARD
  // ==========================================
  Widget _buildMiniMemberDashboard(BuildContext context) {
    return ListenableBuilder(
      listenable: mockData,
      builder: (context, _) {
        final user = mockData.currentUser;
        final likedCount = mockData.shortlistedProfiles.length;
        final matchingCount = mockData.getRealMatchingCount(user);
        final unlockedCount = mockData.unlockedProfiles.length;

        final subSectDisplay = user.subSect != null && user.subSect!.contains('(')
            ? user.subSect!.split('(')[0].trim()
            : (user.subSect ?? user.community);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEADBCE)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF580B23).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Status Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (user.imageBytes != null && user.imageBytes!.isNotEmpty)
                        ? Image.memory(user.imageBytes!, fit: BoxFit.cover)
                        : (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                            ? Image.network(
                                CloudflareR2Service().ensureDisplayableUrl(user.profileImageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildUserAvatar(user),
                              )
                            : (user.imageAsset != null && user.imageAsset!.isNotEmpty)
                                ? Image.asset(
                                    user.imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _buildUserAvatar(user),
                                  )
                                : _buildUserAvatar(user),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "வணக்கம், ${(user.nameTamil != null && user.nameTamil!.isNotEmpty) ? user.nameTamil! : user.name}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C1E20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF1B6B38)),
                          ],
                        ),
                        Text(
                          "ID: ${user.id} • $subSectDisplay",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF8C797C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF3EAE0)),
              const SizedBox(height: 8),

              // 3 Quick Dashboard Status Metrics: Shortlist, My Matches, Unlocked Contacts
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardPill(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFE53935),
                      count: "$likedCount",
                      label: "விருப்பங்கள்",
                      subtitle: "Shortlist",
                      onTap: () => onNavigateToTab(3),
                    ),
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFEDE0D5)),
                  Expanded(
                    child: _buildDashboardPill(
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF7A132B),
                      count: "$matchingCount",
                      label: "பொருத்தங்கள்",
                      subtitle: "Matches",
                      onTap: () => onNavigateToTab(1),
                    ),
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFEDE0D5)),
                  Expanded(
                    child: _buildDashboardPill(
                      icon: Icons.contact_phone_rounded,
                      iconColor: const Color(0xFF1B6B38),
                      count: "$unlockedCount",
                      label: "தொடர்புகள்",
                      subtitle: "Unlocked",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContactCartScreen(
                              mockData: mockData,
                              initialTabIndex: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardPill({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C494C),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                color: Color(0xFF8C797C),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUserAvatar(ProfileModel user) {
    final initials = _getUserInitials(user.name);
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF8C2C41), Color(0xFF580B23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _getUserInitials(String name) {
    if (name.isEmpty) return 'M';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
