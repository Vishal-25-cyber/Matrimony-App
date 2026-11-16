import 'package:flutter/material.dart';
import '../../../models/horoscope_chart_model.dart';

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

class _AdminHoroscopeTableEditorState extends State<AdminHoroscopeTableEditor>
    with SingleTickerProviderStateMixin {
  int _activeChartTab = 0; // 0: Rasi, 1: Navamsam
  late Map<String, String> _rasiData;
  late Map<String, String> _navamsamData;
  String? _selectedHouseKey;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Visual grid order matching South Indian kundali layout (4×3)
  static const List<String> _gridOrder = [
    'meenam',    'mesham',   'rishabam',   'mithunam',
    'kumbam',    '',         '',           'kadagam',
    'makaram',   '',         '',           'simmam',
    'dhanusu',   'viruchigam', 'thulam',   'kanni',
  ];

  @override
  void initState() {
    super.initState();
    _rasiData = (widget.initialRasiChart != null && widget.initialRasiChart!.isNotEmpty)
        ? Map<String, String>.from(widget.initialRasiChart!)
        : HoroscopeChartModel.getEmptyChart();
    _navamsamData = (widget.initialNavamsamChart != null && widget.initialNavamsamChart!.isNotEmpty)
        ? Map<String, String>.from(widget.initialNavamsamChart!)
        : HoroscopeChartModel.getEmptyChart();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant AdminHoroscopeTableEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRasiChart != oldWidget.initialRasiChart && widget.initialRasiChart != null) {
      _rasiData = Map<String, String>.from(widget.initialRasiChart!);
    }
    if (widget.initialNavamsamChart != oldWidget.initialNavamsamChart && widget.initialNavamsamChart != null) {
      _navamsamData = Map<String, String>.from(widget.initialNavamsamChart!);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Map<String, String> get _currentData =>
      _activeChartTab == 0 ? _rasiData : _navamsamData;

  void _selectHouse(String key) {
    setState(() => _selectedHouseKey = key);
  }

  void _togglePlanet(String planet) {
    final key = _selectedHouseKey;
    if (key == null) return;
    final current = _currentData[key] ?? '-';
    final planets = current == '-'
        ? <String>[]
        : current.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    setState(() {
      if (planets.contains(planet)) {
        planets.remove(planet);
      } else {
        planets.add(planet);
      }
      final newVal = planets.isEmpty ? '-' : planets.join(', ');
      if (_activeChartTab == 0) {
        _rasiData[key] = newVal;
      } else {
        _navamsamData[key] = newVal;
      }
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  void _clearHouse(String key) {
    setState(() {
      if (_activeChartTab == 0) {
        _rasiData[key] = '-';
      } else {
        _navamsamData[key] = '-';
      }
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  void _clearAll() {
    final empty = {for (final h in HoroscopeChartModel.houses) h.key: '-'};
    setState(() {
      if (_activeChartTab == 0) {
        _rasiData = empty;
      } else {
        _navamsamData = Map<String, String>.from(empty);
      }
      _selectedHouseKey = null;
    });
    widget.onChanged(_rasiData, _navamsamData);
  }

  HoroscopeHouseMeta? get _selectedHouse => _selectedHouseKey == null
      ? null
      : HoroscopeChartModel.houses.firstWhere(
          (h) => h.key == _selectedHouseKey,
          orElse: () => HoroscopeChartModel.houses.first,
        );

  List<String> get _selectedPlanets {
    final val = _currentData[_selectedHouseKey] ?? '-';
    if (val == '-' || val.trim().isEmpty) return [];
    return val.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A132B).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildKundaliGrid(),
          if (_selectedHouseKey != null) _buildPlanetPanel(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7A132B), Color(0xFF4E0C1A)],
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
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_mosaic_rounded, color: Color(0xFFF9E8B2), size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ஜாதகக் கட்டம் (Horoscope Editor)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "வீட்டை தொட்டு கிரகங்களை சேர்க்கவும்",
                  style: TextStyle(fontSize: 10, color: Color(0xFFF3D9A0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RASI / NAVAMSAM TAB ──
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EAE0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildTab(0, "ராசி (Rasi)", const Color(0xFF7A132B)),
            _buildTab(1, "நவாம்சம் (Navamsam)", const Color(0xFF1A3868)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Color activeColor) {
    final active = _activeChartTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeChartTab = index;
            _selectedHouseKey = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : activeColor,
            ),
          ),
        ),
      ),
    );
  }

  // ── VISUAL KUNDALI GRID (4×4) ──
  Widget _buildKundaliGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final cellW = constraints.maxWidth / 4;
              final cellH = constraints.maxHeight / 4;
              return Stack(
                children: [
                  // Draw cross divider lines
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _GridLinePainter(),
                  ),
                  // Build cells
                  ...List.generate(16, (i) {
                    final row = i ~/ 4;
                    final col = i % 4;
                    final key = _gridOrder[i];
                    final isCenter = (row == 1 || row == 2) && (col == 1 || col == 2);
                    if (isCenter) return const SizedBox.shrink();
                    if (key.isEmpty) return const SizedBox.shrink();

                    final house = HoroscopeChartModel.houses.firstWhere(
                      (h) => h.key == key,
                      orElse: () => HoroscopeChartModel.houses.first,
                    );
                    final val = _currentData[key] ?? '-';
                    final planets = val == '-' ? '' : val;
                    final isSel = _selectedHouseKey == key;

                    return Positioned(
                      left: col * cellW,
                      top: row * cellH,
                      width: cellW,
                      height: cellH,
                      child: GestureDetector(
                        onTap: () => _selectHouse(key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF7A132B).withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSel ? const Color(0xFF7A132B) : Colors.transparent,
                              width: isSel ? 1.8 : 0,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // House name label (top-left)
                              Positioned(
                                top: 3,
                                left: 4,
                                child: Text(
                                  house.tamil,
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? const Color(0xFF7A132B)
                                        : const Color(0xFFAA8870),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Clear button (top-right) when has planets
                              if (planets.isNotEmpty)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _clearHouse(key),
                                    child: Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded,
                                          size: 9, color: Colors.red),
                                    ),
                                  ),
                                ),
                              // Planets text (center)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(2, 16, 2, 2),
                                  child: Text(
                                    planets.isEmpty ? '' : planets,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSel
                                          ? const Color(0xFF4E0C1A)
                                          : const Color(0xFF3A2020),
                                      height: 1.3,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Center diamond label
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD4AF37)),
                        const SizedBox(height: 2),
                        Text(
                          _activeChartTab == 0 ? "ராசி" : "நவாம்சம்",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A132B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── PLANET PANEL ──
  Widget _buildPlanetPanel() {
    final house = _selectedHouse;
    if (house == null) return const SizedBox.shrink();
    final activePlanets = _selectedPlanets;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9ED), Color(0xFFFFF3E0)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${house.tamil} (${house.english})",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activePlanets.isEmpty
                          ? "கிரகங்கள் இல்லை — தேர்வு செய்யவும்"
                          : "தேர்வு: ${activePlanets.join(', ')}",
                      style: TextStyle(
                        fontSize: 10,
                        color: activePlanets.isEmpty
                            ? Colors.grey
                            : const Color(0xFF4E0C1A),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Planet toggle buttons
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: HoroscopeChartModel.standardPlanets.map((planet) {
                  final isActive = activePlanets.contains(planet);
                  return GestureDetector(
                    onTap: () => _togglePlanet(planet),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF7A132B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF7A132B)
                              : const Color(0xFFD4AF37),
                          width: 1.2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF7A132B).withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        planet,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : const Color(0xFF580B23),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOTTOM BAR ──
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Tip text
          const Expanded(
            child: Text(
              "💡 வீட்டை தொட்டு, கிரகங்களை தேர்வு செய்யவும்",
              style: TextStyle(fontSize: 10, color: Color(0xFF8B6B70)),
            ),
          ),
          // Clear All
          GestureDetector(
            onTap: _clearAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep_rounded, size: 13, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text(
                    "அழிக்க (Clear)",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid divider lines painter
class _GridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    final cw = size.width / 4;
    final ch = size.height / 4;

    // Vertical lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(cw * i, 0), Offset(cw * i, size.height), paint);
    }
    // Horizontal lines
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, ch * i), Offset(size.width, ch * i), paint);
    }
    // Center X diagonals
    canvas.drawLine(Offset(cw, ch), Offset(cw * 3, ch * 3), paint);
    canvas.drawLine(Offset(cw * 3, ch), Offset(cw, ch * 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
