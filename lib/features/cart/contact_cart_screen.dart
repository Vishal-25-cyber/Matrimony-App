import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_model.dart';
import '../../models/payment_request_model.dart';
import '../../services/mock_data_service.dart';
import '../profiles/profile_details_screen.dart';
import '../../core/utils/navigation_helper.dart';

class ContactCartScreen extends StatefulWidget {
  final MockDataService mockData;
  final int initialTabIndex;

  const ContactCartScreen({
    super.key,
    required this.mockData,
    this.initialTabIndex = 0,
  });

  @override
  State<ContactCartScreen> createState() => _ContactCartScreenState();
}

class _ContactCartScreenState extends State<ContactCartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _utrController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submittedSuccess = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabIndex.clamp(0, 2);
    _tabController = TabController(length: 3, vsync: this, initialIndex: initial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    final utr = _utrController.text.trim();
    if (utr.isEmpty) {
      setState(() {
        _errorMessage =
            "12-இலக்க UTR / Transaction ID உள்ளிடவும்\nPlease enter 12-digit UTR number";
      });
      return;
    }
    if (utr.length < 6) {
      setState(() {
        _errorMessage =
            "சரியான UTR எண்ணை உள்ளிடவும் (குறைந்தது 6 இலக்கங்கள்)\nPlease enter a valid UTR / Reference ID";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      widget.mockData.submitPaymentRequest(utrNumber: utr);
      setState(() {
        _isSubmitting = false;
        _submittedSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "கட்டணம் சமர்ப்பிக்கப்பட்டு தரவுத்தளத்தில் சேமிக்கப்பட்டது! (UTR: $utr)",
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B6B38),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  // Record a payment directly dialog
  void _showRecordPaymentDialog(BuildContext context) {
    final utrController = TextEditingController();
    final amountController = TextEditingController(text: "25");
    String selectedCandidateId = widget.mockData.allProfiles.isNotEmpty
        ? widget.mockData.allProfiles.first.id
        : "";
    String? recordError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        Icon(Icons.add_card_rounded, color: Color(0xFF7A132B), size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "புதிய கட்டண விவரம் பதிவு / Record Payment",
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
                      "Enter UTR reference to store your payment in database",
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
                    ),
                    const SizedBox(height: 16),

                    // Candidate Selection
                    const Text(
                      "வரன் தேர்வு / Select Candidate *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF580B23),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEADBCE)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCandidateId,
                          isExpanded: true,
                          items: widget.mockData.allProfiles.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                "${p.name} (${p.id}) • ${p.age} Yrs",
                                style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedCandidateId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // UTR Number Field
                    const Text(
                      "12-இலக்க UTR / Transaction Reference ID *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF580B23),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: utrController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "எ.கா: 426891045231 (12 digits UTR)",
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        prefixIcon: const Icon(Icons.receipt_long_rounded,
                            color: Color(0xFF7A132B), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFFDFBF7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF7A132B), width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount Field
                    const Text(
                      "செலுத்திய தொகை / Amount (₹) *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF580B23),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFF1B6B38), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFFDFBF7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFEADBCE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF1B6B38), width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),

                    if (recordError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        recordError!,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A132B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        final utr = utrController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim()) ?? 25.0;
                        if (utr.isEmpty) {
                          setModalState(() {
                            recordError = "UTR எண்ணை உள்ளிடவும் (Please enter UTR)";
                          });
                          return;
                        }
                        if (utr.length < 6) {
                          setModalState(() {
                            recordError =
                                "சரியான UTR எண்ணை உள்ளிடவும் (குறைந்தது 6 இலக்கங்கள்)";
                          });
                          return;
                        }

                        final candidate = widget.mockData.getProfileById(selectedCandidateId);
                        final candidateName = candidate != null
                            ? "${candidate.name} (${candidate.id})"
                            : selectedCandidateId;

                        widget.mockData.recordDirectPayment(
                          utrNumber: utr,
                          amount: amount,
                          profileIds: [selectedCandidateId],
                          profileNames: [candidateName],
                        );

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.cloud_done_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "✓ கட்டண விவரம் ($utr) தரவுத்தளத்தில் வெற்றிகரமாக சேமிக்கப்பட்டது!",
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1B6B38),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "தரவுத்தளத்தில் சேமிக்க / Save to Database",
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ],
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

  // Official Matrimony Receipt Dialog
  void _showReceiptDialog(BuildContext context, PaymentRequestModel payment) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
                  // Receipt Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7A132B),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "ப",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "பண்டாரத்தார் மணமாலை",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF580B23),
                            ),
                          ),
                          Text(
                            "அதிகாரப்பூர்வ கட்டண ரசீது / Official Receipt",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF7A686B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFEADBCE), thickness: 1),
                  const SizedBox(height: 8),

                  // MongoDB Verification Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6B38).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF1B6B38).withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded, size: 15, color: Color(0xFF1B6B38)),
                        SizedBox(width: 6),
                        Text(
                          "MongoDB Cloud Database Verified ✓",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B6B38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Details rows
                  _buildReceiptRow("ரசீது எண் / Receipt ID", payment.id),
                  _buildReceiptRow(
                    "தேதி & நேரம் / Date",
                    "${payment.timestamp.day.toString().padLeft(2, '0')}/${payment.timestamp.month.toString().padLeft(2, '0')}/${payment.timestamp.year} ${payment.timestamp.hour.toString().padLeft(2, '0')}:${payment.timestamp.minute.toString().padLeft(2, '0')}",
                  ),
                  _buildReceiptRow("செலுத்தியவர் / User", payment.userName),
                  _buildReceiptRow("கைபேசி / Mobile", payment.userPhone),
                  _buildReceiptRow(
                      "தேர்வு செய்யப்பட்ட வரன்", payment.profileNames.join(", ")),
                  _buildReceiptRow("UTR குறிப்பு எண் / Ref", payment.utrNumber),
                  _buildReceiptRow("செலுத்தும் முறை / Method", payment.paymentMethod),

                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFEADBCE), thickness: 1),
                  const SizedBox(height: 6),

                  // Total & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "மொத்த தொகை / Total Paid:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23),
                        ),
                      ),
                      Text(
                        "₹${payment.totalAmount.toInt()}.00",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B6B38),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "நிலை / Status:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A686B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: payment.status == 'approved'
                              ? const Color(0xFF1B6B38).withValues(alpha: 0.12)
                              : const Color(0xFFB8860B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          payment.status == 'approved'
                              ? "ஒப்புதல் பெற்றது ✓ (Approved)"
                              : "சரிபார்ப்பில் உள்ளது ⏳ (Pending)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: payment.status == 'approved'
                                ? const Color(0xFF1B6B38)
                                : const Color(0xFF7A4B00),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text:
                                  "Pandarathar Matrimony Receipt\nID: ${payment.id}\nUTR: ${payment.utrNumber}\nAmount: ₹${payment.totalAmount.toInt()}\nCandidate: ${payment.profileNames.join(', ')}\nDate: ${payment.timestamp}",
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("ரசீது விவரங்கள் நகலெடுக்கப்பட்டது (Copied)"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text("நகல் / Copy", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7A132B),
                            side: const BorderSide(color: Color(0xFF7A132B)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A132B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("சரி / Close",
                              style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1017),
              ),
            ),
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
        final cartItems = widget.mockData.cartProfiles;
        final totalAmount = widget.mockData.cartTotalAmount;
        final pendingRequests = widget.mockData.pendingPaymentRequests;
        final allPayments = widget.mockData.paymentRequests;
        final unlockedProfiles = widget.mockData.unlockedProfiles;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: "பின்செல்க / Back",
              onPressed: () => SafeNavigation.safePop(context, initialIndex: 3),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "எனது கட்டணங்கள் & தொடர்புகள்",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Payment Details • Unlocked Contacts • QR Cart",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFF0D68A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: "Record Payment UTR",
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: Color(0xFFF0D68A)),
                onPressed: () => _showRecordPaymentDialog(context),
              ),
              if (cartItems.isNotEmpty)
                IconButton(
                  tooltip: "Clear Cart",
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Color(0xFFF0D68A)),
                  onPressed: () => widget.mockData.clearCart(),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFD4AF37),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11.5),
              tabs: [
                Tab(
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  text: "கட்டணங்கள் (${allPayments.length})",
                ),
                Tab(
                  icon: const Icon(Icons.contacts_rounded, size: 20),
                  text: "தொடர்புகள் (${unlockedProfiles.length})",
                ),
                Tab(
                  icon: Badge(
                    isLabelVisible: cartItems.isNotEmpty,
                    label: Text(
                      "${cartItems.length}",
                      style: const TextStyle(fontSize: 9),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, size: 20),
                  ),
                  text: "கூடை / Cart",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Payment Details & Database History
              _buildPaymentDetailsTab(allPayments, unlockedProfiles),

              // Tab 2: Unlocked Contacts List
              _buildUnlockedContactsTab(unlockedProfiles),

              // Tab 3: Cart & UPI QR Payment
              _buildCartTab(cartItems, totalAmount, pendingRequests),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: PAYMENT DETAILS & DATABASE HISTORY
  // ==========================================
  Widget _buildPaymentDetailsTab(
    List<PaymentRequestModel> payments,
    List<ProfileModel> unlockedProfiles,
  ) {
    final totalSpent = payments.fold<double>(0, (sum, p) => sum + p.totalAmount);
    final approvedCount = payments.where((p) => p.status == 'approved').length;
    final pendingCount = payments.where((p) => p.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Database Status Header Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBF4ED), Color(0xFFFFF9F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEADBCE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_done_rounded,
                      color: Color(0xFF1B6B38), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            "சேமிக்கப்பட்ட கட்டண விவரங்கள்",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF580B23),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded,
                              size: 14, color: Color(0xFF1B6B38)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "MongoDB Database Synced & Stored Securely",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF1B6B38),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "அனைத்து கட்டண UTR எண்களும் தரவுத்தளத்தில் பாதுகாக்கப்படுகின்றன.",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A132B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showRecordPaymentDialog(context),
                  child: const Text(
                    "+ சேர்க்க",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Metrics Chips Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: "மொத்த கட்டணங்கள்",
                  value: "${payments.length}",
                  icon: Icons.receipt_rounded,
                  color: const Color(0xFF7A132B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: "செலுத்திய தொகை",
                  value: "₹${totalSpent.toInt()}",
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFF1B6B38),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: "ஒப்புதல் பெற்றது",
                  value: "$approvedCount / ${payments.length}",
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF00695C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "கட்டணப் பரிவர்த்தனைகள் (${payments.length})",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF580B23),
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Text(
                    "$pendingCount சரிபார்ப்பில்",
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Payments List
          if (payments.isEmpty)
            _buildEmptyPaymentsCard()
          else
            ...payments.map((p) => _buildPaymentCard(p)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF7A686B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRequestModel payment) {
    final isApproved = payment.status == 'approved';
    final isPending = payment.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? const Color(0xFFA5D6A7)
              : isPending
                  ? const Color(0xFFFFCC80)
                  : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Payment ID & Status Badge
          Row(
            children: [
              const Icon(Icons.receipt_rounded, size: 16, color: Color(0xFF7A132B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  payment.id,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF580B23),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFE8F5E9)
                      : isPending
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isApproved
                        ? const Color(0xFF81C784)
                        : isPending
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFFE57373),
                  ),
                ),
                child: Text(
                  isApproved
                      ? "ஒப்புதல் பெற்றது ✓ (Approved)"
                      : isPending
                          ? "சரிபார்ப்பில் உள்ளது ⏳ (Pending)"
                          : "நிராகரிக்கப்பட்டது ✗ (Rejected)",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isApproved
                        ? const Color(0xFF1B6B38)
                        : isPending
                            ? const Color(0xFFE65100)
                            : const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF3EAE0)),
          const SizedBox(height: 10),

          // Amount, UTR and Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("செலுத்திய தொகை",
                      style: TextStyle(fontSize: 10, color: Color(0xFF7A686B))),
                  Text(
                    "₹${payment.totalAmount.toInt()}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A132B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("UTR: ",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF580B23))),
                        Expanded(
                          child: Text(
                            payment.utrNumber,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B6B38),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: payment.utrNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("UTR எண் நகலெடுக்கப்பட்டது (Copied)"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.copy_rounded,
                                size: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${payment.timestamp.day}/${payment.timestamp.month}/${payment.timestamp.year} ${payment.timestamp.hour.toString().padLeft(2, '0')}:${payment.timestamp.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                        const Spacer(),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFBBEFCE)),
                          ),
                          child: const Text(
                            "MongoDB ✓",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B6B38),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Associated Profile(s)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDE0D5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 16, color: Color(0xFF7A132B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.profileNames.join(", "),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isApproved
                            ? "தொடர்பு எண்கள் திறக்கப்பட்டுள்ளது ✓"
                            : "நிர்வாகி சரிபார்த்து ஒப்புதல் அளித்ததும் தொடர்பு எண்கள் திறக்கப்படும்.",
                        style: TextStyle(
                          fontSize: 10,
                          color: isApproved
                              ? const Color(0xFF1B6B38)
                              : const Color(0xFF8C797C),
                          fontWeight: isApproved ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isApproved && payment.profileIds.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileDetailsScreen(
                            profileId: payment.profileIds.first,
                            mockData: widget.mockData,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "வரன் பார்க்க >",
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A132B)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Action: View Receipt
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showReceiptDialog(context, payment),
              icon: const Icon(Icons.receipt_long_rounded,
                  size: 14, color: Color(0xFF7A132B)),
              label: const Text(
                "ரசீது பார்க்க / View Receipt",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A132B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPaymentsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            "சேமிக்கப்பட்ட கட்டணங்கள் எதுவும் இல்லை",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
          ),
          const SizedBox(height: 4),
          const Text(
            "வரன்கள் கூடையில் சேர்க்கப்பட்டு செலுத்தப்படும் அல்லது பதிவு செய்யப்படும் கட்டண விவரங்கள் இங்கே தோன்றும்.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF7A686B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A132B),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _showRecordPaymentDialog(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text("புதிய கட்டணம் பதிவு செய்க"),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: UNLOCKED CONTACTS
  // ==========================================
  Widget _buildUnlockedContactsTab(List<ProfileModel> unlockedProfiles) {
    if (unlockedProfiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded,
                    size: 50, color: Color(0xFF7A132B)),
              ),
              const SizedBox(height: 16),
              const Text(
                "திறக்கப்பட்ட தொடர்புகள் இல்லை",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF580B23)),
              ),
              const SizedBox(height: 6),
              const Text(
                "No Unlocked Contacts Yet\nவரன்கள் பட்டியலில் இருந்து ₹25 கட்டணம் செலுத்திய பின் நிர்வாகி ஒப்புதல் அளித்ததும் நேரடி தொலைபேசி எண்கள் இங்கே தோன்றும்.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF6B585C), height: 1.4),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _tabController.animateTo(2); // Switch to Cart tab
                },
                child: const Text("தொடர்பு கூடைக்கு செல்ல / Go to Cart"),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B6B38).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF1B6B38).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: Color(0xFF1B6B38), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "திறக்கப்பட்ட தொடர்புகள் (${unlockedProfiles.length}) • நீங்கள் நேரடியாக அழைக்கலாம்",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B6B38),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ...unlockedProfiles.map((p) => _buildUnlockedProfileCard(p)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUnlockedProfileCard(ProfileModel profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBCE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Candidate row: Avatar, Name, Age, Location
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F0E6),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: (profile.displayImageAsset != null &&
                          profile.displayImageAsset!.isNotEmpty)
                      ? Image.asset(
                          profile.displayImageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            profile.gender.toLowerCase() == 'bride'
                                ? Icons.person_3_rounded
                                : Icons.person_rounded,
                            color: const Color(0xFF7A132B),
                            size: 28,
                          ),
                        )
                      : Icon(
                          profile.gender.toLowerCase() == 'bride'
                              ? Icons.person_3_rounded
                              : Icons.person_rounded,
                          color: const Color(0xFF7A132B),
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.name} (${profile.nameTamil ?? ''})",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF580B23),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${profile.id} • ${profile.age} Yrs • ${profile.star ?? ''}",
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xFF6B585C)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.location,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF8C797C)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "திறக்கப்பட்டது ✓",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B6B38),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Unlocked Contact Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Column(
              children: [
                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 16, color: Color(0xFF1B6B38)),
                    const SizedBox(width: 8),
                    const Text(
                      "தொலைபேசி:",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF2C5E3B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B6B38),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // WhatsApp
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: Color(0xFF1B6B38)),
                    const SizedBox(width: 8),
                    const Text(
                      "வாட்ஸ்அப்:",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF2C5E3B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile.whatsapp,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B6B38),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Call, WhatsApp, View Profile
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Calling ${profile.phone}..."),
                          backgroundColor: const Color(0xFF1B6B38),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, size: 15),
                    label: const Text("அழைக்க / Call",
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7A132B),
                      side: const BorderSide(color: Color(0xFF7A132B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onPressed: () {
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
                    icon: const Icon(Icons.visibility_rounded, size: 15),
                    label: const Text("வரன் விவரம்",
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold)),
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
  // TAB 3: CART & QR PAYMENT
  // ==========================================
  Widget _buildCartTab(
    List<ProfileModel> cartItems,
    double totalAmount,
    List<PaymentRequestModel> pendingRequests,
  ) {
    if (_submittedSuccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B38).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    size: 58, color: Color(0xFF1B6B38)),
              ),
              const SizedBox(height: 18),
              const Text(
                "கட்டணம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B6B38),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "உங்கள் UTR குறிப்பு எண் தரவுத்தளத்தில் சேமிக்கப்பட்டு நிர்வாகிக்கு அனுப்பப்பட்டுள்ளது. நிர்வாகி சரிபார்த்து ஒப்புதல் அளித்ததும் தேர்ந்தெடுக்கப்பட்ட வரன்களின் தொடர்பு விவரங்கள் உடனடியாக திறக்கப்படும்.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF58484B), height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    _submittedSuccess = false;
                    _utrController.clear();
                  });
                  _tabController.animateTo(0); // Switch to Payment History tab!
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text(
                  "சேமிக்கப்பட்ட கட்டணங்களை பார்க்க / View Payments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (cartItems.isEmpty && pendingRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart_outlined,
                    size: 54, color: Color(0xFF7A132B)),
              ),
              const SizedBox(height: 16),
              const Text(
                "தொடர்பு கூடை காலியாக உள்ளது",
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF580B23),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your Contact Cart is Empty\nவரன்கள் பட்டியலில் இருந்து 'தொடர்பு பெற (₹25)' தேர்வு செய்யவும்.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF6B585C), height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("வரன்களை பார்க்க / Browse Matches"),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pending Approvals Banner (if any)
          if (pendingRequests.isNotEmpty) ...[
            _buildPendingRequestsBanner(pendingRequests),
            const SizedBox(height: 16),
          ],

          if (cartItems.isNotEmpty) ...[
            // 1. Cart Items Summary Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "தேர்ந்தெடுக்கப்பட்ட வரன்கள் (${cartItems.length})",
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF580B23),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF7A132B).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    "மொத்தம்: ₹${totalAmount.toInt()}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A132B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. Selected Profiles List Cards
            ...cartItems.map((profile) => _buildCartItemCard(profile)),

            const SizedBox(height: 18),

            // 3. Official UPI QR Code Payment Section
            _buildQrPaymentCard(cartItems.length, totalAmount),

            const SizedBox(height: 16),

            // 4. UTR Submission Field & Confirm Button
            _buildUtrSubmissionSection(),

            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  // Cart item card with thumbnail, name, ID, price and remove button
  Widget _buildCartItemCard(ProfileModel profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F0E6),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: (profile.displayImageAsset != null &&
                      profile.displayImageAsset!.isNotEmpty)
                  ? Image.asset(
                      profile.displayImageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        profile.gender.toLowerCase() == 'bride'
                            ? Icons.person_3_rounded
                            : Icons.person_rounded,
                        color: const Color(0xFF7A132B),
                        size: 28,
                      ),
                    )
                  : Icon(
                      profile.gender.toLowerCase() == 'bride'
                          ? Icons.person_3_rounded
                          : Icons.person_rounded,
                      color: const Color(0xFF7A132B),
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${profile.name} (${profile.nameTamil ?? ''})",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF580B23),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${profile.id} • ${profile.age} Yrs • ${profile.star ?? ''}",
                  style:
                      const TextStyle(fontSize: 11.5, color: Color(0xFF6B585C)),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.location,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8C797C)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "₹25",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B6B38),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => widget.mockData.removeFromCart(profile.id),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child:
                      Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Admin UPI QR Code Card
  Widget _buildQrPaymentCard(int count, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF580B23).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, color: Color(0xFF7A132B), size: 24),
              SizedBox(width: 8),
              Text(
                "நிர்வாகி UPI QR குறியீடு / Admin UPI QR",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A132B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Scan & Pay using GPay / PhonePe / Paytm / UPI",
            style: TextStyle(fontSize: 11, color: Color(0xFF6B585C)),
          ),
          const SizedBox(height: 14),

          // Custom Rendered UPI QR Code Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Custom Simulated High-Contrast QR Pattern with Center Logo
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated QR Pattern Grid
                      CustomPaint(
                        size: const Size(170, 170),
                        painter: _AdminQrPainter(),
                      ),
                      // Center Logo Medallion
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A132B),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            "ப",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Merchant Details Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF4ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "UPI ID: pandaratharmatrimony@upi",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "செலுத்த வேண்டிய தொகை: ₹${totalAmount.toInt()} ($count வரன்கள்)",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B6B38),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_rounded, size: 14, color: Color(0xFF1B6B38)),
              SizedBox(width: 4),
              Text(
                "பாதுகாப்பான UPI கட்டணம் • நிர்வாகி நேரடி அனுமதி",
                style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF1B6B38),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UTR / Transaction ID submission
  Widget _buildUtrSubmissionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "பணம் செலுத்திய விவரம் / Payment Reference",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF580B23),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "QR ஸ்கேன் செய்து செலுத்திய பின் 12-இலக்க UTR / Transaction Ref ID உள்ளிடவும்:",
            style: TextStyle(fontSize: 11, color: Color(0xFF6B585C)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _utrController,
            decoration: InputDecoration(
              hintText: "எ.கா: 426891045231 (12 digits UTR)",
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.receipt_long_rounded,
                  color: Color(0xFF7A132B), size: 20),
              filled: true,
              fillColor: const Color(0xFFFDFBF7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD4AF37)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8D6C6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF7A132B), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                  fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A132B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: _isSubmitting ? null : _submitPayment,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "ஒப்புதலுக்கு அனுப்புக / Submit for Approval",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Pending requests status banner
  Widget _buildPendingRequestsBanner(List<PaymentRequestModel> pendingRequests) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5A93C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded,
                  color: Color(0xFFB8860B), size: 20),
              const SizedBox(width: 8),
              Text(
                "நிர்வாகி ஒப்புதலுக்கு காத்திருக்கிறது (${pendingRequests.length})",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A4B00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "நீங்கள் சமர்ப்பித்த QR கட்டணம் நிர்வாகியால் சரிபார்க்கப்பட்டு வருகிறது. ஒப்புதல் கிடைத்தவுடன் தொடர்பு எண்கள் தானாகவே திறக்கப்படும்.",
            style:
                TextStyle(fontSize: 11.5, color: Color(0xFF5A4420), height: 1.3),
          ),
        ],
      ),
    );
  }
}

