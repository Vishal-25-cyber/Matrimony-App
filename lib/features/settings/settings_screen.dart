import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../services/auth_service.dart';
import '../../services/mongodb_service.dart';
import '../auth/login_screen.dart';
import '../profiles/edit_profile_screen.dart';
import '../contacts/contact_us_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../core/utils/navigation_helper.dart';

class SettingsScreen extends StatefulWidget {
  final MockDataService mockData;

  const SettingsScreen({super.key, required this.mockData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings State
  String _selectedLanguage = 'Tamil / English';
  String _phoneVisibility = 'unlocked'; // 'unlocked', 'all', 'hidden'
  String _photoVisibility = 'all'; // 'all', 'request', 'hidden'
  String _horoscopeVisibility = 'matched'; // 'matched', 'protected'
  bool _notifyShortlist = true;

  // Notification toggles
  bool _notifyNewMatches = true;
  bool _notifyInterests = true;
  bool _notifyPaymentUpdates = true;
  bool _notifyWhatsApp = true;
  bool _notifyDailyPorutham = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: () => SafeNavigation.safePop(context, initialIndex: 4),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'அமைப்புகள் / Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Account, Privacy & Support',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFF0D68A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section Header
          _buildSectionTitle('Account / கணக்கு அமைப்புகள்'),

          // 1. Edit Profile
          _buildListTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update personal details, horoscope & photos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(mockData: widget.mockData),
                ),
              );
            },
          ),

          // 2. Privacy Options
          _buildListTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy Options',
            subtitle: _getPrivacySubtitle(),
            onTap: () => _showPrivacyOptionsSheet(context),
          ),

          // 3. Notification Preferences
          _buildListTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notification Preferences',
            subtitle: 'New matches, WhatsApp & payment alerts',
            onTap: () => _showNotificationPreferencesSheet(context),
          ),

          // 4. App Language
          _buildListTile(
            icon: Icons.language_rounded,
            title: 'App Language',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(context),
          ),

          // 5. Change Password
          _buildListTile(
            icon: Icons.key_outlined,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const SizedBox(height: 20),

          // Support & Legal Section
          _buildSectionTitle('Support & Legal / உதவி & விதிமுறைகள்'),

          // 6. Help & Support -> Opens ContactUsScreen
          _buildListTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Contact Community Care • Chennimalai Office',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsScreen(),
                ),
              );
            },
          ),

          // 7. Terms & Conditions
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Rules, ₹25 unlock policy & eligibility',
            onTap: () => _showTermsDialog(context),
          ),

          // 8. Privacy Policy
          _buildListTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            subtitle: 'Confidentiality, MongoDB encryption & data safety',
            onTap: () => _showPrivacyPolicyDialog(context),
          ),

          // 9. Admin Portal (Payment Approvals & Candidate Management)
          _buildListTile(
            icon: Icons.admin_panel_settings_rounded,
            title: 'நிர்வாக தளம் / Admin Portal',
            subtitle: 'Payment approvals, verify UTR & manage candidates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDashboardScreen(mockData: widget.mockData),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFC62828)),
              label: const Text(
                'Logout / வெளியேறுக',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC62828), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              '${AppConstants.appName}\nVersion 1.0.0 • Verified Community Platform',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrivacySubtitle() {
    if (_phoneVisibility == 'unlocked') {
      return 'Phone: Unlocked Members • Photos: $_photoVisibility';
    } else if (_phoneVisibility == 'hidden') {
      return 'Phone: Hidden • Photos: $_photoVisibility';
    }
    return 'Phone: All Members • Photos: $_photoVisibility';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7A132B),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE0D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7A132B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF7A132B), size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF580B23),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
                )
              : null,
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF8C797C), size: 22),
          onTap: onTap,
        ),
      ),
    );
  }

  // ==========================================
  // 1. PRIVACY OPTIONS SHEET
  // ==========================================
  void _showPrivacyOptionsSheet(BuildContext context) {
    String tempPhone = _phoneVisibility;
    String tempPhoto = _photoVisibility;
    String tempHoro = _horoscopeVisibility;
    bool tempShortlist = _notifyShortlist;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(Icons.lock_rounded, color: Color(0xFF7A132B), size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "தனியுரிமை அமைப்புகள் / Privacy Options",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF580B23),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Manage who can view your mobile number, photos & horoscope",
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
                    ),
                    const SizedBox(height: 16),

                    // Phone visibility
                    const Text(
                      "1. தொலைபேசி எண் பார்வை / Mobile Number Visibility",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                    const SizedBox(height: 6),
                    _buildRadioTile<String>(
                      title: "பணம் செலுத்தி திறக்கப்பட்டவர்களுக்கு மட்டும் (Default)",
                      subtitle: "Only members who unlock your contact via ₹25 payment",
                      value: "unlocked",
                      groupValue: tempPhone,
                      onChanged: (val) => setSheetState(() => tempPhone = val!),
                    ),
                    _buildRadioTile<String>(
                      title: "அனைத்து பதிவுசெய்த உறுப்பினர்களுக்கும்",
                      subtitle: "Visible to all verified Pandarathar community members",
                      value: "all",
                      groupValue: tempPhone,
                      onChanged: (val) => setSheetState(() => tempPhone = val!),
                    ),
                    _buildRadioTile<String>(
                      title: "மறைக்கப்பட்டது / Hidden",
                      subtitle: "Do not show phone number publicly",
                      value: "hidden",
                      groupValue: tempPhone,
                      onChanged: (val) => setSheetState(() => tempPhone = val!),
                    ),

                    const SizedBox(height: 14),

                    // Photo visibility
                    const Text(
                      "2. புகைப்படம் பார்வை / Photo Visibility",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                    const SizedBox(height: 6),
                    _buildRadioTile<String>(
                      title: "அனைத்து உறுப்பினர்களுக்கும் தெரியும் (Visible to All)",
                      subtitle: "Show photo to all registered members",
                      value: "all",
                      groupValue: tempPhoto,
                      onChanged: (val) => setSheetState(() => tempPhoto = val!),
                    ),
                    _buildRadioTile<String>(
                      title: "கோரிக்கைக்குப் பின் மட்டும் (On Request Only)",
                      subtitle: "Show photo only after you accept their request",
                      value: "request",
                      groupValue: tempPhoto,
                      onChanged: (val) => setSheetState(() => tempPhoto = val!),
                    ),

                    const SizedBox(height: 14),

                    // Horoscope visibility
                    const Text(
                      "3. ஜாதகக் குறிப்பு பார்வை / Horoscope Visibility",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                    const SizedBox(height: 6),
                    _buildRadioTile<String>(
                      title: "பொருத்தம் உள்ள நட்சத்திரங்களுக்கு (Public to Match)",
                      subtitle: "Visible to compatible star & rasi candidates",
                      value: "matched",
                      groupValue: tempHoro,
                      onChanged: (val) => setSheetState(() => tempHoro = val!),
                    ),
                    _buildRadioTile<String>(
                      title: "பாதுகாக்கப்பட்டது (Protected on Request)",
                      subtitle: "Only unlocked via request",
                      value: "protected",
                      groupValue: tempHoro,
                      onChanged: (val) => setSheetState(() => tempHoro = val!),
                    ),

                    const SizedBox(height: 14),

                    // Shortlist notification toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: const Color(0xFF1B6B38),
                      title: const Text(
                        "விருப்பப்பட்டியலில் சேர்த்தால் தெரிவிக்கவும்",
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      subtitle: const Text(
                        "Notify me when someone shortlists my profile",
                        style: TextStyle(fontSize: 11, color: Color(0xFF7A686B)),
                      ),
                      value: tempShortlist,
                      onChanged: (val) => setSheetState(() => tempShortlist = val),
                    ),

                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A132B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        setState(() {
                          _phoneVisibility = tempPhone;
                          _photoVisibility = tempPhoto;
                          _horoscopeVisibility = tempHoro;
                          _notifyShortlist = tempShortlist;
                        });

                        // Persist to MongoDB cache
                        MongoDBService().updateUserProfile({
                          'id': widget.mockData.currentUser.id,
                          'phoneVisibility': tempPhone,
                          'photoVisibility': tempPhoto,
                          'horoscopeVisibility': tempHoro,
                          'notifyShortlist': tempShortlist,
                        });

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "✓ தனியுரிமை அமைப்புகள் தரவுத்தளத்தில் புதுப்பிக்கப்பட்டது! (Privacy Saved)",
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFF1B6B38),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        "சேமிக்க / Save Privacy Settings",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        );
      },
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBF4ED) : const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEDE0D5),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF7A132B) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A686B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. NOTIFICATION PREFERENCES SHEET
  // ==========================================
  void _showNotificationPreferencesSheet(BuildContext context) {
    bool tempMatches = _notifyNewMatches;
    bool tempInterests = _notifyInterests;
    bool tempPayment = _notifyPaymentUpdates;
    bool tempWhatsApp = _notifyWhatsApp;
    bool tempDaily = _notifyDailyPorutham;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: Color(0xFF7A132B), size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "அறிவிப்பு விருப்பங்கள் / Notification Settings",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF580B23),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Select which alerts and updates you wish to receive",
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
                    ),
                    const SizedBox(height: 16),

                    _buildNotificationSwitch(
                      title: "புதிய வரன் அறிவிப்புகள் / New Match Alerts",
                      subtitle: "Alerts when auspicious matches matching your star are added",
                      value: tempMatches,
                      onChanged: (val) => setSheetState(() => tempMatches = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFEDE0D5)),

                    _buildNotificationSwitch(
                      title: "விருப்பம் & செய்தி / Interest & Message Alerts",
                      subtitle: "When a candidate expresses interest or accepts your proposal",
                      value: tempInterests,
                      onChanged: (val) => setSheetState(() => tempInterests = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFEDE0D5)),

                    _buildNotificationSwitch(
                      title: "கட்டணம் & தொடர்பு திறப்பு / Payment & Unlock Status",
                      subtitle: "Instant updates when UTR payment is approved by admin",
                      value: tempPayment,
                      onChanged: (val) => setSheetState(() => tempPayment = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFEDE0D5)),

                    _buildNotificationSwitch(
                      title: "WhatsApp அறிவிப்புகள் / WhatsApp Updates",
                      subtitle: "Receive direct match summaries on WhatsApp",
                      value: tempWhatsApp,
                      onChanged: (val) => setSheetState(() => tempWhatsApp = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFEDE0D5)),

                    _buildNotificationSwitch(
                      title: "தினசரி சுப நேர பொருத்தங்கள் / Daily Match Digest",
                      subtitle: "Morning notification of compatible Pandarathar horoscopes",
                      value: tempDaily,
                      onChanged: (val) => setSheetState(() => tempDaily = val),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A132B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        setState(() {
                          _notifyNewMatches = tempMatches;
                          _notifyInterests = tempInterests;
                          _notifyPaymentUpdates = tempPayment;
                          _notifyWhatsApp = tempWhatsApp;
                          _notifyDailyPorutham = tempDaily;
                        });

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "✓ அறிவிப்பு விருப்பங்கள் சேமிக்கப்பட்டது! (Preferences Saved)",
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFF1B6B38),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        "சேமிக்க / Save Preferences",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        );
      },
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeTrackColor: const Color(0xFF1B6B38),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A686B)),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // ==========================================
  // 3. APP LANGUAGE DIALOG
  // ==========================================
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.language_rounded, color: Color(0xFF7A132B)),
            SizedBox(width: 8),
            Text(
              'Select Language / மொழி',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              label: "தமிழ் (Tamil)",
              isSelected: _selectedLanguage == 'தமிழ் (Tamil)',
              onTap: () {
                setState(() => _selectedLanguage = 'தமிழ் (Tamil)');
                Navigator.pop(dialogCtx);
                _showLanguageFeedback("தமிழ் (Tamil)");
              },
            ),
            const SizedBox(height: 6),
            _buildLanguageOption(
              label: "English",
              isSelected: _selectedLanguage == 'English',
              onTap: () {
                setState(() => _selectedLanguage = 'English');
                Navigator.pop(dialogCtx);
                _showLanguageFeedback("English");
              },
            ),
            const SizedBox(height: 6),
            _buildLanguageOption(
              label: "இருமொழியும் / Tamil & English",
              isSelected: _selectedLanguage == 'Tamil / English',
              onTap: () {
                setState(() => _selectedLanguage = 'Tamil / English');
                Navigator.pop(dialogCtx);
                _showLanguageFeedback("Tamil & English");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEDE0D5),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: isSelected ? const Color(0xFFFBF4ED) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B38), size: 20)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  void _showLanguageFeedback(String lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("மொழி தேர்வு செய்யப்பட்டது: $lang (Language Updated)"),
        backgroundColor: const Color(0xFF1B6B38),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // 4. CHANGE PASSWORD DIALOG
  // ==========================================
  void _showChangePasswordDialog(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? passError;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.key_rounded, color: Color(0xFF7A132B), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'கடவுச்சொல் மாற்றுதல்\nChange Password',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Password
                    TextField(
                      controller: currentPassCtrl,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'தற்போதைய கடவுச்சொல் / Current *',
                        labelStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // New Password
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'புதிய கடவுச்சொல் / New Password *',
                        labelStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Confirm Password
                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'உறுதிசெய்க / Confirm Password *',
                        labelStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    if (passError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        passError!,
                        style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('ரத்து / Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A132B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final currentP = currentPassCtrl.text.trim();
                          final newP = newPassCtrl.text.trim();
                          final confirmP = confirmPassCtrl.text.trim();

                          if (currentP.isEmpty || newP.isEmpty || confirmP.isEmpty) {
                            setDialogState(() => passError = "அனைத்து புலங்களையும் உள்ளிடவும் (All fields required)");
                            return;
                          }
                          if (newP.length < 6) {
                            setDialogState(() => passError = "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்");
                            return;
                          }
                          if (newP != confirmP) {
                            setDialogState(() => passError = "புதிய கடவுச்சொற்கள் பொருந்தவில்லை (Passwords do not match)");
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            passError = null;
                          });

                          final res = await AuthService().changePassword(
                            currentPassword: currentP,
                            newPassword: newP,
                          );

                          if (!dialogCtx.mounted) return;

                          if (!res.success) {
                            setDialogState(() {
                              isSaving = false;
                              passError = res.message;
                            });
                          } else {
                            Navigator.pop(dialogCtx);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("✓ ${res.message}"),
                                backgroundColor: const Color(0xFF1B6B38),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('மாற்றுக / Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 5. TERMS & CONDITIONS MODAL
  // ==========================================
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7A132B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "விதிமுறைகள் & நிபந்தனைகள்",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                          ),
                          Text(
                            "Terms & Conditions • Pandarathar Matrimony",
                            style: TextStyle(fontSize: 11, color: Color(0xFF7A686B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFEADBCE), thickness: 1),
                const SizedBox(height: 10),

                _buildTermsSection(
                  number: "1",
                  title: "சமுதாய உறுப்பினர் தகுதி / Eligibility",
                  desc: "இத்தளம் பண்டாரத்தார் (Pandarathar) சமுதாய வரன்களுக்காக மட்டுமே இயங்குகிறது. மணமகனுக்கு 21 வயது மற்றும் மணமகளுக்கு 18 வயது பூர்த்தியடைந்திருக்க வேண்டும்.",
                ),
                _buildTermsSection(
                  number: "2",
                  title: "சுயவிவர உண்மைத்தன்மை / Profile Authenticity",
                  desc: "பதிவு செய்யப்படும் சுயவிவரங்கள், தொலைபேசி எண்கள், ஜாதகக் கட்டங்கள் மற்றும் சான்றிதழ்கள் அனைத்தும் உண்மையானவையாக இருக்க வேண்டும். தவறான தகவல்கள் கண்டறியப்பட்டால் கணக்கு உடனடியாக முடக்கப்படும்.",
                ),
                _buildTermsSection(
                  number: "3",
                  title: "தொடர்பு எண் திறப்பு & ₹25 கட்டணம் / Contact Policy",
                  desc: "ஒரு வரனின் நேரடி தொடர்பு எண் பெற ₹25 கட்டணம் நிர்ணயிக்கப்பட்டுள்ளது. இது உண்மையான திருமண வரன் தேடலை உறுதி செய்வதற்கும் சேவையைப் பராமரிப்பதற்கும் மட்டுமே. வணிக நோக்கங்களுக்காக தொடர்பு எண்களைப் பயன்படுத்துவது சட்டப்படி குற்றமாகும்.",
                ),
                _buildTermsSection(
                  number: "4",
                  title: "ஜாதகப் பொருத்தம் / Horoscope Matching",
                  desc: "வழங்கப்படும் 10 நவகிரகப் பொருத்தங்கள் கணக்கீடுகள் பாரம்பரிய ஜோதிட விதிகளின் அடிப்படையிலானவை. குடும்ப முடிவுகள் தனிப்பட்ட விருப்பத்திற்கு உட்பட்டவை.",
                ),
                _buildTermsSection(
                  number: "5",
                  title: "நன்னடத்தை & மரியாதை / Code of Conduct",
                  desc: "எல்லா உறுப்பினர்களும் சக வரன்களின் குடும்பங்களை மரியாதையுடன் அணுக வேண்டும். தகாத முறையில் குறுஞ்செய்தி அல்லது அழைப்பு செய்வது தடை செய்யப்பட்டுள்ளது.",
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A132B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("புரிந்துகொண்டேன் / I Understand & Agree", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection({required String number, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF7A132B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5A4448), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. PRIVACY POLICY MODAL
  // ==========================================
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1B6B38), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B6B38),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "தனியுரிமை கொள்கை",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                          ),
                          Text(
                            "Privacy Policy • 256-bit Secure Storage",
                            style: TextStyle(fontSize: 11, color: Color(0xFF7A686B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFEADBCE), thickness: 1),
                const SizedBox(height: 10),

                _buildTermsSection(
                  number: "1",
                  title: "பாதுகாப்பான தரவுத்தளம் / Secure MongoDB Cloud",
                  desc: "உங்கள் பெயர், கைபேசி எண், மின்னஞ்சல் மற்றும் கடவுச்சொல் ஆகியவை MongoDB கிளவுட் தரவுத்தளத்தில் குறியாக்கம் (Encryption) செய்யப்பட்டு பாதுகாப்பாக சேமிக்கப்படுகின்றன.",
                ),
                _buildTermsSection(
                  number: "2",
                  title: "தொடர்பு எண்கள் பாதுகாப்பு / Contact Protection",
                  desc: "உங்கள் நேரடி தொலைபேசி எண் பொதுவெளியில் அனைவருக்கும் தெரியாது. ₹25 கட்டணம் செலுத்தி நிர்வாகி சரிபார்த்த பின் மட்டுமே அங்கீகரிக்கப்பட்ட வரன்களுக்கு வெளிப்படுத்தப்படும்.",
                ),
                _buildTermsSection(
                  number: "3",
                  title: "புகைப்படங்கள் & ஜாதகப் பாதுகாப்பு / Media Security",
                  desc: "பதிவேற்றப்படும் புகைப்படங்கள் மற்றும் ஜாதக அட்டவணைகள் வாட்டர்மார்க் (Watermark) மற்றும் பாதுகாப்பு அடுக்குகளுடன் பாதுகாக்கப்படுகின்றன. மூன்றாம் தரப்பினருக்கு விற்பனை செய்யப்பட மாட்டாது.",
                ),
                _buildTermsSection(
                  number: "4",
                  title: "தரவு நீக்கம் & கட்டுப்பாடுகள் / Profile Deletion",
                  desc: "திருமணம் நிச்சயிக்கப்பட்ட பிறகு அல்லது எப்போது வேண்டுமானாலும் உங்கள் சுயவிவரத்தை தற்காலிகமாக மறைக்கவோ அல்லது நிரந்தரமாக நீக்கவோ உரிமை உண்டு.",
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B38),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("சரி / Close", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 7. LOGOUT CONFIRMATION DIALOG
  // ==========================================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text(
              "வெளியேறவா? / Logout?",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
            ),
          ],
        ),
        content: const Text(
          "உங்கள் கணக்கில் இருந்து வெளியேற விரும்புகிறீர்களா?\nAre you sure you want to logout from Pandarathar Matrimony?",
          style: TextStyle(fontSize: 12.5, color: Color(0xFF5A4448), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("ரத்து / Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("வெளியேறு / Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
