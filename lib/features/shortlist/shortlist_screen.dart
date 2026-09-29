import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/auth_service.dart';
import '../profiles/profile_details_screen.dart';
import '../../core/widgets/horoscope_certificate_dialog.dart';
import '../../core/utils/navigation_helper.dart';

class ShortlistScreen extends StatefulWidget {
  final MockDataService mockData;
  final bool isAdmin;
  final VoidCallback? onBackToHome;

  const ShortlistScreen({
    super.key,
    required this.mockData,
    this.isAdmin = false,
    this.onBackToHome,
  });

  @override
  State<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends State<ShortlistScreen> {
  @override
  void initState() {
    super.initState();
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      widget.mockData.syncWithAuthAsync(authUser).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  // Opens the QR Payment Dialog / BottomSheet
  void _openPaymentDialog(BuildContext context, List<ProfileModel> profilesToUnlock, double totalAmount) {
    final nameController = TextEditingController(text: widget.mockData.currentUser.name);
    final amountController = TextEditingController(text: totalAmount.toInt().toString());
    final utrController = TextEditingController();
    String? formError;
    String? nameError;
    String? amountError;
    String? utrError;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final nameText = nameController.text.trim();
            final amtText = amountController.text.trim();
            final utrText = utrController.text.trim();
            final isAllFilled = nameText.isNotEmpty && amtText.isNotEmpty && utrText.isNotEmpty;

            return Container(
              margin: EdgeInsets.only(
                top: 40,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDF9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A132B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "QR கட்டணம் & தொடர்பு திறத்தல்",
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF580B23),
                                ),
                              ),
                              Text(
                                "சென்னிமலை ஆறுமுகம் - பண்டாரத்தார் மணமாலை",
                                style: TextStyle(fontSize: 11, color: Color(0xFF7A686B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF7A132B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF580B23), Color(0xFF7A132B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "கூடையில் உள்ள மொத்த வரன்கள்: ${profilesToUnlock.length}",
                                  style: const TextStyle(color: Color(0xFFF3E5AB), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "ஒரு வரன் கட்டணம்: ₹25 • கூடை மொத்த கட்டணம்",
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "₹${totalAmount.toInt()}",
                              style: const TextStyle(
                                color: Color(0xFF580B23),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // UPI QR Code Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Scan & Pay using GPay / PhonePe / Paytm / BHIM",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                          ),
                          const SizedBox(height: 10),

                          // QR Canvas
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(160, 160),
                                  painter: _ShortlistQrPainter(),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7A132B),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "ப",
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // UPI ID Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5EE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEADBCE)),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "UPI ID: ",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF6B585C), fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "pandaratharmatrimony@upi",
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF580B23), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(const ClipboardData(text: "pandaratharmatrimony@upi"));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("UPI ID நகலெடுக்கப்பட்டது (Copied)"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF7A132B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form Fields Header
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "கட்டண விவரங்கள் / Enter Payment Details:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF580B23),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "அனைத்தும் கட்டாயம் *",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 1. Payment User Name
                    TextField(
                      controller: nameController,
                      onChanged: (val) {
                        setModalState(() {
                          formError = null;
                          nameError = val.trim().isEmpty ? "செலுத்துபவர் பெயர் தேவை *" : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "செலுத்துபவர் பெயர் / Payment User Name *",
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF580B23)),
                        hintText: "உங்கள் பெயர் உள்ளிடவும்",
                        errorText: nameError,
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF7A132B), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFFAF7F2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. Amount Paid
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setModalState(() {
                          formError = null;
                          final parsed = double.tryParse(val.trim());
                          amountError = (val.trim().isEmpty || parsed == null || parsed <= 0)
                              ? "சரியான தொகை உள்ளிடவும் *"
                              : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "செலுத்தப்பட்ட தொகை / Amount Paid (₹) *",
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF580B23)),
                        hintText: "தொகை உள்ளிடவும்",
                        errorText: amountError,
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF1B6B38), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFFAF7F2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Transaction ID / UTR
                    TextField(
                      controller: utrController,
                      onChanged: (val) {
                        setModalState(() {
                          formError = null;
                          utrError = val.trim().isEmpty
                              ? "பரிவர்த்தனை எண் / UTR தேவை *"
                              : (val.trim().length < 6 ? "குறைந்தது 6 இலக்கங்கள் தேவை" : null);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "பரிவர்த்தனை எண் / Transaction ID / UTR *",
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF580B23)),
                        hintText: "12 இலக்க UTR எண் (எ.கா: 426891045231)",
                        hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                        errorText: utrError,
                        prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF7A132B), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFFAF7F2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    if (formError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formError!,
                                style: const TextStyle(color: Colors.red, fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Submit Button - Active only when all fields are completed
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAllFilled ? const Color(0xFF7A132B) : const Color(0xFFB099A0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: isAllFilled ? 2 : 0,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              final name = nameController.text.trim();
                              final amtVal = double.tryParse(amountController.text.trim());
                              final utr = utrController.text.trim();

                              if (name.isEmpty) {
                                setModalState(() {
                                  nameError = "செலுத்துபவர் பெயர் தேவை *";
                                  formError = "செலுத்துபவர் பெயரை உள்ளிடவும் (Enter User Name)";
                                });
                                return;
                              }
                              if (amountController.text.trim().isEmpty || amtVal == null || amtVal <= 0) {
                                setModalState(() {
                                  amountError = "சரியான தொகை உள்ளிடவும் *";
                                  formError = "செலுத்தப்பட்ட தொகையை சரியாக உள்ளிடவும் (Enter Valid Amount)";
                                });
                                return;
                              }
                              if (utr.isEmpty) {
                                setModalState(() {
                                  utrError = "பரிவர்த்தனை எண் / UTR தேவை *";
                                  formError = "பரிவர்த்தனை எண் / UTR உள்ளிடவும் (Enter Transaction ID / UTR)";
                                });
                                return;
                              }
                              if (utr.length < 6) {
                                setModalState(() {
                                  utrError = "குறைந்தது 6 இலக்கங்கள் தேவை";
                                  formError = "சரியான UTR எண்ணை உள்ளிடவும் (குறைந்தது 6 இலக்கங்கள்)";
                                });
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                                formError = null;
                              });

                              // Submit to MockDataService and MongoDB
                              widget.mockData.submitPaymentRequestWithDetails(
                                userName: name,
                                amount: amtVal,
                                utrNumber: utr,
                                profileIds: profilesToUnlock.map((p) => p.id).toList(),
                                profileNames: profilesToUnlock.map((p) => "${p.name} (${p.id})").toList(),
                              );

                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "கட்டணம் நிர்வாகி ஒப்புதலுக்கு அனுப்பப்பட்டது! நிர்வாகி (Admin) சரிபார்த்து ஒப்புதல் அளித்ததும் உடனே உங்கள் கூடையில் உள்ள ${profilesToUnlock.length} வரன்களும் திறக்கப்படும்.",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF1B6B38),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "ஒப்புதலுக்கு சமர்ப்பிக்கவும் / Submit",
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
        final shortlisted = widget.mockData.shortlistedProfiles;

        // Categorize shortlisted profiles
        final unlockedProfiles = shortlisted.where((p) => widget.mockData.isProfileUnlocked(p.id)).toList();
        final pendingProfiles = shortlisted.where((p) => widget.mockData.isProfilePendingApproval(p.id)).toList();
        final toUnlockProfiles = shortlisted
            .where((p) => !widget.mockData.isProfileUnlocked(p.id) && !widget.mockData.isProfilePendingApproval(p.id))
            .toList();

        final toUnlockTotal = toUnlockProfiles.length * 25.0;
        final pendingRequests = widget.mockData.pendingPaymentRequests;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              tooltip: "முகப்புக்கு செல்க / Back to Home",
              onPressed: () {
                if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                } else {
                  SafeNavigation.safePop(context, initialIndex: 0);
                }
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "விருப்பப்பட்ட வரன்கள்",
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "நீங்கள் விரும்பிய வரன்கள் (${shortlisted.length}) • ஒரு வரன் ₹25",
                  style: const TextStyle(fontSize: 11, color: Color(0xFFF3E5AB), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          body: shortlisted.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F3),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFC1CC)),
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: Color(0xFF8C1D38),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "விருப்பப்பட்ட வரன்கள் இல்லை",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF580B23),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "வரன்களைப் பார்வையிடும் போது விருப்பக்குறியீடு (❤️) அழுத்தினால் இங்கு சேர்க்கப்படும்.\nஒவ்வொரு வரனுக்கும் ₹25 செலுத்தி தொடர்பு எண்கள் & முழு ஜாதக விவரங்களைத் திறக்கலாம்.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B5458), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                  children: [
                    // 1. If there are locked profiles to pay for: show the clean payment summary card
                    if (toUnlockProfiles.isNotEmpty) ...[
                      _buildCartSummaryCard(
                        toUnlockCount: toUnlockProfiles.length,
                        toUnlockTotal: toUnlockTotal,
                        onPayPressed: () => _openPaymentDialog(context, toUnlockProfiles, toUnlockTotal),
                      ),
                      const SizedBox(height: 12),
                    ]
                    // 2. Else if there are pending approval requests: show simple pending banner (NO confusing "all unlocked" message!)
                    else if (pendingProfiles.isNotEmpty && pendingRequests.isNotEmpty) ...[
                      _buildPendingApprovalBanner(pendingRequests.first),
                      const SizedBox(height: 12),
                    ]
                    // 3. Else if all are unlocked: show clean success status
                    else if (unlockedProfiles.isNotEmpty) ...[
                      _buildAllUnlockedBanner(),
                      const SizedBox(height: 12),
                    ],

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "கூடையில் உள்ள வரன்கள் (${shortlisted.length})",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF580B23),
                          ),
                        ),
                        Text(
                          "திறக்கப்பட்டது: ${unlockedProfiles.length}/${shortlisted.length}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B6B38),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of Liked Profiles
                    ...shortlisted.map((profile) {
                      final isUnlocked = widget.mockData.isProfileUnlocked(profile.id);
                      final isPending = widget.mockData.isProfilePendingApproval(profile.id);

                      return _buildShortlistCartCard(
                        profile: profile,
                        isUnlocked: isUnlocked,
                        isPending: isPending,
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  // Cart & Calculation Summary Card - Clean, Styled, No Overflow
  Widget _buildCartSummaryCard({
    required int toUnlockCount,
    required double toUnlockTotal,
    required VoidCallback onPayPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFDF7), Color(0xFFFFF8E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF580B23).withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Icon + Label + Price Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, size: 18, color: Color(0xFF7A132B)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$toUnlockCount வரன்கள் × ₹25',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1A1D),
                        ),
                      ),
                      const Text(
                        'கட்டணம் செலுத்தி தொடர்பு எண் பெறுக',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF7A686B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Total Amount badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${toUnlockTotal.toInt()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF580B23),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFEDE0C8)),

          // Bottom: Rate info + Pay Button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                // Rate info chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B38).withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_rounded, size: 13, color: Color(0xFF1B6B38)),
                      SizedBox(width: 4),
                      Text(
                        '1 வரன் = ₹25 மட்டுமே',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B6B38),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Pay Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A132B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    shadowColor: const Color(0xFF7A132B).withValues(alpha: 0.4),
                  ),
                  onPressed: onPayPressed,
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: Text(
                    '₹${toUnlockTotal.toInt()} செலுத்துக',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Pending Approval Banner - Clean & Simple (Admin Approve button visible for Admin)
  Widget _buildPendingApprovalBanner(dynamic pendingReq) {
    final bool showAdminAction = widget.isAdmin || AuthService().currentUser?.username == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5A93C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, color: Color(0xFFB8860B), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "கட்டணம் சரிபார்க்கப்படுகிறது (UTR: ${pendingReq.utrNumber})",
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5A93C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "நிர்வாகி சரிபார்த்து ஒப்புதல் அளித்ததும் உடனே வரன்களின் தொடர்புகள் திறக்கப்படும்.",
            style: TextStyle(fontSize: 11, color: Color(0xFF6B5430)),
          ),
          if (showAdminAction) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6B38),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                ),
                onPressed: () {
                  widget.mockData.approvePaymentRequest(pendingReq.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✓ நிர்வாகி ஒப்புதல் அளித்தார்! அனைத்து வரன்களின் தொடர்பு விவரங்களும் திறக்கப்பட்டன."),
                      backgroundColor: Color(0xFF1B6B38),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.verified_rounded, size: 14),
                label: const Text(
                  "நிர்வாகி உடனடி ஒப்புதல் (Admin Approve)",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // All Unlocked Banner - Clean & Simple Success Strip
  Widget _buildAllUnlockedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B38), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "அனைத்து வரன்களின் தொடர்பு விவரங்களும் திறக்கப்பட்டுவிட்டன ✓",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
            ),
          ),
        ],
      ),
    );
  }

  // Individual Liked Profile Card (Cart Item)
  Widget _buildShortlistCartCard({
    required ProfileModel profile,
    required bool isUnlocked,
    required bool isPending,
  }) {
    final bool showAdminAction = widget.isAdmin || AuthService().currentUser?.username == 'admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFA5D6A7)
              : isPending
                  ? const Color(0xFFE5A93C)
                  : const Color(0xFFEADBCE),
          width: isUnlocked ? 1.5 : 1,
        ),
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
          // Profile Info Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Thumbnail
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileDetailsScreen(profileId: profile.id, mockData: widget.mockData),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F0E6),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: (profile.imageAsset != null && profile.imageAsset!.isNotEmpty)
                          ? Image.asset(
                              profile.imageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                                color: const Color(0xFF7A132B),
                                size: 30,
                              ),
                            )
                          : Icon(
                              profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                              color: const Color(0xFF7A132B),
                              size: 30,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Basic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.name,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Heart Icon Toggle (Tap to unlike and remove)
                          IconButton(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.favorite_rounded, color: Color(0xFFC62828), size: 22),
                            onPressed: () {
                              final pName = profile.name;
                              final pId = profile.id;
                              widget.mockData.toggleShortlist(pId);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "$pName விருப்பப்பட்டியலில் இருந்து நீக்கப்பட்டது",
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                  backgroundColor: const Color(0xFF580B23),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: "மீட்டெடு (Undo)",
                                    textColor: const Color(0xFFF3E5AB),
                                    onPressed: () {
                                      widget.mockData.toggleShortlist(pId);
                                    },
                                  ),
                                ),
                              );
                            },
                            tooltip: "விருப்பப்பட்டியலில் இருந்து நீக்குக (Unlike / Remove)",
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${profile.id} • ${profile.age} வயது • ${profile.star}",
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B585C), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${profile.rasi} • ${profile.location} • ${profile.occupation}",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8C797C)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status & Action Strip
          if (isUnlocked) ...[
            // UNLOCKED STATE: Compact strip showing Unlocked badge and View Contact Details button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8F4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                border: Border(top: BorderSide(color: Color(0xFFA5D6A7))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6B38).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B38), size: 14),
                        SizedBox(width: 5),
                        Text(
                          "Unlocked ✓",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B6B38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // View Unlocked Contact Details Action Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B38),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showUnlockedContactDetails(context, profile),
                    icon: const Icon(Icons.visibility_rounded, size: 14),
                    label: const Text(
                      "தொடர்பு பார்க்க / View",
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isPending) ...[
            // PENDING STATE: Awaiting Admin Approval
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF0),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                border: Border(top: BorderSide(color: Color(0xFFE5A93C))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: Color(0xFFB8860B), size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      "நிர்வாகி சரிபார்ப்பில் உள்ளது ⏳ (Pending Admin Approval)",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7A4B00)),
                    ),
                  ),
                  if (showAdminAction)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        final reqs = widget.mockData.pendingPaymentRequests;
                        if (reqs.isNotEmpty) {
                          widget.mockData.approvePaymentRequest(reqs.first.id);
                        }
                      },
                      child: const Text("ஒப்புதல் / Approve", style: TextStyle(fontSize: 11, color: Color(0xFF1B6B38), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ] else ...[
            // LOCKED STATE: Pay for all profiles together via the main cart payment button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDF9),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                border: Border(top: BorderSide(color: Color(0xFFEADBCE))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Color(0xFF7A132B), size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      "தொடர்பு எண்கள் & ஜாதகம் பூட்டப்பட்டுள்ளது",
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF6B585C), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "₹25",
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUnlockedContactDetails(BuildContext context, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
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

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF1B6B38), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF580B23),
                          ),
                        ),
                        const Text(
                          "தொடர்பு விவரங்கள் திறக்கப்பட்டது ✓ (Unlocked)",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B6B38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Phone & WhatsApp Cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Column(
                  children: [
                    // Phone Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.phone_rounded, color: Color(0xFF1B6B38), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "நேரடி தொலைபேசி / Mobile",
                                style: TextStyle(fontSize: 11, color: Color(0xFF6B585C)),
                              ),
                              Text(
                                profile.phone.isNotEmpty ? profile.phone : "+91 98421 11001",
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B6B38),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6B38),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Calling ${profile.phone}..."),
                                backgroundColor: const Color(0xFF1B6B38),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 14),
                          label: const Text("அழைக்க", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFA5D6A7)),
                    // WhatsApp Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chat_rounded, color: Color(0xFF128C7E), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "வாட்ஸ்அப் எண் / WhatsApp",
                                style: TextStyle(fontSize: 11, color: Color(0xFF6B585C)),
                              ),
                              Text(
                                profile.whatsapp.isNotEmpty ? profile.whatsapp : (profile.phone.isNotEmpty ? profile.phone : "+91 98421 11001"),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF128C7E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Connecting to WhatsApp: ${profile.whatsapp.isNotEmpty ? profile.whatsapp : profile.phone}..."),
                                backgroundColor: const Color(0xFF128C7E),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 14),
                          label: const Text("வாட்ஸ்அப்", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Family Details Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: Column(
                  children: [
                    _buildModalDetailRow(Icons.person_outline, "தந்தை / Father", profile.fatherName),
                    const Divider(height: 12, color: Color(0xFFEADBCE)),
                    _buildModalDetailRow(Icons.person_outline, "தாய் / Mother", profile.motherName),
                    const Divider(height: 12, color: Color(0xFFEADBCE)),
                    _buildModalDetailRow(Icons.people_outline, "உடன்பிறப்பு / Siblings", profile.siblings),
                    const Divider(height: 12, color: Color(0xFFEADBCE)),
                    _buildModalDetailRow(Icons.location_on_outlined, "குடும்ப இருப்பிடம்", profile.familyLocation),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Actions: View Full Profile & View Horoscope
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7A132B),
                        side: const BorderSide(color: Color(0xFF7A132B)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        HoroscopeCertificateDialog.show(context, profile, mockData: widget.mockData);
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 16),
                      label: const Text("ஜாதகம் / Horoscope", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF580B23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailsScreen(
                              profileId: profile.id,
                              mockData: widget.mockData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_rounded, size: 16),
                      label: const Text("முழு சுயவிவரம்", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF7A132B)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B585C), fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value.isNotEmpty ? value : "—",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
      ],
    );
  }
}

// Simulated High-Contrast QR Code Painter
class _ShortlistQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C1017)
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    _drawFinderPattern(canvas, 8, 8, paint);
    _drawFinderPattern(canvas, size.width - 42, 8, paint);
    _drawFinderPattern(canvas, 8, size.height - 42, paint);

    // Decorative modules grid
    const step = 8.5;
    for (double x = 10; x < size.width - 10; x += step) {
      for (double y = 10; y < size.height - 10; y += step) {
        final inTopLeft = x < 46 && y < 46;
        final inTopRight = x > size.width - 46 && y < 46;
        final inBottomLeft = x < 46 && y > size.height - 46;
        final inCenter = (x - size.width / 2).abs() < 22 && (y - size.height / 2).abs() < 22;

        if (!inTopLeft && !inTopRight && !inBottomLeft && !inCenter) {
          final hash = (x * 7 + y * 13).toInt() % 3;
          if (hash == 0 || hash == 1) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 6, 6), const Radius.circular(1.5)),
              paint,
            );
          }
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 34, 34), const Radius.circular(5)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 5, y + 5, 24, 24), const Radius.circular(3)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 10, y + 10, 14, 14), const Radius.circular(2)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
