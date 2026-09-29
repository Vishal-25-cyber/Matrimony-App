import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../utils/horoscope_download_helper.dart';
import 'drawn_horoscope_chart_widget.dart';
import 'horoscope_comparison_dialog.dart';

class HoroscopeCertificateDialog extends StatefulWidget {
  final ProfileModel profile;
  final MockDataService? mockData;

  const HoroscopeCertificateDialog({
    super.key,
    required this.profile,
    this.mockData,
  });

  static void show(
    BuildContext context,
    ProfileModel profile, {
    MockDataService? mockData,
  }) {
    showDialog(
      context: context,
      builder: (_) => HoroscopeCertificateDialog(
        profile: profile,
        mockData: mockData,
      ),
    );
  }

  @override
  State<HoroscopeCertificateDialog> createState() => _HoroscopeCertificateDialogState();
}

class _HoroscopeCertificateDialogState extends State<HoroscopeCertificateDialog> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    final success = await HoroscopeDownloadHelper.downloadHoroscopeCertificate(
      context: context,
      boundaryKey: _certificateKey,
      profile: widget.profile,
    );
    if (mounted) {
      setState(() => _isDownloading = false);
      if (success) {
        _showPostDownloadCompareOption();
      }
    }
  }

  void _showPostDownloadCompareOption() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.download_done_rounded, color: Color(0xFF1B6B38), size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  "ஜாதகக் குறிப்பு வெற்றிகரமாக பதிவிறக்கப்பட்டது! ✓",
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "இப்போது ${widget.profile.name} ஜாதகத்துடன் உங்கள் ஜாதகத்தை ஒப்பிட்டு 10 பொருத்தங்களையும் துல்லியமாக பார்க்கலாமா?",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF580B23)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            HoroscopeComparisonDialog.show(
                              context,
                              profile1: widget.profile,
                              mockData: widget.mockData,
                            );
                          },
                          icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                          label: const Text(
                            "இரு ஜாதகப் பொருத்தம் காண்க",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A132B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7A132B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("பிறகு", style: TextStyle(color: Color(0xFF7A132B), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final r2Url = profile.r2CertificateUrl ??
        "https://pub-r2.pandarathar-matrimony.com/certificates/${profile.id}.pdf";
    final rasiData = profile.getEffectiveRasiChart();
    final navamsamData = profile.getEffectiveNavamsamChart();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Certificate Header with Golden Border
              Container(
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
                      child: const Icon(Icons.history_edu_rounded, color: Color(0xFF7A132B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "அங்கீகரிக்கப்பட்ட ஜாதகக் குறிப்பு",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Verified Horoscope Certificate • ${profile.id}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF3E5AB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Printable Area (Rendered via RepaintBoundary for Crisp PNG Download)
              RepaintBoundary(
                key: _certificateKey,
                child: Container(
                  color: const Color(0xFFFFFDF9),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Auspicious Invocation
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("|| சிவமயம் ||", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7A132B))),
                            SizedBox(width: 24),
                            Text("|| சுபமுகூர்த்தம் ||", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7A132B))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Cloudflare R2 Safe Storage Banner
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF4F8FA), Color(0xFFEBF3F8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C7BE5).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C7BE5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Cloudflare R2 பாதுகாக்கப்பட்ட சேமிப்பகம்",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A3868),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C7BE5).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "R2 SSL Encrypted",
                                    style: TextStyle(fontSize: 9.5, color: Color(0xFF1A3868), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              r2Url,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Color(0xFF2C7BE5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Profile Summary Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF4ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8D6C6)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFF9F0E6),
                                  backgroundImage: (profile.imageAsset != null && profile.imageAsset!.isNotEmpty)
                                      ? AssetImage(profile.imageAsset!)
                                      : null,
                                  child: (profile.imageAsset == null || profile.imageAsset!.isEmpty)
                                      ? Icon(
                                          profile.gender.toLowerCase() == 'bride' ? Icons.person_3_rounded : Icons.person_rounded,
                                          color: const Color(0xFF7A132B),
                                          size: 26,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${profile.name} (${profile.nameTamil ?? ''})",
                                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "பிறந்த தேதி: ${profile.dob ?? '14 மே 1999'} • ${profile.age} வயது",
                                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF4C3E41)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18, color: Color(0xFFE2D0C0)),
                            _buildDetailRow("நட்சத்திரம்", (profile.star ?? "ரோகிணி").split(' (').first),
                            _buildDetailRow("ராசி", (profile.rasi ?? "ரிஷபம்").split(' (').first),
                            _buildDetailRow("லக்னம்", "மேஷம்"),
                            _buildDetailRow("சாதி", profile.caste ?? profile.community),
                            _buildDetailRow("கோத்திரம்", (profile.gothram ?? "சிவகோத்திரம்").split(' (').first),
                            _buildDetailRow(
                              "ஜாதக தோஷம்",
                              profile.doshamType == 'chevvai'
                                  ? "செவ்வாய் தோஷம் உண்டு (7/8-ம் இடம்)"
                                  : profile.doshamType == 'rahu_ketu'
                                      ? "ராகு - கேது சர்ப்ப தோஷம்"
                                      : profile.doshamType == 'chevvai_rahu_ketu'
                                          ? "செவ்வாய் + ராகு-கேது (இரட்டை தோஷம்)"
                                          : profile.doshamType == 'kalathra'
                                              ? "களத்திர / மாங்கல்ய தோஷம்"
                                              : "சுத்த ஜாதகம் (தோஷமில்லை)",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tamil Astrological Rasi & Navamsam Grids (Drawn dynamically)
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "ஜாதகக் கட்டங்கள் / Astrological Charts",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF580B23),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF1B6B38), width: 0.8),
                            ),
                            child: const Text(
                              "துல்லியம் ✓",
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1B6B38)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Side-by-side Drawn Charts
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rasi Chart
                          Expanded(
                            child: DrawnHoroscopeChartWidget(
                              chartData: rasiData,
                              isRasi: true,
                              cellHeight: 44,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Navamsam Chart
                          Expanded(
                            child: DrawnHoroscopeChartWidget(
                              chartData: navamsamData,
                              isRasi: false,
                              cellHeight: 44,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Official Astrologer Verification Stamp
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE6CA7E)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF8C1D38), width: 1.5),
                              ),
                              child: const Icon(Icons.verified_rounded, color: Color(0xFF8C1D38), size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "பண்டாரத்தார் சபை ஆஸ்தான ஜோதிடர்",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF580B23),
                                    ),
                                  ),
                                  Text(
                                    "நேரில் சரிபார்க்கப்பட்டு அங்கீகரிக்கப்பட்டது • 100% Genuine",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6B4E54),
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
              ),

              // Dedicated 10 Poruthams Comparison Card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A132B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.compare_arrows_rounded, color: Color(0xFFF3E5AB), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "இரு ஜாதகப் பொருத்தம் பார்க்க",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF580B23)),
                          ),
                          Text(
                            "10 திருமணப் பொருத்தங்கள் துல்லியக் கணிப்பு",
                            style: TextStyle(fontSize: 10, color: Color(0xFF6B5458)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        HoroscopeComparisonDialog.show(
                          context,
                          profile1: widget.profile,
                          mockData: widget.mockData,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A132B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 1,
                      ),
                      child: const Text("பொருத்தம் பார்", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Bottom Actions: Download Horoscope & Close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _handleDownload,
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.download_rounded, size: 20),
                          label: Text(
                            _isDownloading ? "பதிவிறக்குகிறது..." : "ஜாதகத்தைப் பதிவிறக்குக (Download)",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6B38),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7A132B)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("சரி", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A132B))),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B5458), fontWeight: FontWeight.w600),
            ),
          ),
          const Text(" :  ", style: TextStyle(fontSize: 11, color: Color(0xFFB0A2A5), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF2C161A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
