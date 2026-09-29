import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../main_navigation_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'Tamil';

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Top Emblem / Crest with ornamental header line
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle background arch curve
                    Container(
                      width: 280,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Royal Crest
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E0824).withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/app_crest.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Tamil Title
              const Text(
                AppConstants.appNameTamil,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF580B23),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 4),

              // English Subtitle
              const Text(
                AppConstants.appNameEnglish,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: Color(0xFF9E7522),
                ),
              ),

              const SizedBox(height: 8),

              // Ornamental divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 1,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 14,
                      color: Color(0xFF9E7522),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 1,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tagline in Tamil (Italic)
              const Text(
                AppConstants.taglineTamil,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF751A2F),
                ),
              ),

              const SizedBox(height: 3),

              // Tagline in English
              const Text(
                AppConstants.taglineEnglish,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF5A484C),
                ),
              ),

              const SizedBox(height: 16),

              // Featured Arch Frame Couple Card
              Container(
                width: double.infinity,
                height: 370,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(160),
                    topRight: Radius.circular(160),
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E0824).withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(158),
                    topRight: Radius.circular(158),
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
                      Image.asset(
                        'assets/images/wedding_couple.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.45),
                      ),

                      // Decorative mandala corner accents at top
                      Positioned(
                        top: 24,
                        left: 20,
                        child: Icon(
                          Icons.grain_rounded,
                          size: 22,
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        right: 20,
                        child: Icon(
                          Icons.grain_rounded,
                          size: 22,
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                        ),
                      ),

                      // Floating pill badge at bottom
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF4ED).withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE8D6C5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    size: 16,
                                    color: Color(0xFF580B23),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "பொருத்தமான வரன்கள்",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E171B),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "10/10 Porutham",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF580B23),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 100% Verified Community Profiles banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF1E7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF5DEC9),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCE1CA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFB07B1C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "100% Verified Community Profiles",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C0F1D),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "பாரம்பரியம் & குடும்ப நற்பண்பு அரவணைப்பு",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF755E61),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Language Toggle (தமிழ் | English)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E6DC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = 'Tamil'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'Tamil'
                              ? const Color(0xFF580B23)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "தமிழ்",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _selectedLanguage == 'Tamil'
                                ? Colors.white
                                : const Color(0xFF5E494D),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = 'English'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'English'
                              ? const Color(0xFF580B23)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "English",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _selectedLanguage == 'English'
                                ? Colors.white
                                : const Color(0xFF5E494D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Primary Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _navigateToMain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF580B23),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadowColor: const Color(0xFF580B23).withValues(alpha: 0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "உள்நுழைக / Login",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Register Free Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _navigateToRegister,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF580B23),
                    side: const BorderSide(
                      color: Color(0xFFE5D5C8),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_outlined, size: 18, color: Color(0xFF580B23)),
                      SizedBox(width: 8),
                      Text(
                        "புதிய பதிவு / Register Free",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF580B23),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Security & Privacy Note
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xFF8A777A),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Strictly Private & Family Protected Profiles",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A777A),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
