import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';

class HoroscopeUnlockDialog extends StatefulWidget {
  final ProfileModel profile;
  final MockDataService mockData;
  final VoidCallback? onUnlocked;

  const HoroscopeUnlockDialog({
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
      builder: (_) => HoroscopeUnlockDialog(
        profile: profile,
        mockData: mockData,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  State<HoroscopeUnlockDialog> createState() => _HoroscopeUnlockDialogState();
}

class _HoroscopeUnlockDialogState extends State<HoroscopeUnlockDialog> {
  String _selectedPlan = 'horoscope'; // 'horoscope' (₹25) or 'combo' (₹40)
  String _selectedPaymentMethod = 'gpay';
  bool _isProcessing = false;
  bool _isSuccess = false;

  int get _amount => _selectedPlan == 'horoscope' ? 25 : 40;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (_selectedPlan == 'combo') {
      widget.mockData.unlockAll(widget.profile.id);
    } else {
      widget.mockData.unlockHoroscope(widget.profile.id);
    }

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
                _selectedPlan == 'combo'
                    ? "${widget.profile.name} ஜாதகம் & தொடர்பு விவரங்கள் திறக்கப்பட்டது! (All Unlocked)"
                    : "${widget.profile.name} ஜாதகக் குறிப்புகள் திறக்கப்பட்டது! (Horoscope Unlocked)",
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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

            const SizedBox(height: 14),

            // Header with Auspicious Golden Theme
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: const Icon(Icons.history_edu_rounded, color: Color(0xFF8C1D38), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "முழு ஜாதகம் & கட்டங்கள் திறப்பு",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      Text(
                        "Unlock Full Horoscope & Charts • ${profile.id}",
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

            const SizedBox(height: 14),

            // Candidate Mini Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEADFD4)),
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
                      width: 50,
                      height: 50,
                      color: const Color(0xFFF9F0E6),
                      child: (profile.displayImageAsset != null && profile.displayImageAsset!.isNotEmpty)
                          ? Image.asset(
                              profile.displayImageAsset!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                                color: const Color(0xFF7A132B),
                                size: 26,
                              ),
                            )
                          : Icon(
                              profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                              color: const Color(0xFF7A132B),
                              size: 26,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF331D22)),
                        ),
                        Text(
                          "${profile.age} Yrs • ${profile.star ?? 'Rohini'} • ${profile.location}",
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B5458)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "₹$_amount",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Plan Selector: Horoscope Only (₹25) vs Combo (₹40)
            const Text(
              "திட்டத்தைத் தேர்ந்தெடுக்கவும் / Choose Plan:",
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF4C3E41)),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPlan = 'horoscope'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedPlan == 'horoscope' ? const Color(0xFFFFF9E6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPlan == 'horoscope' ? const Color(0xFFD4AF37) : const Color(0xFFE2D6CB),
                          width: _selectedPlan == 'horoscope' ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "ஜாதகம் மட்டும்",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              ),
                              Icon(
                                _selectedPlan == 'horoscope' ? Icons.check_circle_rounded : Icons.circle_outlined,
                                size: 16,
                                color: _selectedPlan == 'horoscope' ? const Color(0xFF7A132B) : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "ராசி & நவாம்சக் கட்டம்",
                              style: TextStyle(fontSize: 10, color: Color(0xFF7E6F72)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "₹25",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPlan = 'combo'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedPlan == 'combo' ? const Color(0xFFFFF9E6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPlan == 'combo' ? const Color(0xFFD4AF37) : const Color(0xFFE2D6CB),
                          width: _selectedPlan == 'combo' ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "முழு விவரங்கள்",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              ),
                              Icon(
                                _selectedPlan == 'combo' ? Icons.check_circle_rounded : Icons.circle_outlined,
                                size: 16,
                                color: _selectedPlan == 'combo' ? const Color(0xFF7A132B) : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "ஜாதகம் + தொலைபேசி",
                              style: TextStyle(fontSize: 10, color: Color(0xFF7E6F72)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "₹40 (சேமிப்பு ₹10)",
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // What will be unlocked list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2D6CB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "திறக்கப்படும் விவரங்கள் / What will be unlocked:",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF4C3E41)),
                  ),
                  const SizedBox(height: 8),
                  _buildUnlockItem(Icons.grid_on_rounded, "ராசி & நவாம்சக் கட்டங்கள் (12 பாவங்கள் & கிரக நிலைகள்)"),
                  _buildUnlockItem(Icons.auto_stories_rounded, "முழு அங்கீகரிக்கப்பட்ட ஜாதகச் சான்றிதழ் PDF"),
                  _buildUnlockItem(Icons.stars_rounded, "10 திருமணப் பொருத்தங்கள் விரிவான ஆய்வு அறிக்கை"),
                  _buildUnlockItem(Icons.shield_outlined, "செவ்வாய், ராகு-கேது தோஷ முழு விவரங்கள்"),
                  if (_selectedPlan == 'combo')
                    _buildUnlockItem(Icons.phone_rounded, "நேரடி தொலைபேசி, வாட்ஸ்அப் & மின்னஞ்சல் முகவரி"),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Payment Options
            const Text(
              "கட்டண முறை / Payment Method:",
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF4C3E41)),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildPayOption(
                    id: 'gpay',
                    label: 'Google Pay',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPayOption(
                    id: 'phonepe',
                    label: 'PhonePe',
                    icon: Icons.payments_rounded,
                    iconColor: const Color(0xFF5F259F),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPayOption(
                    id: 'card',
                    label: 'Card / Net',
                    icon: Icons.credit_card_rounded,
                    iconColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Pay Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C1D38),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "கட்டணம் செயலாக்கப்படுகிறது...",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : _isSuccess
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text("வெற்றி! ஜாதகம் திறக்கப்பட்டது ✓", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_open_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "₹$_amount செலுத்தி ஜாதகம் திறக்க / Pay & Unlock",
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                ),
              ),
            ),


            const SizedBox(height: 10),

            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.security_rounded, size: 13, color: Color(0xFF7A6B6E)),
                SizedBox(width: 6),
                Text(
                  "100% பாதுகாப்பான பரிவர்த்தனை • UPI / Razorpay Secure",
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6B6E)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1B6B38)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF332225), height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayOption({
    required String id,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFFDDD2C8),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF8C1D38) : const Color(0xFF4C3E41),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
