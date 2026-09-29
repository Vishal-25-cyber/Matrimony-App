import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';

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
  bool _isSuccess = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 900));

    widget.mockData.unlockContact(widget.profile.id);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pop(context);
    widget.onUnlocked?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "${widget.profile.name} தொடர்பு விவரங்கள் திறக்கப்பட்டது! ✓ (Unlocked)",
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

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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

            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8C1D38).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF8C1D38), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "தொடர்பு விவரங்கள் திறப்பு",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      Text(
                        "${profile.id} • ₹25",
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF7E6F72), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Candidate Mini Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADFD4)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFF9F0E6),
                      child: (profile.imageAsset != null && profile.imageAsset!.isNotEmpty)
                          ? Image.asset(
                              profile.imageAsset!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                                color: const Color(0xFF7A132B),
                                size: 24,
                              ),
                            )
                          : Icon(
                              profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
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
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF331D22)),
                        ),
                        Text(
                          "${profile.age} Yrs • ${profile.star ?? 'Rohini'} • ${profile.location}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B5458)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "₹25",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Official UPI QR Code Card (Minimal & Clean)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF580B23).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawn QR Code with center logo
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(170, 170),
                          painter: _ContactQrPainter(),
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

                  const SizedBox(height: 14),

                  // UPI ID with Copy Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF4EE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8D7C8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "UPI ID: pandarathar@upi",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: "pandarathar@upi"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("UPI ID நகலெடுக்கப்பட்டது! (pandarathar@upi)"),
                                duration: Duration(seconds: 1),
                                backgroundColor: Color(0xFF1B6B38),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF7A132B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pay Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing || _isSuccess ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C1D38),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text("கட்டணம் சரிபார்க்கப்படுகிறது..."),
                          ],
                        )
                      : _isSuccess
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text("வெற்றிகரமானது! தொடர்பு திறக்கப்பட்டது ✓"),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_open_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "₹25 செலுத்தி தொடர்பை திறக்கவும்",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        final inCenter = (x - size.width / 2).abs() < 20 && (y - size.height / 2).abs() < 20;

        if (!inTL && !inTR && !inBL && !inCenter) {
          final hash = (x * 7 + y * 13).toInt() % 3;
          if (hash == 0 || hash == 1) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 5.5, 5.5), const Radius.circular(1.2)),
              paint,
            );
          }
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 30, 30), const Radius.circular(5)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + 4, y + 4, 22, 22), const Radius.circular(3)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + 8, y + 8, 14, 14), const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
