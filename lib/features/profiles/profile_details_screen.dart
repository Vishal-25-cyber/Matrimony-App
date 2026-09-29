import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../core/widgets/big_horoscope_charts_dialog.dart';
import '../../core/widgets/drawn_horoscope_chart_widget.dart';
import '../../core/utils/horoscope_download_helper.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/widgets/contact_unlock_dialog.dart';
import '../main_navigation_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String profileId;
  final MockDataService mockData;

  const ProfileDetailsScreen({
    super.key,
    required this.profileId,
    required this.mockData,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  int _selectedTab = 0; // 0: Details, 1: Horoscope, 2: Family & Contact
  final GlobalKey _chartSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
        final profile = widget.mockData.getProfileById(widget.profileId) ??
            ProfileModel(
              id: widget.profileId.isNotEmpty ? widget.profileId : "PM-1001",
              name: "Candidate Profile",
              gender: "Bride",
              age: 25,
              height: "5' 4\"",
              maritalStatus: "Never Married",
              motherTongue: "Tamil",
              religion: "Hindu",
              community: "Pandarathar (பண்டாரத்தார்)",
              education: "B.Tech",
              occupation: "Software Professional",
              company: "IT Solutions",
              annualIncome: "₹8 - 10 LPA",
              location: "Coimbatore",
              about: "Family-oriented, traditional values.",
              fatherName: "K. Sundaram",
              motherName: "S. Lakshmi",
              siblings: "1 Brother",
              familyLocation: "Coimbatore",
              familyDetails: "Traditional family",
              preferredAge: "26 - 30 Yrs",
              preferredLocation: "Coimbatore, Chennai",
              preferredEducation: "Any Degree",
              preferredOccupation: "Professional",
              isOnline: true,
              phone: "+91 94884 46677",
              whatsapp: "+91 94884 46677",
              email: "contact@pandarathar.com",
              avatarSeed: "Candidate",
              imageAsset: "assets/images/bride_soundarya.jpg",
            );

        final isLiked = profile.isShortlisted;
        final isUnlocked = profile.isContactUnlocked;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: "பின்செல்க / Back",
              onPressed: () => SafeNavigation.safePop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${profile.id} • ${profile.gender == 'Bride' ? 'மணமகள்' : 'மணமகன்'}",
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFFF0D68A), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              // Like / Shortlist Button
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? const Color(0xFFFF4B6E) : Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  widget.mockData.toggleShortlist(profile.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                              color: const Color(0xFFF3E5AB),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isLiked
                                      ? "விருப்பப்பட்டியலில் இருந்து நீக்கப்பட்டது"
                                      : "விருப்பப்பட்டியலில் சேர்க்கப்பட்டது! ✓",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFEDE0D5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0x33F3E5AB), width: 1),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      elevation: 8,
                      backgroundColor: const Color(0xFF4A0E1C),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Column(
              children: [
                // Profile Card Top with Photo & Horoscope CTA
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDE0D5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                              color: const Color(0xFFF9F0E6),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildProfilePhoto(profile),
                          ),
                          // Heart button floating on photo
                          Positioned(
                            top: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () => widget.mockData.toggleShortlist(profile.id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isLiked ? const Color(0xFFFF4B6E) : const Color(0xFF7E6F72),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.nameTamil != null && profile.nameTamil!.isNotEmpty
                            ? "${profile.name} (${profile.nameTamil})"
                            : profile.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A132B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${profile.age} வயது • ${(profile.star ?? 'Rohini').split(' (').first} • ${profile.location.replaceAll(', Tamil Nadu', '').replaceAll(', TN', '')}",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A4448)),
                      ),
                    ],
                  ),
                ),

                if (isUnlocked) ...[
                  const SizedBox(height: 14),
                  _buildContactStatusCard(profile, isUnlocked),
                ],

                const SizedBox(height: 14),

                // Tab Switcher: விவரம் / Details | ஜாதகம் / Horoscope | குடும்பம் & தொடர்பு
                Row(
                  children: [
                    _buildTabButton(0, "விவரம் / Details"),
                    const SizedBox(width: 8),
                    _buildTabButton(1, "ஜாதகம் / Horoscope"),
                    const SizedBox(width: 8),
                    _buildTabButton(2, isUnlocked ? "குடும்பம் & தொடர்பு ✓" : "குடும்பம் & தொடர்பு 🔒"),
                  ],
                ),

                const SizedBox(height: 14),

                // Tab Content
                if (_selectedTab == 0) _buildDetailsTab(profile),
                if (_selectedTab == 1) _buildHoroscopeTab(profile),
                if (_selectedTab == 2) _buildFamilyTab(profile, isUnlocked),
              ],
            ),
          ),
        );
      },
    );
  }

  // Status Card for Direct Contact
  Widget _buildContactStatusCard(ProfileModel profile, bool isUnlocked) {
    if (!isUnlocked) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B6B38), width: 1.2),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B38), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "நேரடி தொடர்பு எண்கள் முழுமையாக திறக்கப்பட்டுள்ளது! ✓",
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFFAF3EC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7A132B)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF7A132B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Details Tab
  Widget _buildDetailsTab(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        children: [
          _buildDataRow(Icons.cake_outlined, "வயது / Age", "${profile.age} Yrs"),
          _buildDivider(),
          _buildDataRow(Icons.straighten_rounded, "உயரம் / Height", profile.height),
          _buildDivider(),
          _buildDataRow(Icons.favorite_border, "திருமண நிலை / Status", profile.maritalStatus),
          _buildDivider(),
          _buildDataRow(Icons.groups_outlined, "சாதி / Caste", profile.community),
          _buildDivider(),
          _buildDataRow(Icons.school_outlined, "கல்வி / Education", profile.education),
          _buildDivider(),
          _buildDataRow(Icons.work_outline_rounded, "தொழில் / Occupation", profile.occupation),
          _buildDivider(),
          _buildDataRow(Icons.business_outlined, "நிறுவனம் / Company", profile.company),
          _buildDivider(),
          _buildDataRow(Icons.payments_outlined, "வருமானம் / Income", profile.annualIncome),
          _buildDivider(),
          _buildDataRow(Icons.location_on_outlined, "இருப்பிடம் / Location", profile.location),
        ],
      ),
    );
  }

  // Horoscope Tab (100% Free Access)
  Widget _buildHoroscopeTab(ProfileModel profile) {
    return Column(
      children: [
        // 1. Astrological Primary Information Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE0D5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_edu_rounded, color: Color(0xFF7A132B), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "அடிப்படை ஜாதகக் குறிப்புகள் / Basic Horoscope",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildDivider(),
              _buildDataRow(Icons.star_rounded, "நட்சத்திரம் / Star", profile.star ?? "ரோகிணி (Rohini)"),
              _buildDivider(),
              _buildDataRow(Icons.brightness_5_outlined, "ராசி / Moon Sign", profile.rasi ?? "ரிஷபம் (Rishabham)"),
              _buildDivider(),
              _buildDataRow(Icons.account_balance_outlined, "கோத்திரம் / Gothram", profile.gothram ?? "சிவகோத்திரம் (Siva Gothram)"),
              _buildDivider(),
              _buildDataRow(
                Icons.shield_outlined,
                "ஜாதக தோஷம் / Dosham",
                profile.doshamType == 'chevvai'
                    ? "செவ்வாய் தோஷம் உண்டு (7/8-ம் இடம்)"
                    : profile.doshamType == 'rahu_ketu'
                        ? "ராகு - கேது சர்ப்ப தோஷம்"
                        : profile.doshamType == 'chevvai_rahu_ketu'
                            ? "செவ்வாய் + ராகு-கேது (இரட்டை தோஷம்)"
                            : profile.doshamType == 'kalathra'
                                ? "களத்திர / மாங்கல்ய தோஷம்"
                                : "சுத்த ஜாதகம் (தோஷமில்லை)",
              ),
              _buildDivider(),
              _buildDataRow(
                Icons.security_rounded,
                "தோஷப் பொருத்தம்",
                profile.doshamType == 'chevvai'
                    ? "செவ்வாய் தோஷ வரன்கள் மட்டும்"
                    : profile.doshamType == 'rahu_ketu'
                        ? "ராகு-கேது தோஷ வரன்கள் மட்டும்"
                        : profile.doshamType == 'chevvai_rahu_ketu'
                            ? "இரட்டை தோஷ வரன்கள் மட்டும்"
                            : profile.doshamType == 'kalathra'
                                ? "களத்திர தோஷ வரன்கள் மட்டும்"
                                : "சுத்த ஜாதக வரன்கள் மட்டும்",
              ),
              _buildDivider(),
              _buildDataRow(Icons.timelapse_rounded, "தசா புக்தி இருப்பு", "சுக்கிர திசை 4 ஆண்டுகள் 6 மாதங்கள்"),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Astrological Charts Section (ராசி & நவாம்சக் கட்டங்கள்)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE0D5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_on_rounded, color: Color(0xFF7A132B), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "ஜாதகக் கட்டங்கள் / Astrological Charts",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFF7A132B), size: 20),
                    tooltip: "கட்டங்களை பெரிதாகக் காண்க",
                    onPressed: () => BigHoroscopeChartsDialog.show(context, profile),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Authentic 12-house drawn charts (RepaintBoundary for instant download)
              RepaintBoundary(
                key: _chartSectionKey,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DrawnHoroscopeChartWidget(
                          chartData: profile.getEffectiveRasiChart(),
                          isRasi: true,
                          cellHeight: 44,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DrawnHoroscopeChartWidget(
                          chartData: profile.getEffectiveNavamsamChart(),
                          isRasi: false,
                          cellHeight: 44,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => HoroscopeDownloadHelper.downloadHoroscopeCertificate(
                    context: context,
                    boundaryKey: _chartSectionKey,
                    profile: profile,
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text(
                    "ஜாதகக் கட்டங்களைப் பதிவிறக்குக / Download Charts (PNG)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B38),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Family & Contact Tab (Totally locked before payment, opens completely after payment)
  Widget _buildFamilyTab(ProfileModel profile, bool isUnlocked) {
    if (!isUnlocked) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE0D5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A132B).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7A132B).withValues(alpha: 0.2), width: 1.5),
              ),
              child: const Icon(Icons.lock_rounded, color: Color(0xFF7A132B), size: 26),
            ),
            const SizedBox(height: 12),
            const Text(
              "நேரடி தொடர்பு எண்கள் பூட்டப்பட்டுள்ளது",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF580B23),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${profile.phone.length > 7 ? profile.phone.substring(0, 7) : '+91 98421'} ••••••",
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF8C1D38),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "மணமகன்/மணமகளின் குடும்ப விவரங்கள், பெற்றோர் தகவல் மற்றும் நேரடி தொலைபேசி எண்களைப் பெற ஒரு முறை கட்டணம் ₹25 செலுத்தி தொடர்பு எண்ணைத் திறக்கவும்.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Color(0xFF5A4448), height: 1.35),
            ),
            const SizedBox(height: 16),

            // Masked preview of locked family & contact fields
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADBCE)),
              ),
              child: Column(
                children: [
                  _buildMaskedRow(Icons.person_outline, "தந்தை / Father", "•••••••••••••••"),
                  _buildDivider(),
                  _buildMaskedRow(Icons.person_outline, "தாய் / Mother", "•••••••••••••••"),
                  _buildDivider(),
                  _buildMaskedRow(Icons.people_outline, "உடன்பிறப்பு / Siblings", "•••••••••••••••"),
                  _buildDivider(),
                  _buildDataRow(Icons.home_outlined, "குடும்ப இருப்பிடம்", profile.familyLocation),
                  _buildDivider(),
                  _buildMaskedRow(Icons.phone_rounded, "நேரடி தொலைபேசி / Mobile", "+91 984 ••••••"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Direct Unlock Contact button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6B38),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                onPressed: () {
                  ContactUnlockDialog.show(
                    context,
                    profile: profile,
                    mockData: widget.mockData,
                    onUnlocked: () => setState(() {}),
                  );
                },
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text(
                  "💳 ₹25 செலுத்தி தொடர்பு எண் பெற / Unlock Contact",
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Add to Liked & Go to Shortlist page button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8C1D38),
                  side: const BorderSide(color: Color(0xFF8C1D38)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Like the profile if not already liked
                  if (!profile.isShortlisted) {
                    widget.mockData.toggleShortlist(profile.id);
                  }
                  // Navigate to the liked / shortlist page (tab index 3)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 3),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.favorite_rounded, size: 16),
                label: const Text(
                  "❤️ விருப்பப்பட்டியலில் சேர்த்து கட்டணம் செலுத்துக",
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      );
    }

    // Fully Unlocked State (After Payment)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom_rounded, color: Color(0xFF7A132B), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "குடும்ப விவரங்கள் / Family Details",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1B6B38)),
                ),
                child: const Text(
                  "திறக்கப்பட்டது ✓",
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDivider(),
          _buildDataRow(Icons.person_outline, "தந்தை / Father", profile.fatherName),
          _buildDivider(),
          _buildDataRow(Icons.person_outline, "தாய் / Mother", profile.motherName),
          _buildDivider(),
          _buildDataRow(Icons.people_outline, "உடன்பிறப்பு / Siblings", profile.siblings),
          _buildDivider(),
          _buildDataRow(Icons.home_outlined, "குடும்ப இருப்பிடம்", profile.familyLocation),
          _buildDivider(),
          _buildDataRow(Icons.info_outline_rounded, "குடும்ப வகை", profile.familyDetails),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: Color(0xFF7A132B), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "நேரடி தொடர்பு விவரங்கள் / Contact Details",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDataRow(Icons.phone_rounded, "கைபேசி / Mobile", profile.phone),
          _buildDivider(),
          _buildDataRow(Icons.chat_bubble_outline_rounded, "வாட்ஸ்அப் / WhatsApp", profile.whatsapp),
          _buildDivider(),
          _buildDataRow(Icons.email_outlined, "மின்னஞ்சல் / Email", profile.email),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Calling ${profile.phone}..."),
                          backgroundColor: const Color(0xFF1B6B38),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text("அழைக்க / Call", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B38),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Opening WhatsApp: ${profile.whatsapp}"),
                          backgroundColor: const Color(0xFF075E54),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: const Text("WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E54),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaskedRow(IconData icon, String label, String maskedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8C1D38)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A4448), fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            maskedValue,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E8B8E), letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Icon(icon, size: 16, color: const Color(0xFF7A132B)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2A1518)),
            ),
          ),
          const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4C3E41)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF0E5DB));
  }

  Widget _buildProfilePhoto(ProfileModel profile) {
    if (profile.profileImageUrl != null && profile.profileImageUrl!.trim().isNotEmpty) {
      final safeUrl = CloudflareR2Service().ensureDisplayableUrl(profile.profileImageUrl!);
      return Image.network(
        safeUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildLocalOrFallbackPhoto(profile),
      );
    }
    return _buildLocalOrFallbackPhoto(profile);
  }

  Widget _buildLocalOrFallbackPhoto(ProfileModel profile) {
    if (profile.imageBytes != null && profile.imageBytes!.isNotEmpty) {
      return Image.memory(
        profile.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildAssetOrPlaceholder(profile),
      );
    }
    return _buildAssetOrPlaceholder(profile);
  }

  Widget _buildAssetOrPlaceholder(ProfileModel profile) {
    final assetPath = profile.displayImageAsset;
    if (assetPath != null && assetPath.isNotEmpty) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildNoPhotoPlaceholder(profile),
      );
    }
    return _buildNoPhotoPlaceholder(profile);
  }

  Widget _buildNoPhotoPlaceholder(ProfileModel p) {
    final isBride = p.gender.toLowerCase() == 'bride';
    return Container(
      color: const Color(0xFFF9F0E6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBride ? Icons.person_3_rounded : Icons.person_rounded,
            size: 58,
            color: const Color(0xFF7A132B),
          ),
          const SizedBox(height: 4),
          const Text(
            'புகைப்படம் இல்லை\n(No Photo Set)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF8C797C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
