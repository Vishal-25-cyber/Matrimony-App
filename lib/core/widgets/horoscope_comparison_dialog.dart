import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';

class HoroscopeComparisonDialog extends StatefulWidget {
  final ProfileModel? brideOrProfile1;
  final ProfileModel? groomOrProfile2;
  final MockDataService? mockData;
  final bool initialShowUpload;
  final bool isDialog;

  const HoroscopeComparisonDialog({
    super.key,
    this.brideOrProfile1,
    this.groomOrProfile2,
    this.mockData,
    this.initialShowUpload = false,
    this.isDialog = true,
  });

  static void show(
    BuildContext context, {
    ProfileModel? profile1,
    ProfileModel? profile2,
    MockDataService? mockData,
    bool initialShowUpload = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => HoroscopeComparisonDialog(
        brideOrProfile1: profile1,
        groomOrProfile2: profile2,
        mockData: mockData,
        initialShowUpload: initialShowUpload,
      ),
    );
  }

  @override
  State<HoroscopeComparisonDialog> createState() => _HoroscopeComparisonDialogState();
}

class _HoroscopeComparisonDialogState extends State<HoroscopeComparisonDialog> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: "பின்செல்க / Back",
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "நட்சத்திரப் பொருத்தம் அட்டவணை",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: "Reset Zoom",
                onPressed: _resetZoom,
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.asset(
                'assets/images/star_porutham_chart_clean.jpg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    "படம் ஏற்றுவதில் பிழை (Image Load Error)",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header with Tamil Title "நட்சத்திரப் பொருத்தம்"
        _buildHeader(context),

        // 2. Body showcasing single Star Porutham Chart Image
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEADBCE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.zoom_in_rounded, size: 18, color: Color(0xFF7A132B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "27 நட்சத்திரங்கள் & 10 பொருத்தங்கள் அட்டவணை • விரல்களால் பெரிதாக்கிப் பார்க்கலாம் (Pinch to Zoom)",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF580B23),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Star Porutham Image Card with Interactive Viewer
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    GestureDetector(
                      onDoubleTap: () => _openFullScreen(context),
                      child: Container(
                        color: const Color(0xFFFBF8F2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── TOP LABEL: பெண்களின் நட்சத்திரம் (Girls' Star) ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF7A132B), Color(0xFF9C1D3B)],
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.female_rounded, size: 15, color: Color(0xFFF9E8B2)),
                                  SizedBox(width: 6),
                                  Text(
                                    "பெண்களின் நட்சத்திரம்",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.female_rounded, size: 15, color: Color(0xFFF9E8B2)),
                                ],
                              ),
                            ),

                            // ── CHART ROW: Left label + Image ──
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // LEFT LABEL: ஆண்களின் நட்சத்திரம் (Boys' Star)
                                  Container(
                                    width: 28,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF1A3868), Color(0xFF2A4E8F)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.male_rounded, size: 13, color: Color(0xFFBDD1F8)),
                                            SizedBox(width: 4),
                                            Text(
                                              "ஆண்களின் நட்சத்திரம்",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.male_rounded, size: 13, color: Color(0xFFBDD1F8)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // THE CHART IMAGE
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxHeight: 480),
                                      child: InteractiveViewer(
                                        transformationController: _transformationController,
                                        minScale: 0.8,
                                        maxScale: 4.0,
                                        child: Image.asset(
                                          'assets/images/star_porutham_chart_clean.jpg',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 300,
                                            color: const Color(0xFFFFF3F5),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image_not_supported_rounded, size: 48, color: Color(0xFF7A132B)),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "நட்சத்திரப் பொருத்தம் படம் ஏற்ற முடியவில்லை",
                                                    style: TextStyle(color: Color(0xFF7A132B), fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action strip below image
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFDF9),
                        border: Border(top: BorderSide(color: Color(0xFFEADBCE))),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF7A132B)),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              "முழுத்திரையில் காண இருமுறை தொடவும்",
                              style: TextStyle(fontSize: 11, color: Color(0xFF6B585C), fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF7A132B),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _openFullScreen(context),
                            icon: const Icon(Icons.fullscreen_rounded, size: 16),
                            label: const Text(
                              "முழுத்திரை",
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Instructions Card explaining How it matches & When it doesn't match
              _buildInstructionsCard(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Matching Guide / Instructions Card ---
  Widget _buildInstructionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A132B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Header with Royal Gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A132B), Color(0xFF50091B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories_rounded, size: 16, color: Color(0xFFF9E8B2)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "அட்டவணை பார்க்கும் முறை & வழிகாட்டி",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "வழிகாட்டி",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A0E1C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step-by-Step Stepper Cards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEADBCE)),
                  ),
                  child: Column(
                    children: [
                      _buildGuideStep(
                        step: "1",
                        title: "பெண்ணின் நட்சத்திரம்:",
                        desc: "மேல் கிடைமட்ட வரிசையில் பெண்ணின் நட்சத்திரத்தைக் காணவும்.",
                        badgeColor: const Color(0xFF7A132B),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1, color: Color(0xFFEADBCE)),
                      ),
                      _buildGuideStep(
                        step: "2",
                        title: "ஆணின் நட்சத்திரம்:",
                        desc: "இடது செங்குத்து வரிசையில் ஆணின் நட்சத்திரத்தைக் காணவும்.",
                        badgeColor: const Color(0xFF1A3868),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1, color: Color(0xFFEADBCE)),
                      ),
                      _buildGuideStep(
                        step: "3",
                        title: "பொருத்த கலம் (Cell):",
                        desc: "இரண்டும் நேருக்கு நேர் சந்திக்கும் கட்டத்தில் உள்ள விவரத்தைப் பார்க்கவும்.",
                        badgeColor: const Color(0xFFB8860B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Match vs No-Match Cards (Equal Height using IntrinsicHeight)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Match Card (பொருத்தம் உண்டு)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3FAF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA5D6A7), width: 1.3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF81C784)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 13),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "பொருத்தம் உண்டு",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                          color: Color(0xFF1B5E20),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "கட்டத்தில் எண்கள் (7, 8, 9, 10) இருந்தால் பொருத்தம் உண்டு.",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 8),
                              // Score Breakdown Pills
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFC8E6C9)),
                                ),
                                child: const Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("⭐ 8-10: ", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                                        Expanded(
                                          child: Text("உத்தமம்", style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text("✓ 6-7: ", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                                        Expanded(
                                          child: Text("நன்று", style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // No Match Card (பொருத்தம் இல்லை)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF4F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEF9A9A), width: 1.3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC62828).withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE57373)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel_rounded, color: Color(0xFFC62828), size: 13),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "பொருத்தம் இல்லை",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                          color: Color(0xFFB71C1C),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "கட்டம் காலியாக (வெற்று / -) இருந்தால் பொருத்தம் இல்லை.",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFFB71C1C),
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 8),
                              // Reason Breakdown Pill
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFCDD2)),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFC62828)),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "ரஜ்ஜு அல்லது முக்கிய பொருத்தம் இல்லாததால் கலம் வெற்று.",
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFFC62828), height: 1.25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Golden Note Callout Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF9E6), Color(0xFFFFF4D4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5B034), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars_rounded, size: 19, color: Color(0xFFD48806)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "குறிப்பு: திருமணத்திற்கு குறைந்தபட்சம் 6 பொருத்தங்கள் மற்றும் ரஜ்ஜு பொருத்தம் இருப்பது மிக உகந்தது.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF874D00),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required String step,
    required String title,
    required String desc,
    required Color badgeColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.3),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF332024)),
              children: [
                TextSpan(
                  text: "$title ",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A0E1C)),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF7A132B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star_rounded, color: Color(0xFF7A132B), size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "நட்சத்திரப் பொருத்தம்",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "விவாக நட்சத்திரப் பொருத்த அட்டவணை",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFF3E5AB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isDialog)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: "Close",
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (!widget.isDialog) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
    );
  }
}
