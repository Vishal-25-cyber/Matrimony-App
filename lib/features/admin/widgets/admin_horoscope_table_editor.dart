import 'package:flutter/material.dart';
import '../../../models/horoscope_chart_model.dart';
import '../../../core/widgets/drawn_horoscope_chart_widget.dart';

class AdminHoroscopeTableEditor extends StatefulWidget {
  final Map<String, String>? initialRasiChart;
  final Map<String, String>? initialNavamsamChart;
  final Function(Map<String, String> rasi, Map<String, String> navamsam) onChanged;

  const AdminHoroscopeTableEditor({
    super.key,
    this.initialRasiChart,
    this.initialNavamsamChart,
    required this.onChanged,
  });

  @override
  State<AdminHoroscopeTableEditor> createState() => _AdminHoroscopeTableEditorState();
}

class _AdminHoroscopeTableEditorState extends State<AdminHoroscopeTableEditor> {
  int _activeChartTab = 0; // 0: Rasi, 1: Navamsam
  late Map<String, String> _rasiData;
  late Map<String, String> _navamsamData;
  final Map<String, TextEditingController> _controllers = {};
  String? _focusedHouseKey;

  @override
  void initState() {
    super.initState();
    _rasiData = Map<String, String>.from(
      widget.initialRasiChart ?? HoroscopeChartModel.getShudhaRasiTemplate(),
    );
    _navamsamData = Map<String, String>.from(
      widget.initialNavamsamChart ?? HoroscopeChartModel.getStandardNavamsamTemplate(),
    );
    _initControllers();
  }

  void _initControllers() {
    for (final house in HoroscopeChartModel.houses) {
      final currentMap = _activeChartTab == 0 ? _rasiData : _navamsamData;
      final val = currentMap[house.key] ?? '-';
      _controllers[house.key] = TextEditingController(text: val == '-' ? '' : val);
    }
  }

