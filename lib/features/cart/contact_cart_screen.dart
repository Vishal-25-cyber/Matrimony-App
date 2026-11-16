import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_model.dart';
import '../../models/payment_request_model.dart';
import '../../services/mock_data_service.dart';
import '../profiles/profile_details_screen.dart';
import '../../core/utils/navigation_helper.dart';

class ContactCartScreen extends StatefulWidget {
  final MockDataService mockData;

  const ContactCartScreen({
    super.key,
    required this.mockData,
  });

  @override
  State<ContactCartScreen> createState() => _ContactCartScreenState();
}

class _ContactCartScreenState extends State<ContactCartScreen> {
  final _utrController = TextEditingController();

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
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

                  // Verified Badge
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
                          "பாதுகாப்பாக சேமிக்கப்பட்டது ✓ Securely Stored",
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
        final allPayments = widget.mockData.currentUserPaymentRequests;
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
            title: const Text(
              "எனது கட்டணங்கள்",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: _buildPaymentDetailsTab(allPayments, unlockedProfiles),
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
          // Payments summary header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEADBCE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B38).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Color(0xFF1B6B38), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "சேமிக்கப்பட்ட கட்டண விவரங்கள்",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "அனைத்து UTR எண்களும் பாதுகாப்பாக சேமிக்கப்படுகின்றன",
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF7A686B)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, size: 18, color: const Color(0xFF1B6B38)),
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
                        Expanded(
                          child: Text(
                            "${payment.timestamp.day}/${payment.timestamp.month}/${payment.timestamp.year} ${payment.timestamp.hour.toString().padLeft(2, '0')}:${payment.timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
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
                            : "தொடர்பு எண்கள் திறக்கப்பட்டுள்ளது ✓",
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

}
