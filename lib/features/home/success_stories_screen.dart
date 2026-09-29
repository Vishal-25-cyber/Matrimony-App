import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../core/utils/navigation_helper.dart';

class SuccessStoriesScreen extends StatelessWidget {
  final MockDataService mockData;

  const SuccessStoriesScreen({super.key, required this.mockData});

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
              "வெற்றிக் கதைகள்",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "Success Stories",
              style: TextStyle(fontSize: 10, color: Color(0xFFF0D68A), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Featured Success Story Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Couple Photo
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/wedding_couple.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.4),
                    ),
                  ),

                  // Quote Details
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          "“பண்டாரத்தார் மணமாலை மூலம் எங்கள் வாழ்க்கை துணையை கண்டோம். மிகவும் நன்றி!”",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A132B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "“We found our perfect match through Pandarathar Mana Maalai. Thank you so much!”",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A484C),
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF3EC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5D5C8)),
                          ),
                          child: const Text(
                            "- Mr. & Mrs. Suresh, Coimbatore",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A1518),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE0D5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/garland_couple.jpg', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Karthik & Soundarya",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Married: Nov 2024 • Thanjavur",
                          style: TextStyle(fontSize: 11, color: Color(0xFF7E6F72)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Sacred values and astrological harmony came together perfectly.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF4C3E41)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // View More Stories Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Showing all verified Pandarathar wedding testimonials'),
                      backgroundColor: Color(0xFF7A132B),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "மேலும் கதைகள் பார்க்க / View More Stories",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