  void _updateControllersForActiveTab() {
    final currentMap = _activeChartTab == 0 ? _rasiData : _navamsamData;
    for (final house in HoroscopeChartModel.houses) {
      final val = currentMap[house.key] ?? '-';
      _controllers[house.key]?.text = val == '-' ? '' : val;
    }
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _applyPlanet(String planet) {
    final targetKey = _focusedHouseKey ?? 'mesham';
    final ctrl = _controllers[targetKey];
    if (ctrl == null) return;

    final currentText = ctrl.text.trim();
    String newText;
    if (currentText.isEmpty || currentText == '-') {
      newText = planet;
    } else if (currentText.contains(planet)) {
      // Toggle off
      final items = currentText.split(',').map((s) => s.trim()).where((s) => s != planet).toList();
      newText = items.join(', ');
    } else {
      newText = "$currentText, $planet";
    }

    ctrl.text = newText;
    _onHouseChanged(targetKey, newText);
  }

  void _onHouseChanged(String key, String text) {
    setState(() {
      final clean = text.trim().isEmpty ? '-' : text.trim();
      if (_activeChartTab == 0) {
        _rasiData[key] = clean;
      } else {
        _navamsamData[key] = clean;
      }
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  void _loadTemplate(Map<String, String> template) {
    setState(() {
      if (_activeChartTab == 0) {
        _rasiData = Map<String, String>.from(template);
      } else {
        _navamsamData = Map<String, String>.from(template);
      }
      _updateControllersForActiveTab();
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  void _clearCurrentChart() {
    setState(() {
      final empty = {for (final h in HoroscopeChartModel.houses) h.key: '-'};
      if (_activeChartTab == 0) {
        _rasiData = empty;
      } else {
        _navamsamData = empty;
      }
      _updateControllersForActiveTab();
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  @override
  Widget build(BuildContext context) {
    final currentChartData = _activeChartTab == 0 ? _rasiData : _navamsamData;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Title & Live Preview Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A132B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ஜாதகக் கட்டங்கள் அட்டவணை / Chart Data Entry",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                    Text(
                      "12 வீடுகளுக்கான கிரக நிலைகளை நேரடியாக உள்ளிடவும்",
                      style: TextStyle(fontSize: 10, color: Color(0xFF755C62)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chart Selector Tabs (ராசி / நவாம்சம்)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EAE0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeChartTab = 0;
                        _updateControllersForActiveTab();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeChartTab == 0 ? const Color(0xFF7A132B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "ராசிக் கட்டம் (Rasi Chart)",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _activeChartTab == 0 ? Colors.white : const Color(0xFF580B23),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeChartTab = 1;
                        _updateControllersForActiveTab();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeChartTab == 1 ? const Color(0xFF1A3868) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "நவாம்சக் கட்டம் (Navamsam)",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _activeChartTab == 1 ? Colors.white : const Color(0xFF1A3868),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Live Drawn Chart Preview Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEDE0D5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "நேரடி அட்டவணை முன்னோட்டம் (Live Preview):",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4C3E41)),
                    ),
                    Text(
                      _activeChartTab == 0 ? "ராசி" : "நவாம்சம்",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _activeChartTab == 0 ? const Color(0xFF7A132B) : const Color(0xFF1A3868),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DrawnHoroscopeChartWidget(
                  chartData: currentChartData,
                  isRasi: _activeChartTab == 0,
                  cellHeight: 30,
                  showHeader: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Preset Templates
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTemplateChip("சுத்த ஜாதகம் மாதிரி", () => _loadTemplate(HoroscopeChartModel.getShudhaRasiTemplate())),
              _buildTemplateChip("செவ்வாய் தோஷம் மாதிரி", () => _loadTemplate(HoroscopeChartModel.getChevvaiRasiTemplate())),
              _buildTemplateChip("ராகு-கேது மாதிரி", () => _loadTemplate(HoroscopeChartModel.getRahuKetuRasiTemplate())),
              _buildTemplateChip("அழிக்க (Clear)", _clearCurrentChart, isDestructive: true),
            ],
          ),

          const SizedBox(height: 10),

          // Quick Planet Addition Chips
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5EF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF7A132B)),
                    const SizedBox(width: 4),
                    Text(
                      "தேர்ந்தெடுத்த வீடு (${_getTamilName(_focusedHouseKey ?? 'mesham')}) - கிரகங்களை சேர்க்க கிளிக் செய்யவும்:",
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: HoroscopeChartModel.standardPlanets.map((planet) {
                    return ActionChip(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      label: Text(
                        "+ $planet",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
                      onPressed: () => _applyPlanet(planet),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Table of 12 Houses
          const Text(
            "12 ராசி வீடுகள் (Houses Entry Table):",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2C161A)),
          ),
          const SizedBox(height: 6),

          // Grid of 12 House inputs (2 columns)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 380;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HoroscopeChartModel.houses.map((house) {
                  final isFocused = _focusedHouseKey == house.key;
                  final width = isWide ? (constraints.maxWidth - 8) / 2 : constraints.maxWidth;

                  return SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFocused ? const Color(0xFFFFF9E6) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFocused ? const Color(0xFF7A132B) : const Color(0xFFE2D6CB),
                          width: isFocused ? 1.4 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${house.tamil} (${house.english})",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isFocused ? const Color(0xFF7A132B) : const Color(0xFF332024),
                                ),
                              ),
                              if (_controllers[house.key]?.text.isNotEmpty ?? false)
                                GestureDetector(
                                  onTap: () {
                                    _controllers[house.key]?.clear();
                                    _onHouseChanged(house.key, '');
                                  },
                                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 32,
                            child: TextField(
                              controller: _controllers[house.key],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: "கிரகங்கள் (எ.கா. லக்னம், புதன்)",
                                hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(color: Color(0xFFE0D0C0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(color: Color(0xFF7A132B), width: 1.2),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA),
                              ),
                              onTap: () {
                                setState(() => _focusedHouseKey = house.key);
                              },
                              onChanged: (val) => _onHouseChanged(house.key, val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFF3EAE0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDestructive ? Colors.red[300]! : const Color(0xFFD4AF37),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red[800] : const Color(0xFF580B23),
          ),
        ),
      ),
    );
  }

  String _getTamilName(String key) {
    final match = HoroscopeChartModel.houses.firstWhere(
      (h) => h.key == key,
      orElse: () => HoroscopeChartModel.houses.first,
    );
    return match.tamil;
  }
}
