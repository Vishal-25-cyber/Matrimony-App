import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/navigation_helper.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
          onPressed: () => SafeNavigation.safePop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "தொடர்பு கொள்ள",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "Contact Us",
              style: TextStyle(fontSize: 10, color: Color(0xFFF0D68A), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Address Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded, color: Color(0xFF7A132B), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "எங்கள் முகவரி / Our Office Address",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A132B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "பஸ் நிலையம் பின்புறம், காமாட்சி லாட்ஜ் எதிரில், அருக்காணி உணவகம் அருகில், சென்னிமலை – 638 051.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A1518),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Near Bus Stand (Back Side), Opp. Kamatchi Lodge, Near Arukkani Hotel, Chennimalai – 638 051.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6E5D62),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Phone Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_in_talk_rounded, color: Color(0xFF7A132B), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "தொலைபேசி / Phone",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A132B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "94884 46677",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB82D1D),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "84383 82277",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB82D1D),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Working Hours Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time_rounded, color: Color(0xFF7A132B), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "அலுவலக நேரம் / Working Hours",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A132B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "திங்கள் காலை 10.00 முதல் மாலை 5.00 வரை",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A1518),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Daily 10.00 AM to 5.00 PM",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6E5D62),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // WhatsApp Chat Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening WhatsApp: +91 94884 46677'),
                      backgroundColor: Color(0xFF0F7A4C),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                label: const Text(
                  "WhatsApp Chat",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F7A4C),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Service notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF3EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5D5C8)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_outlined, size: 18, color: Color(0xFF7A132B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppConstants.onlineServiceNote,
                      style: TextStyle(fontSize: 11, color: Color(0xFF4C3E41)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
