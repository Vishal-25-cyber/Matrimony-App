import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import 'unlocked_contact_screen.dart';
import '../../core/utils/navigation_helper.dart';

class ContactUnlockScreen extends StatefulWidget {
  final ProfileModel profile;
  final MockDataService mockData;

  const ContactUnlockScreen({
    super.key,
    required this.profile,
    required this.mockData,
  });

  @override
  State<ContactUnlockScreen> createState() => _ContactUnlockScreenState();
}

class _ContactUnlockScreenState extends State<ContactUnlockScreen> {
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
      setState(() => _errorMsg = 'பரிவர்த்தனை எண்ணை உள்ளிடவும் (Enter Transaction ID)');
      return;
    }
    if (utr.length < 6) {
      setState(() => _errorMsg = 'சரியான Transaction ID உள்ளிடவும் (குறைந்தது 6 எழுத்துக்கள்)');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });

    // Store payment & immediately unlock — no admin approval needed
    widget.mockData.submitPaymentRequestWithDetails(
      userName: name,
      amount: amount,
      utrNumber: utr,
      profileIds: [widget.profile.id],
      profileNames: ['${widget.profile.name} (${widget.profile.id})'],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('கட்டணம் பதிவு செய்யப்பட்டது! தொடர்பு திறக்கப்பட்டது ✓'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UnlockedContactScreen(
          profile: widget.mockData.getProfileById(widget.profile.id)!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: () => SafeNavigation.safePop(context, initialIndex: 3),
        ),
        title: const Text(
          'தொடர்பு திறப்பு / Unlock Contact',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGoldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGold, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.accentGoldDark, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${widget.profile.name} (${widget.profile.id}) • கூடையில் உள்ள மொத்த வரன்கள்: 1 • ஒரு வரன் கட்டணம்: ${AppConstants.contactUnlockPrice}',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.accentGoldDark, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '₹25',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // QR Code + UPI Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Scan & Pay using GPay / PhonePe / Paytm / BHIM",
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF7A686B), fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(size: const Size(180, 180), painter: _QrPainter()),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7A132B),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              ),
                              child: const Center(
                                child: Text("ப", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: "pandaratharmatrimony@upi"));
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF4EE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8D7C8)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "UPI ID: pandaratharmatrimony@upi",
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.copy_rounded, size: 15, color: Color(0xFF7A132B)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Payment Details Form Header (Safe & Responsive, No Overflow) ──
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "கட்டண விவரங்கள் / Enter Payment Details:",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A132B).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "அனைத்தும் கட்டாயம் *",
                        style: TextStyle(fontSize: 10, color: Color(0xFF7A132B), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User Name
                _buildLabel("செலுத்துபவர் பெயர் / Payment User Name *"),
                const SizedBox(height: 5),
                _buildField(controller: _nameController, hint: "உங்கள் பெயர்", icon: Icons.person_outline_rounded, type: TextInputType.name),
                const SizedBox(height: 12),

                // Amount
                _buildLabel("செலுத்தப்பட்ட தொகை / Amount Paid (₹) *"),
                const SizedBox(height: 5),
                _buildField(controller: _amountController, hint: "25", icon: Icons.currency_rupee_rounded, type: TextInputType.number),
                const SizedBox(height: 12),

                // UTR
                _buildLabel("பரிவர்த்தனை எண் / Transaction ID / UTR *"),
                const SizedBox(height: 5),
                _buildField(controller: _utrController, hint: "12-digit UTR / Transaction Reference", icon: Icons.receipt_long_rounded, type: TextInputType.text),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMsg!, style: const TextStyle(fontSize: 11.5, color: Colors.red, fontWeight: FontWeight.bold)),
                ],

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C1D38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 10),
                              Text("சேமிக்கிறது...", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18),
                              SizedBox(width: 10),
                              Text(
                                "ஒப்புதலுக்கு சமர்ப்பிக்கவும் / Submit",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF580B23)),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C1017)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF7A132B), size: 20),
        filled: true,
        fillColor: const Color(0xFFFDFBF7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEADBCE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7A132B), width: 1.5)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2C1017)..style = PaintingStyle.fill;
    _drawFinder(canvas, 8, 8, paint);
    _drawFinder(canvas, size.width - 38, 8, paint);
    _drawFinder(canvas, 8, size.height - 38, paint);
    const step = 8.0;
    for (double x = 10; x < size.width - 10; x += step) {
      for (double y = 10; y < size.height - 10; y += step) {
        final inTL = x < 42 && y < 42;
        final inTR = x > size.width - 42 && y < 42;
        final inBL = x < 42 && y > size.height - 42;
        final inCenter = (x - size.width / 2).abs() < 22 && (y - size.height / 2).abs() < 22;
        if (!inTL && !inTR && !inBL && !inCenter) {
          final hash = (x * 7 + y * 13).toInt() % 3;
          if (hash == 0 || hash == 1) {
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 5.5, 5.5), const Radius.circular(1.2)), paint);
          }
        }
      }
    }
  }
  void _drawFinder(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 30, 30), const Radius.circular(5)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 4, y + 4, 22, 22), const Radius.circular(3)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 8, y + 8, 14, 14), const Radius.circular(2)), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
