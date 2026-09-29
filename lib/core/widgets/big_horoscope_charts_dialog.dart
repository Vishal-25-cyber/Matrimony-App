import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../utils/horoscope_download_helper.dart';
import 'drawn_horoscope_chart_widget.dart';

/// Modal dialog that displays ONLY the Astrological Charts (Rasi & Navamsam tables)
/// enlarged with crisp high-readability cells, without certificates or bio data.
class BigHoroscopeChartsDialog extends StatefulWidget {
  final ProfileModel profile;

  const BigHoroscopeChartsDialog({
    super.key,
    required this.profile,
  });

  static void show(BuildContext context, ProfileModel profile) {
    showDialog(
      context: context,
      builder: (_) => BigHoroscopeChartsDialog(profile: profile),
    );
  }

  @override
  State<BigHoroscopeChartsDialog> createState() => _BigHoroscopeChartsDialogState();
}

class _BigHoroscopeChartsDialogState extends State<BigHoroscopeChartsDialog> {
  final GlobalKey _chartsKey = GlobalKey();
  int _selectedView = 0; // 0 = Both, 1 = Rasi, 2 = Navamsam
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    await HoroscopeDownloadHelper.downloadHoroscopeCertificate(
      context: context,
      boundaryKey: _chartsKey,
      profile: widget.profile,
    );
    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final rasiData = profile.getEffectiveRasiChart();
    final navamsamData = profile.getEffectiveNavamsamChart();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header with Golden Accents
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      child: const Icon(Icons.grid_on_rounded, color: Color(0xFF7A132B), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ஜாதகக் கட்டங்கள் (பெரிதாக)",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "${profile.name} • ${profile.star ?? ''} • ${profile.rasi ?? ''}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF3E5AB),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                      visualDensity: VisualDensity.compact,
                      tooltip: "மூடுக",
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // 2. View Toggle: Both | Rasi Only | Navamsam Only
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2D1C1)),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(0, "ராசி & நவாம்சம் (Both)"),
                          const SizedBox(width: 4),
                          _buildTabButton(1, "ராசிக் கட்டம் (Rasi)"),
                          const SizedBox(width: 4),
                          _buildTabButton(2, "நவாம்சக் கட்டம் (Navamsam)"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. Crisp Big Astrological Tables Area (RepaintBoundary for PNG download)
                    RepaintBoundary(
                      key: _chartsKey,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDE0D5)),
                        ),
                        child: _buildChartsContent(rasiData, navamsamData),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4. Action Buttons (Download Charts PNG / Close)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: _isDownloading ? null : _handleDownload,
                              icon: _isDownloading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.download_rounded, size: 18),
                              label: Text(
                                _isDownloading ? "பதிவிறக்குகிறது..." : "ஜாதகக் கட்டங்களைப் பதிவிறக்குக (PNG)",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B6B38),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7A132B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              "மூடுக",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                            ),
                          ),
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
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedView == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedView = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7A132B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF6B4F4F),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartsContent(Map<String, String> rasiData, Map<String, String> navamsamData) {
    if (_selectedView == 1) {
      // Rasi Only: Displayed with large cell height (80px)
      return DrawnHoroscopeChartWidget(
        chartData: rasiData,
        isRasi: true,
        cellHeight: 80,
      );
    }

    if (_selectedView == 2) {
      // Navamsam Only: Displayed with large cell height (80px)
      return DrawnHoroscopeChartWidget(
        chartData: navamsamData,
        isRasi: false,
        cellHeight: 80,
      );
    }

    // Both Charts: Responsive side-by-side or stacked with enlarged cells (65px)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 450;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DrawnHoroscopeChartWidget(
                  chartData: rasiData,
                  isRasi: true,
                  cellHeight: 65,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DrawnHoroscopeChartWidget(
                  chartData: navamsamData,
                  isRasi: false,
                  cellHeight: 65,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            DrawnHoroscopeChartWidget(
              chartData: rasiData,
              isRasi: true,
              cellHeight: 65,
            ),
            const SizedBox(height: 12),
            DrawnHoroscopeChartWidget(
              chartData: navamsamData,
              isRasi: false,
              cellHeight: 65,
            ),
          ],
        );
      },
    );
  }
}