// Simulated QR pattern painter
class _AdminQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C1017)
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    _drawFinderPattern(canvas, 10, 10, paint);
    _drawFinderPattern(canvas, size.width - 45, 10, paint);
    _drawFinderPattern(canvas, 10, size.height - 45, paint);

    // Decorative modules grid
    const step = 9.0;
    for (double x = 12; x < size.width - 12; x += step) {
      for (double y = 12; y < size.height - 12; y += step) {
        // Skip corner finder areas and center logo
        final inTopLeft = x < 50 && y < 50;
        final inTopRight = x > size.width - 50 && y < 50;
        final inBottomLeft = x < 50 && y > size.height - 50;
        final inCenter = (x - size.width / 2).abs() < 24 &&
            (y - size.height / 2).abs() < 24;

        if (!inTopLeft && !inTopRight && !inBottomLeft && !inCenter) {
          final hash = (x * 7 + y * 13).toInt() % 3;
          if (hash == 0 || hash == 1) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(x, y, 6.5, 6.5), const Radius.circular(1.5)),
              paint,
            );
          }
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, Paint paint) {
    // Outer box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 36, 36), const Radius.circular(6)),
      paint,
    );
    // Inner white
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, y + 5, 26, 26), const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    // Center square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 10, y + 10, 16, 16), const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
