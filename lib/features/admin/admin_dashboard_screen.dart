import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../models/profile_model.dart';
import '../../models/payment_request_model.dart';
import '../../models/horoscope_chart_model.dart';
import '../../services/mock_data_service.dart';
import '../profiles/profile_details_screen.dart';
import '../main_navigation_screen.dart';
import 'widgets/admin_horoscope_table_editor.dart';

class AdminDashboardScreen extends StatefulWidget {
  final MockDataService mockData;

  const AdminDashboardScreen({super.key, required this.mockData});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Admin Authentication State
  bool _isAuthenticated = false;
  final _adminUserCtrl = TextEditingController();
  final _adminPassCtrl = TextEditingController();
  String? _authError;

  // Add Profile Form Controllers
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Bride';
  final _nameCtrl = TextEditingController();
  final _nameTamilCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '25');
  final _heightCtrl = TextEditingController(text: "5' 4\"");
  final _casteCtrl = TextEditingController(text: "Pandarathar (பண்டாரத்தார்)");
  String _selectedStar = "ரோகிணி (Rohini)";
  String _selectedRasi = "ரிஷபம் (Rishabham)";
  final String _gothram = "சிவகோத்திரம் (Siva Gothram)";
  String _doshamType = 'none'; // 'none', 'chevvai', 'rahu_ketu', 'chevvai_rahu_ketu', 'kalathra'
  final _educationCtrl = TextEditingController(text: "B.Tech / B.E");
  final _occupationCtrl = TextEditingController(text: "Software Engineer");
  final _companyCtrl = TextEditingController(text: "IT Solutions");
  final _incomeCtrl = TextEditingController(text: "₹12,00,000 PA");
  final _locationCtrl = TextEditingController(text: "Coimbatore, Tamil Nadu");
  final _fatherCtrl = TextEditingController(text: "Sundaram (Businessman)");
  final _motherCtrl = TextEditingController(text: "Lakshmi (Homemaker)");
  final _phoneCtrl = TextEditingController(text: "+91 94884 77112");
  final _whatsappCtrl = TextEditingController(text: "+91 94884 77112");
  final _r2UrlCtrl = TextEditingController();
  Map<String, String> _adminRasiChart = HoroscopeChartModel.getShudhaRasiTemplate();
  Map<String, String> _adminNavamsamChart = HoroscopeChartModel.getStandardNavamsamTemplate();

  // Search in Manage Tab
  final _searchCtrl = TextEditingController();
  String _filterGender = 'All';

  final List<String> _stars = [
    "அஸ்வினி (Aswini)",
    "பரணி (Bharani)",
    "கார்த்திகை (Karthigai)",
    "ரோகிணி (Rohini)",
    "மிருகசீரிடம் (Mrigashira)",
    "திருவாதிரை (Thiruvathirai)",
    "புனர்பூசம் (Punarpoosam)",
    "பூசம் (Poosam)",
    "ஆயில்யம் (Ayilyam)",
    "மகம் (Magam)",
    "பூரம் (Pooram)",
    "உத்திரம் (Uthiram)",
    "அஸ்தம் (Hastham)",
    "சித்திரை (Chithirai)",
    "சுவாதி (Swathi)",
    "விசாகம் (Visakam)",
    "அனுஷம் (Anusham)",
    "கேட்டை (Kettai)",
    "மூலம் (Moolam)",
    "பூராடம் (Pooradam)",
    "உத்திராடம் (Uthiradam)",
    "திருவோணம் (Thiruvonam)",
    "அவிட்டம் (Avittam)",
    "சதயம் (Sathayam)",
    "பூரட்டாதி (Poorattathi)",
    "உத்திரட்டாதி (Uthirattathi)",
    "ரேவதி (Revathi)",
  ];

  final List<String> _rasis = [
    "மேஷம் (Mesham)",
    "ரிஷபம் (Rishabham)",
    "மிதுனம் (Mithunam)",
    "கடகம் (Kadagam)",
    "சிம்மம் (Simmam)",
    "கன்னி (Kanni)",
    "துலாம் (Thulam)",
    "விருச்சிகம் (Viruchigam)",
    "தனுசு (Dhanusu)",
    "மகரம் (Magaram)",
    "கும்பம் (Kumbam)",
    "மீனம் (Meenam)",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateDefaultR2Url();
  }

  void _generateDefaultR2Url() {
    final nextId = widget.mockData.generateNextProfileId();
    _r2UrlCtrl.text = "https://pub-r2.pandarathar-matrimony.com/certificates/$nextId.pdf";
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    _nameCtrl.dispose();
    _nameTamilCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _casteCtrl.dispose();
    _educationCtrl.dispose();
    _occupationCtrl.dispose();
    _companyCtrl.dispose();
    _incomeCtrl.dispose();
    _locationCtrl.dispose();
    _fatherCtrl.dispose();
    _motherCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _r2UrlCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _authenticateAdmin() {
    final u = _adminUserCtrl.text.trim();
    final p = _adminPassCtrl.text.trim();
    if (u == 'admin' && p == 'admin123') {
      setState(() {
        _isAuthenticated = true;
        _authError = null;
      });
    } else {
      setState(() {
        _authError = "தவறான பயனர் பெயர் அல்லது கடவுச்சொல்\n(Username: admin / Password: admin123)";
      });
    }
  }

  void _handleAddProfile() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("தயவுசெய்து அனைத்து கட்டாய விவரங்களையும் நிரப்பவும்."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newId = widget.mockData.generateNextProfileId();
    final isBride = _gender == 'Bride';

    final newProfile = ProfileModel(
      id: newId,
      name: _nameCtrl.text.trim(),
      nameTamil: _nameTamilCtrl.text.trim().isNotEmpty ? _nameTamilCtrl.text.trim() : null,
      gender: _gender,
      age: int.tryParse(_ageCtrl.text.trim()) ?? 25,
      height: _heightCtrl.text.trim(),
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: _casteCtrl.text.trim(),
      caste: _casteCtrl.text.trim(),
      subSect: "பண்டாரத்தார் (Pandarathar)",
      star: _selectedStar,
      rasi: _selectedRasi,
      gothram: _gothram,
      dob: "15 Jun 1999",
      chevvaiDosham: (_doshamType == 'chevvai' || _doshamType == 'chevvai_rahu_ketu') ? "உண்டு / Yes" : "இல்லை / No",
      doshamType: _doshamType,
      r2CertificateUrl: _r2UrlCtrl.text.trim(),
      education: _educationCtrl.text.trim(),
      degree: _educationCtrl.text.trim(),
      occupation: _occupationCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      annualIncome: _incomeCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      about: "Family oriented, culturally rooted Pandarathar candidate.",
      fatherName: _fatherCtrl.text.trim(),
      motherName: _motherCtrl.text.trim(),
      siblings: "1 Sibling",
      familyLocation: _locationCtrl.text.trim(),
      familyDetails: "Respected Pandarathar community family.",
      preferredAge: isBride ? "27 - 31 Yrs" : "22 - 26 Yrs",
      preferredLocation: "Tamil Nadu",
      preferredEducation: "Any Degree / Professional",
      preferredOccupation: "Software / Govt / Business",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 உத்தம பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: _doshamType == 'chevvai'
          ? "செவ்வாய் தோஷம்"
          : _doshamType == 'rahu_ketu'
              ? "ராகு-கேது தோஷம்"
              : _doshamType == 'chevvai_rahu_ketu'
                  ? "இரட்டை தோஷம்"
                  : _doshamType == 'kalathra'
                      ? "களத்திர தோஷம்"
                      : "புதிய வரன்",
      imageAsset: isBride ? "assets/images/bride_sneha.jpg" : "assets/images/user_karthik.jpg",
      hobbies: ["Music", "Reading", "Temple Visits"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: _phoneCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim(),
      email: "${_nameCtrl.text.trim().toLowerCase().replaceAll(' ', '')}@pandarathar.com",
      avatarSeed: _nameCtrl.text.trim(),
      avatarColorHex: isBride ? "9C27B0" : "1B5E20",
      rasiChart: Map<String, String>.from(_adminRasiChart),
      navamsamChart: Map<String, String>.from(_adminNavamsamChart),
    );

    widget.mockData.addProfile(newProfile);

    // Reset inputs
    _nameCtrl.clear();
    _nameTamilCtrl.clear();
    _adminRasiChart = HoroscopeChartModel.getShudhaRasiTemplate();
    _adminNavamsamChart = HoroscopeChartModel.getStandardNavamsamTemplate();
    _generateDefaultR2Url();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${newProfile.name} (${newProfile.id}) வெற்றிகரமாக சேர்க்கப்பட்டது!",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B6B38),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Switch to Manage tab
    _tabController.animateTo(2);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildAdminLoginScreen();
    }

    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
        final pendingCount = widget.mockData.pendingPaymentRequests.length;

        return Scaffold(
          backgroundColor: const Color(0xFFFBF8F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFF580B23),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: "பயனர் தளம் / User App",
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  );
                }
              },
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Admin Portal",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "நிர்வாக தளம் • ${widget.mockData.allProfiles.length} வரன்கள்",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFF0D68A),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              // Logout
              IconButton(
                tooltip: "வெளியேறு / Logout",
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFF0D68A), size: 22),
                onPressed: () => setState(() => _isAuthenticated = false),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: const Color(0xFF48081C),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return TabBar(
                      controller: _tabController,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Color(0xFFD4AF37), width: 3),
                        insets: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFFD4AF37),
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 11.5),
                      tabs: [
                        // Tab 1: Payments with pending badge
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payment_rounded, size: 15),
                              const SizedBox(width: 4),
                              const Text("கட்டணம்"),
                              if (pendingCount > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5A93C),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$pendingCount',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3A2000),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Tab 2: Add Profile
                        const Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded, size: 15),
                              SizedBox(width: 4),
                              Text("சேர்க்க"),
                            ],
                          ),
                        ),
                        // Tab 3: Profiles - count badge, NOT inline text
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 15),
                              const SizedBox(width: 4),
                              const Text("வரன்கள்"),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.mockData.allProfiles.length}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPaymentApprovalsTab(),
              _buildAddCandidateTab(),
              _buildManageProfilesTab(),
            ],
          ),
        );

      },
    );
  }


  // ==========================================
  // TAB 1: PAYMENT APPROVALS (₹25 EACH)
  // ==========================================
  Widget _buildPaymentApprovalsTab() {
    final pendingList = widget.mockData.pendingPaymentRequests;
    final allRequests = widget.mockData.paymentRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEADBCE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF7A132B), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "UPI QR கட்டண சரிபார்ப்பு • ₹25 வீதம்",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "பயனரின் 12-இலக்க UTR-ஐ சரிபார்த்து 'அனுமதி' அழுத்தவும். தொடர்பு விவரங்கள் உடனே திறக்கப்படும்.",
                        style: TextStyle(fontSize: 11.5, color: Colors.brown[700], height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Header with count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "நிலுவையில் உள்ள கோரிக்கைகள் (${pendingList.length})",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
              ),
              if (pendingList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A93C).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${pendingList.length} Pending",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (pendingList.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE0D5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 44, color: Color(0xFF1B6B38)),
                  const SizedBox(height: 10),
                  const Text(
                    "அனைத்து கட்டணங்களும் சரிபார்க்கப்பட்டது",
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "புதிய QR கட்டண கோரிக்கைகள் இங்கு தோன்றும்.",
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...pendingList.map((req) => _buildPaymentRequestCard(req)),

          const SizedBox(height: 22),

          // Request History Section
          if (allRequests.where((r) => r.status != 'pending').isNotEmpty) ...[
            const Text(
              "சமீபத்திய முடிவுகள் / Approved & History",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
            ),
            const SizedBox(height: 10),
            ...allRequests.where((r) => r.status != 'pending').take(5).map((req) {
              final isApproved = req.status == 'approved';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isApproved ? const Color(0xFF1B6B38) : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${req.userName} • ₹${req.totalAmount.toInt()} (${req.profileNames.length} வரன்கள்)",
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "UTR: ${req.utrNumber} • ${req.profileNames.join(', ')}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFF1B6B38).withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isApproved ? "Approved ✓" : "Rejected",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? const Color(0xFF1B6B38) : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRequestCard(PaymentRequestModel req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: User Name + Amount Badge
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFF7A132B),
                child: Text(
                  req.userName.isNotEmpty ? req.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.userName,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "📞 ${req.userPhone}",
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B585C)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "₹${req.totalAmount.toInt()}",
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDE0D5)),
          const SizedBox(height: 10),

          // UTR / Transaction ID Pill with Copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2CA7E)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFFB8860B), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "UPI Transaction Ref (UTR):",
                        style: TextStyle(fontSize: 10, color: Color(0xFF7A4B00), fontWeight: FontWeight.w600),
                      ),
                      SelectableText(
                        req.utrNumber,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2A1518), letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: req.utrNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("UTR எண் நகலெடுக்கப்பட்டது / UTR Copied!"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A93C).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: Color(0xFF7A4B00)),
                        SizedBox(width: 4),
                        Text(
                          "Copy",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Profiles Requested to unlock
          Text(
            "கோரப்பட்ட வரன்கள் (${req.profileIds.length}):",
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: req.profileNames.map((name) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF3EC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF7A132B)),
                    const SizedBox(width: 4),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Approve / Reject Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: () => widget.mockData.rejectPaymentRequest(req.id),
                    icon: const Icon(Icons.close_rounded, size: 15, color: Colors.red),
                    label: const Text("நிராகரி", style: TextStyle(color: Colors.red, fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.mockData.approvePaymentRequest(req.id),
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text(
                      "அனுமதி / Approve",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
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

  // ==========================================
  // TAB 2: ADD GROOM & BRIDE (மணமகன் / மணமகள்)
  // ==========================================
  Widget _buildAddCandidateTab() {
    final isBride = _gender == 'Bride';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Candidate Type Selector (Bride vs Groom)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADBCE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "வரன் வகை • Candidate Type *",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _gender = 'Bride'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            decoration: BoxDecoration(
                              color: isBride ? const Color(0xFF7A132B) : const Color(0xFFFAF3EC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isBride ? const Color(0xFF7A132B) : const Color(0xFFD4AF37),
                                width: isBride ? 1.8 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.female_rounded,
                                  color: isBride ? Colors.white : const Color(0xFF7A132B),
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "மணமகள் (Bride)",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isBride ? Colors.white : const Color(0xFF7A132B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _gender = 'Groom'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            decoration: BoxDecoration(
                              color: !isBride ? const Color(0xFF7A132B) : const Color(0xFFFAF3EC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !isBride ? const Color(0xFF7A132B) : const Color(0xFFD4AF37),
                                width: !isBride ? 1.8 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.male_rounded,
                                  color: !isBride ? Colors.white : const Color(0xFF7A132B),
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "மணமகன் (Groom)",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: !isBride ? Colors.white : const Color(0xFF7A132B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section 1: Basic Information
            _buildSectionCard(
              title: "1. அடிப்படை விவரங்கள் • Basic Info",
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF7A132B),
              children: [
                _buildFormField(
                  label: "முழு பெயர் • Full Name (English) *",
                  controller: _nameCtrl,
                  hint: "e.g. Soundarya S.",
                  prefixIcon: Icons.badge_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? "பெயர் அவசியம்" : null,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  label: "தமிழ் பெயர் • Tamil Name",
                  controller: _nameTamilCtrl,
                  hint: "எ.கா: சௌந்தர்யா S.",
                  prefixIcon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: "வயது • Age *",
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        hint: "25",
                        prefixIcon: Icons.cake_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? "வயது அவசியம்" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        label: "உயரம் • Height",
                        controller: _heightCtrl,
                        hint: "5' 4\"",
                        prefixIcon: Icons.height_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  label: "சமூகம் • Caste",
                  controller: _casteCtrl,
                  hint: "Pandarathar (பண்டாரத்தார்)",
                  prefixIcon: Icons.diversity_3_rounded,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Section 2: Horoscope Details
            _buildSectionCard(
              title: "2. ஜாதகம் & தோஷ அமைப்புகள் • Horoscope",
              icon: Icons.history_edu_rounded,
              iconColor: const Color(0xFFD4AF37),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("நட்சத்திரம் • Star:", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF332024))),
                          const SizedBox(height: 5),
                          _buildDropdown(
                            value: _selectedStar,
                            items: _stars,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStar = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ராசி • Moon Sign:", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF332024))),
                          const SizedBox(height: 5),
                          _buildDropdown(
                            value: _selectedRasi,
                            items: _rasis,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRasi = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Astrological Problem / Dosham Selector (Clean Radio Cards)
                const Text(
                  "ஜாதக தோஷ வகை • Dosham Status:",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                ),
                const SizedBox(height: 6),
                _buildDoshamRadioTile(
                  type: 'none',
                  title: "சுத்த ஜாதகம் (தோஷம் இல்லை)",
                  badgeText: "Shudha Jathagam",
                ),
                _buildDoshamRadioTile(
                  type: 'chevvai',
                  title: "செவ்வாய் தோஷம் உண்டு",
                  badgeText: "Chevvai Dosham",
                ),
                _buildDoshamRadioTile(
                  type: 'rahu_ketu',
                  title: "ராகு - கேது தோஷம் உண்டு",
                  badgeText: "Rahu-Ketu",
                ),
                _buildDoshamRadioTile(
                  type: 'chevvai_rahu_ketu',
                  title: "இரட்டை தோஷம் (செவ்வாய் + ராகு-கேது)",
                  badgeText: "Double Dosham",
                ),
                _buildDoshamRadioTile(
                  type: 'kalathra',
                  title: "களத்திர / மாங்கல்ய தோஷம் உண்டு",
                  badgeText: "Kalathira",
                ),

                const SizedBox(height: 10),

                // Collapsible Horoscope Table Editor (Clean & Uncluttered)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      leading: const Icon(Icons.grid_on_rounded, color: Color(0xFF7A132B), size: 20),
                      title: const Text(
                        "ஜாதகக் கட்டங்கள் திருத்து (Rasi & Navamsam)",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      subtitle: const Text(
                        "12 கட்டங்கள் உள்ளீடு • விருப்பத்தேர்வு (Optional)",
                        style: TextStyle(fontSize: 10.5, color: Colors.grey),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: AdminHoroscopeTableEditor(
                            initialRasiChart: _adminRasiChart,
                            initialNavamsamChart: _adminNavamsamChart,
                            onChanged: (rasi, navamsam) {
                              _adminRasiChart = rasi;
                              _adminNavamsamChart = navamsam;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Horoscope Certificate PDF Link
                _buildFormField(
                  label: "ஜாதக சான்றிதழ் PDF இணைப்பு / Certificate Link",
                  controller: _r2UrlCtrl,
                  hint: "https://.../certificates/PM-xxxx.pdf",
                  prefixIcon: Icons.cloud_done_rounded,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Section 3: Professional & Location
            _buildSectionCard(
              title: "3. கல்வி, தொழில் & ஊர் • Career Details",
              icon: Icons.work_rounded,
              iconColor: const Color(0xFF2B6CB0),
              children: [
                _buildFormField(
                  label: "கல்வித் தகுதி • Education *",
                  controller: _educationCtrl,
                  hint: "B.Tech / MBA / MBBS / Any Degree",
                  prefixIcon: Icons.school_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? "கல்வி அவசியம்" : null,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  label: "தொழில் • Occupation *",
                  controller: _occupationCtrl,
                  hint: "Software Engineer / Doctor / Business / Govt",
                  prefixIcon: Icons.work_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? "தொழில் அவசியம்" : null,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: "நிறுவனம் • Company",
                        controller: _companyCtrl,
                        hint: "TCS / Govt",
                        prefixIcon: Icons.apartment_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        label: "வருமானம் • Income",
                        controller: _incomeCtrl,
                        hint: "₹12,00,000 PA",
                        prefixIcon: Icons.currency_rupee_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  label: "இருப்பிடம் • Location *",
                  controller: _locationCtrl,
                  hint: "Coimbatore, Tamil Nadu",
                  prefixIcon: Icons.location_on_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? "இருப்பிடம் அவசியம்" : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Section 4: Family & Contact (Unlocked for ₹25)
            _buildSectionCard(
              title: "4. குடும்பம் & தொடர்பு • Contact Details",
              icon: Icons.contact_phone_rounded,
              iconColor: const Color(0xFF1B6B38),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B38).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1B6B38).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_clock_rounded, size: 16, color: Color(0xFF1B6B38)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "பயனர் ₹25 செலுத்திய பின் மட்டுமே இவ்விவரங்கள் திறக்கப்படும்.",
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF1B6B38), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: "தொடர்பு எண் • Phone *",
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        hint: "+91 94884 xxxxx",
                        prefixIcon: Icons.phone_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? "எண் அவசியம்" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        label: "வாட்ஸ்அப் • WhatsApp",
                        controller: _whatsappCtrl,
                        keyboardType: TextInputType.phone,
                        hint: "+91 94884 xxxxx",
                        prefixIcon: Icons.chat_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: "தந்தை பெயர் • Father",
                        controller: _fatherCtrl,
                        hint: "Sundaram (Business)",
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        label: "தாய் பெயர் • Mother",
                        controller: _motherCtrl,
                        hint: "Lakshmi (Homemaker)",
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _handleAddProfile,
                icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                label: Text(
                  "வரன் பதிவு செய் • Add ${isBride ? 'மணமகள்' : 'மணமகன்'} Profile",
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDoshamRadioTile({
    required String type,
    required String title,
    required String badgeText,
  }) {
    final isSelected = _doshamType == type;
    return GestureDetector(
      onTap: () => setState(() => _doshamType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A132B).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEADBCE),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 17,
              color: isSelected ? const Color(0xFF7A132B) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF7A132B) : const Color(0xFF332024),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7A132B).withValues(alpha: 0.12) : const Color(0xFFF2ECE6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF7A132B) : Colors.brown[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6C5B6), width: 1.1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF7A132B), size: 22),
          style: const TextStyle(fontSize: 12, color: Color(0xFF111111), fontWeight: FontWeight.w600),
          items: items.map((it) => DropdownMenuItem(value: it, child: Text(it, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF332024)),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF111111), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF888888)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 17, color: const Color(0xFF7A132B)) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD6C5B6), width: 1.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF7A132B), width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: MANAGE ALL PROFILES (SEARCH, VIEW, DELETE)
  // ==========================================
  Widget _buildManageProfilesTab() {
    final query = _searchCtrl.text.trim().toLowerCase();
    var list = widget.mockData.allProfiles;

    if (_filterGender != 'All') {
      list = list.where((p) => p.gender.toLowerCase() == _filterGender.toLowerCase()).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.id.toLowerCase().contains(query) ||
            (p.caste?.toLowerCase().contains(query) ?? false) ||
            p.location.toLowerCase().contains(query);
      }).toList();
    }

    return Column(
      children: [
        // Search & Filter Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEDE0D5))),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: "தேடு (பெயர், ID: PM-xxx, ஊர்)...",
                    hintStyle: const TextStyle(fontSize: 11.5),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A132B)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFFDFBF7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', "அனைத்தும் (${widget.mockData.allProfiles.length})"),
                    const SizedBox(width: 8),
                    _buildFilterChip('Bride', "மணமகள் (${widget.mockData.allProfiles.where((p) => p.gender == 'Bride').length})"),
                    const SizedBox(width: 8),
                    _buildFilterChip('Groom', "மணமகன் (${widget.mockData.allProfiles.where((p) => p.gender == 'Groom').length})"),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Profiles List
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    "வரன்கள் எதுவும் கிடைக்கவில்லை / No profiles found",
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final p = list[idx];
                    return _buildManageProfileItem(p);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String val, String label) {
    final isSelected = _filterGender == val;
    return GestureDetector(
      onTap: () => setState(() => _filterGender = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFFAF3EC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEADBCE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF580B23),
          ),
        ),
      ),
    );
  }

  Widget _buildManageProfileItem(ProfileModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDE0D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: const Color(0xFFF9F0E6),
              child: (p.imageAsset != null && p.imageAsset!.isNotEmpty)
                  ? Image.asset(
                      p.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        p.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                        color: const Color(0xFF7A132B),
                        size: 24,
                      ),
                    )
                  : Icon(
                      p.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                      color: const Color(0xFF7A132B),
                      size: 24,
                    ),
            ),
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
                        p.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: p.gender == 'Bride'
                            ? Colors.pink.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.gender == 'Bride' ? "மணமகள்" : "மணமகன்",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: p.gender == 'Bride' ? Colors.pink[800] : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${p.id} • ${p.age} Yrs • ${p.location}",
                  style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      p.doshamType == 'chevvai'
                          ? 'செவ்வாய் உண்டு'
                          : p.doshamType == 'rahu_ketu'
                              ? 'ராகு-கேது'
                              : 'சுத்த ஜாதகம்',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: p.doshamType == 'chevvai' ? Colors.red[800] : const Color(0xFF1B6B38),
                      ),
                    ),
                    if (p.r2CertificateUrl != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        "PDF: ✓",
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF2B6CB0), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.visibility_outlined, color: Color(0xFF7A132B), size: 20),
                tooltip: "விவரம் / View",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileDetailsScreen(
                        profileId: p.id,
                        mockData: widget.mockData,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.grid_on_rounded, color: Color(0xFFD4AF37), size: 20),
                tooltip: "ஜாதகக் கட்டங்கள் திருத்து / Edit Charts",
                onPressed: () => _showEditHoroscopeDialog(p),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                tooltip: "நீக்குக / Delete",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("வரன் நீக்க உறுதிப்படுத்தல்", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      content: Text("${p.name} (${p.id}) வரனை நிச்சயமாக நீக்க விரும்புகிறீர்களா?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("வேண்டாம்"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text("${p.name} தரவுத்தளத்திலிருந்து நீக்கப்படுகிறது...")),
                                  ],
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            await widget.mockData.deleteProfile(p.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text("${p.name} (${p.id}) தரவுத்தளத்திலிருந்து முழுமையாக நீக்கப்பட்டது! ✓")),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1B6B38),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text("நீக்குக", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ADMIN LOGIN VIEW
  // ==========================================
  Widget _buildAdminLoginScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF580B23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "நிர்வாகி உள்நுழைவு / Admin Login",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 32, color: Color(0xFF7A132B)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Pandarathar Matrimony",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                ),
                const SizedBox(height: 2),
                const Text(
                  "நிர்வாகி கட்டுப்பாடு தளம் • Admin Portal",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B585C)),
                ),
                const SizedBox(height: 18),

                // Username field
                const Text("பயனர் பெயர் / Username", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _adminUserCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF7A132B), size: 18),
                      hintText: "admin",
                      filled: true,
                      fillColor: const Color(0xFFFDFBF7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password field
                const Text("கடவுச்சொல் / Password", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _adminPassCtrl,
                    obscureText: true,
                    style: const TextStyle(fontSize: 12.5),
                    onSubmitted: (_) => _authenticateAdmin(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF7A132B), size: 18),
                      hintText: "admin123",
                      filled: true,
                      fillColor: const Color(0xFFFDFBF7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),

                if (_authError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _authError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],

                const SizedBox(height: 16),

                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _authenticateAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A132B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "உள்நுழைக / Admin Login",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Credentials Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2CA7E), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "🔑 நிர்வாக நற்சான்றிதழ்கள் / Admin Credentials",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF7A4B00), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _credChip(Icons.person_rounded, "பயனர் / User", "admin"),
                          Container(width: 1, height: 32, color: const Color(0xFFE2CA7E)),
                          _credChip(Icons.lock_rounded, "கடவுச்சொல் / Pass", "admin123"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _credChip(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7A4B00)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF9A6B00))),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
          ),
        ],
      ),
    );
  }

  void _showEditHoroscopeDialog(ProfileModel p) {
    Map<String, String> editingRasi = Map<String, String>.from(p.getEffectiveRasiChart());
    Map<String, String> editingNav = Map<String, String>.from(p.getEffectiveNavamsamChart());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7A132B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ஜாதகக் கட்டங்கள் திருத்துதல்",
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                  ),
                  Text(
                    "${p.name} (${p.id})",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7A4B00), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: AdminHoroscopeTableEditor(
              initialRasiChart: editingRasi,
              initialNavamsamChart: editingNav,
              onChanged: (r, n) {
                editingRasi = r;
                editingNav = n;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ரத்து செய்"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B6B38),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text("அட்டவணையை சேமிக்க / Save"),
            onPressed: () {
              final updated = p.copyWith(
                rasiChart: editingRasi,
                navamsamChart: editingNav,
              );
              widget.mockData.updateProfile(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${p.name} (${p.id}) ஜாதகக் கட்டங்கள் வெற்றிகரமாக சேமிக்கப்பட்டன! ✓"),
                  backgroundColor: const Color(0xFF1B6B38),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

