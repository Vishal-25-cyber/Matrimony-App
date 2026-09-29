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
                'assets/images/star_porutham_chart.jpg',
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
                        constraints: const BoxConstraints(
                          maxHeight: 520,
                        ),
                        color: const Color(0xFFFBF8F2),
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Image.asset(
                            'assets/images/star_porutham_chart.jpg',
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


            ],
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
