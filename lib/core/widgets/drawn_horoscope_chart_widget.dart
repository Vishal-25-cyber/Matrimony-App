import 'package:flutter/material.dart';
import '../../models/horoscope_chart_model.dart';

class DrawnHoroscopeChartWidget extends StatelessWidget {
  final Map<String, String> chartData;
  final bool isRasi;
  final double cellHeight;
  final Color? headerColor;
  final bool showHeader;

  const DrawnHoroscopeChartWidget({
    super.key,
    required this.chartData,
    required this.isRasi,
    this.cellHeight = 42,
    this.headerColor,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = headerColor ?? (isRasi ? const Color(0xFF7A132B) : const Color(0xFF1A3868));
    final grid = HoroscopeChartModel.buildGridMatrix(chartData);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            alignment: Alignment.center,
            child: Text(
              isRasi ? "ராசிக் கட்டம்" : "நவாம்சக் கட்டம்",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: primary, width: 1.5),
            borderRadius: showHeader ? const BorderRadius.vertical(bottom: Radius.circular(8)) : BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (row) {
              return Row(
                children: List.generate(4, (col) {
                  final isCenter = (row == 1 || row == 2) && (col == 1 || col == 2);
                  if (isCenter) {
                    if (row == 1 && col == 1) {
                      return Expanded(
                        flex: 2,
                        child: Container(
                          height: cellHeight * 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9EE),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isRasi ? "ராசி" : "நவாம்சம்",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: primary,
                                    ),
                                  ),
                                  Text(
                                    isRasi ? "(Rasi)" : "(Nav)",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: primary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final text = grid[row][col];
                  final parts = text.split('\n');
                  final houseName = parts.isNotEmpty ? parts[0] : '';
                  final planetText = parts.length > 1 ? parts.sublist(1).join('\n') : '-';
                  final hasPlanets = planetText.trim() != '-' && planetText.trim().isNotEmpty;

                  return Expanded(
                    child: Container(
                      height: cellHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: hasPlanets ? const Color(0xFFFFFDF8) : Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE8D7CA),
                          width: 0.7,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                houseName,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF6B4F4F),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                planetText,
                                style: TextStyle(
                                  fontSize: hasPlanets ? 9 : 8,
                                  fontWeight: hasPlanets ? FontWeight.bold : FontWeight.normal,
                                  color: hasPlanets ? primary : Colors.grey[400],
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}
