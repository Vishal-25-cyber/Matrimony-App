import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../features/contacts/unlocked_contact_screen.dart';

class ContactUnlockDialog extends StatefulWidget {
  final ProfileModel profile;
  final MockDataService mockData;
  final VoidCallback? onUnlocked;

  const ContactUnlockDialog({
    super.key,
    required this.profile,
    required this.mockData,
    this.onUnlocked,
  });

  static void show(
    BuildContext context, {
    required ProfileModel profile,
    required MockDataService mockData,
    VoidCallback? onUnlocked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ContactUnlockDialog(
        profile: profile,
        mockData: mockData,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  State<ContactUnlockDialog> createState() => _ContactUnlockDialogState();
}

class _ContactUnlockDialogState extends State<ContactUnlockDialog> {
  bool _isProcessing = false;
  String? _errorMsg;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController(text: '25');
  final _utrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.mockData.currentUser.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final utr = _utrController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 25.0;

    if (utr.isEmpty) {
      setState(() => _errorMsg = 'Transaction ID / UTR உள்ளிடவும்');
      return;
    }
    if (utr.length < 6) {
      setState(() => _errorMsg = 'குறைந்தது 6 எழுத்துக்கள் தேவை');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });

    widget.mockData.submitPaymentRequestWithDetails(
      userName: name,
      amount: amount,
      utrNumber: utr,
      profileIds: [widget.profile.id],
      profileNames: ['${widget.profile.name} (${widget.profile.id})'],
    );

    if (!mounted) return;

    Navigator.pop(context);
    widget.onUnlocked?.call();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnlockedContactScreen(
          profile: widget.mockData.getProfileById(widget.profile.id)!,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "${widget.profile.name} தொடர்பு திறக்கப்பட்டது! ✓",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B6B38),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ──
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Header row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF8C1D38).withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.qr_code_rounded,
                      color: Color(0xFF8C1D38), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "தொடர்பு விவரங்கள் திறப்பு",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF580B23)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${profile.id} • ₹25 • Contact Unlock",
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E6F72),
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Candidate Card ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADFD4)),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F0E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                                size: 24,
                              ),
                            )
                          : Icon(
                              profile.gender.toLowerCase() == 'bride'
                                  ? Icons.person_3_rounded
                                  : Icons.person_rounded,
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
                        Text(
                          profile.name,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF331D22)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${profile.age} Yrs • ${profile.star ?? 'Rohini'} • ${profile.location}",
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B5458)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "₹25",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── QR + UPI Card ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF580B23).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Scan & Pay  •  GPay / PhonePe / Paytm / BHIM",
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7A686B),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // QR Code
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFEADBCE), width: 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(160, 160),
                          painter: _ContactQrPainter(),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A132B),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFD4AF37), width: 1.5),
                          ),
                          child: const Center(
                            child: Text("ப",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // UPI ID chip
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(
                          text: "pandaratharmatrimony@upi"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("UPI ID நகலெடுக்கப்பட்டது!"),
                          duration: Duration(seconds: 1),
                          backgroundColor: Color(0xFF1B6B38),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF4EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8D7C8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 14, color: Color(0xFF580B23)),
                          SizedBox(width: 6),
                          Text(
                            "UPI ID: pandaratharmatrimony@upi",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF580B23)),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.copy_rounded,
                              size: 14, color: Color(0xFF7A132B)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Payment Details Section Header ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7A132B).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.12)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.edit_note_rounded,
                      size: 18, color: Color(0xFF580B23)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "கட்டண விவரங்கள் / Enter Payment Details",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "* அனைத்தும் கட்டாயம்",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7A132B),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Form Fields ──
            _buildLabel("செலுத்துபவர் பெயர் / Payment User Name *"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _nameController,
              hint: "உங்கள் பெயர் / Your Name",
              icon: Icons.person_outline_rounded,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 12),

            _buildLabel("செலுத்தப்பட்ட தொகை / Amount Paid (₹) *"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _amountController,
              hint: "25",
              icon: Icons.currency_rupee_rounded,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            _buildLabel("பரிவர்த்தனை எண் / Transaction ID / UTR *"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _utrController,
              hint: "12-digit UTR / Transaction Reference",
              icon: Icons.receipt_long_rounded,
              inputType: TextInputType.text,
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // ── Submit Button ──
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C1D38),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 10),
                          Text("சேமிக்கிறது...",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 10),
                          Text(
                            "ஒப்புதலுக்கு சமர்ப்பிக்கவும் / Submit",
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF580B23)),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType inputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C1017)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFB0A0A5)),
        prefixIcon: Icon(icon, color: const Color(0xFF7A132B), size: 20),
        filled: true,
        fillColor: const Color(0xFFFDFBF7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4AF37))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD0C8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF7A132B), width: 1.5)),
      ),
    );
  }
}

// ── QR Painter ──
class _ContactQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C1017)
      ..style = PaintingStyle.fill;

    _drawFinder(canvas, 8, 8, paint);
    _drawFinder(canvas, size.width - 38, 8, paint);
    _drawFinder(canvas, 8, size.height - 38, paint);

    const step = 8.0;
    for (double x = 10; x < size.width - 10; x += step) {
      for (double y = 10; y < size.height - 10; y += step) {
        final inTL = x < 42 && y < 42;
        final inTR = x > size.width - 42 && y < 42;
        final inBL = x < 42 && y > size.height - 42;
        final inCenter =
            (x - size.width / 2).abs() < 20 && (y - size.height / 2).abs() < 20;
        if (!inTL && !inTR && !inBL && !inCenter) {
          final hash = (x * 7 + y * 13).toInt() % 3;
          if (hash == 0 || hash == 1) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(x, y, 5.5, 5.5), const Radius.circular(1.2)),
              paint,
            );
          }
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 30, 30), const Radius.circular(5)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 4, y + 4, 22, 22), const Radius.circular(3)),
        Paint()..color = Colors.white);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 8, y + 8, 14, 14), const Radius.circular(2)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
