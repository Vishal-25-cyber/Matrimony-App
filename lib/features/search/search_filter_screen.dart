import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import 'search_results_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  final MockDataService mockData;
  final VoidCallback? onBackToHome;

  const SearchFilterScreen({
    super.key,
    required this.mockData,
    this.onBackToHome,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  // Looking for: Bride (Female) or Groom (Male) - automatically initialized from signup/profile
  String _lookingFor = 'Bride';

  // Age Filter (Enabled by default)
  bool _filterByAge = true;
  int _fixedAge = 25;
  bool _exactAgeMatch = false;

  // Dropdown expansion state for Rasi, Star, Education, Location
  bool _isRasiExpanded = false;
  bool _isStarExpanded = false;
  bool _isEducationExpanded = false;
  bool _isLocationExpanded = false;

  @override
  void initState() {
    super.initState();
    _initLookingFor();
    // Default to nothing selected as requested:
    // _selectedRasis, _selectedStars, _selectedEducations, _selectedLocations start empty
  }

  void _initLookingFor() {
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      final g = authUser.gender.toLowerCase().trim();
      // If user selected Searching for Bride or is a Groom, they seek a Bride
      if (g.contains('searching for bride') || g == 'groom' || g.contains('male')) {
        _lookingFor = 'Bride';
        return;
      }
      // If user selected Searching for Groom or is a Bride, they seek a Groom
      if (g.contains('searching for groom') || g == 'bride' || g.contains('female')) {
        _lookingFor = 'Groom';
        return;
      }
    }

    final user = widget.mockData.currentUser;
    final userGender = user.gender.toLowerCase().trim();
    if (userGender.contains('searching for bride') || userGender == 'groom' || userGender.contains('male')) {
      _lookingFor = 'Bride';
    } else {
      _lookingFor = 'Groom';
    }
  }

  // Particular Caste Alone
  bool _particularCasteOnly = true;
  String _selectedCaste = 'Pandarathar (பண்டாரத்தார்)';
  final List<String> _casteList = [
    'Pandarathar (பண்டாரத்தார்)',
    'All Castes (அனைத்து சாதி)',
  ];

  // Astrological Horoscope Problems & Compatibility Matcher (5 Classes - Multi-select Checkboxes)
  final Set<String> _selectedDoshams = {'none'};
  bool _onlyCompatibleMatches = true;

  // 12 Rasis (Moon Signs - Multi-select Checkboxes)
  final List<String> _rasisList = [
    'மேஷம் (Mesham)',
    'ரிஷபம் (Rishabham)',
    'மிதுனம் (Mithunam)',
    'கடகம் (Kadagam)',
    'சிம்மம் (Simmam)',
    'கன்னி (Kanni)',
    'துலாம் (Thulam)',
    'விருச்சிகம் (Viruchigam)',
    'தனுசு (Dhanusu)',
    'மகரம் (Magaram)',
    'கும்பம் (Kumbam)',
    'மீனம் (Meenam)',
  ];
  final Set<String> _selectedRasis = {};

  // 27 Stars (Nakshatras - Multi-select Checkboxes)
  final List<String> _starsList = [
    'அஸ்வினி (Aswini)',
    'பரணி (Bharani)',
    'கார்த்திகை (Karthigai)',
    'ரோகிணி (Rohini)',
    'மிருகசீரிடம் (Mrigashira)',
    'திருவாதிரை (Thiruvathirai)',
    'புனர்பூசம் (Punarpoosam)',
    'பூசம் (Poosam)',
    'ஆயில்யம் (Ayilyam)',
    'மகம் (Magam)',
    'பூரம் (Pooram)',
    'உத்திரம் (Uthiram)',
    'அஸ்தம் (Hastham)',
    'சித்திரை (Chithirai)',
    'சுவாதி (Swathi)',
    'விசாகம் (Visakam)',
    'அனுஷம் (Anusham)',
    'கேட்டை (Kettai)',
    'மூலம் (Moolam)',
    'பூராடம் (Pooradam)',
    'உத்திராடம் (Uthiradam)',
    'திருவோணம் (Thiruvonam)',
    'அவிட்டம் (Avittam)',
    'சதயம் (Sathayam)',
    'பூரட்டாதி (Poorattathi)',
    'உத்திரட்டாதி (Uthirattathi)',
    'ரேவதி (Revathi)',
  ];
  final Set<String> _selectedStars = {};
  String _starSearchQuery = '';
  final ScrollController _starScrollController = ScrollController();

  @override
  void dispose() {
    _starScrollController.dispose();
    super.dispose();
  }

  // Education / Degrees (Multi-select Checkboxes)
  final List<String> _educationList = [
    'B.Tech / B.E',
    'M.Sc / M.Tech',
    'MBA / Finance',
    'Doctor / MBBS',
    'Govt / Degree',
  ];
  final Set<String> _selectedEducations = {};

  // Locations / Cities (Multi-select Checkboxes)
  final List<String> _locationList = [
    'Chennai',
    'Coimbatore',
    'Erode',
    'Madurai',
    'Salem',
    'Thanjavur',
    'Trichy',
  ];
  final Set<String> _selectedLocations = {};

  void _applySearch() {
    final casteFilter = _particularCasteOnly ? _selectedCaste : 'All';

    List<String>? doshamFilterList;
    if (_onlyCompatibleMatches) {
      if (_selectedDoshams.isNotEmpty && _selectedDoshams.length < 5) {
        doshamFilterList = _selectedDoshams.toList();
      }
    }

    final results = widget.mockData.filterSmartMatches(
      lookingForGender: _lookingFor,
      caste: casteFilter,
      myDosham: doshamFilterList != null && doshamFilterList.length == 1
          ? doshamFilterList.first
          : (_onlyCompatibleMatches && doshamFilterList == null ? 'all' : null),
      doshams: doshamFilterList,
      stars: _selectedStars.isNotEmpty && _selectedStars.length < _starsList.length
          ? _selectedStars.toList()
          : null,
      rasis: _selectedRasis.isNotEmpty && _selectedRasis.length < _rasisList.length
          ? _selectedRasis.toList()
          : null,
      fixedAge: _filterByAge ? _fixedAge : null,
      exactAgeMatch: _exactAgeMatch,
      educations: _selectedEducations.isNotEmpty && _selectedEducations.length < _educationList.length
          ? _selectedEducations.toList()
          : null,
      locations: _selectedLocations.isNotEmpty && _selectedLocations.length < _locationList.length
          ? _selectedLocations.toList()
          : null,
      searchQuery: null,
    );

    final title = _onlyCompatibleMatches
        ? "பொருத்தமான வரன்கள் (${results.length})"
        : "தேடல் முடிவுகள் (${results.length})";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          mockData: widget.mockData,
          title: title,
          profiles: results,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        leading: (widget.onBackToHome != null || (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)))
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: "முகப்புக்கு செல்க / Back to Home",
                onPressed: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else if (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "வரன் தேடல்",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "சாதி & ஜாதக பொருத்தம்",
              style: TextStyle(fontSize: 11, color: Color(0xFFF0D68A), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selected during signup (Locked to what the user chose)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF3EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADBCE)),
              ),
              child: Row(
                children: [
                  Icon(
                    _lookingFor == 'Bride' ? Icons.female_rounded : Icons.male_rounded,
                    size: 20,
                    color: const Color(0xFF7A132B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lookingFor == 'Bride'
                          ? "தேடும் வரன்: மணமகள் (Bride வரன்கள் மட்டும்)"
                          : "தேடும் வரன்: மணமகன் (Groom வரன்கள் மட்டும்)",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A132B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A132B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "பதிவு செய்யப்பட்டது ✓",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A132B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Particular Caste Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFF7A132B), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "சாதி வடிகட்டி (Caste)",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                        ),
                      ),
                      Switch(
                        value: _particularCasteOnly,
                        activeThumbColor: const Color(0xFF7A132B),
                        onChanged: (val) => setState(() => _particularCasteOnly = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _particularCasteOnly
                        ? "பண்டாரத்தார் வரன்கள் மட்டும்"
                        : "அனைத்து சாதி வரன்கள்",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _particularCasteOnly ? const Color(0xFF1B6B38) : Colors.grey[700],
                    ),
                  ),
                  if (_particularCasteOnly) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2CA7E)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCaste,
                          isExpanded: true,
                          items: _casteList
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCaste = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Astrological Horoscope Compatibility Matcher
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF7A132B), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A132B).withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu_rounded, color: Color(0xFF7A132B), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "ஜாதக பொருத்தம்",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                        ),
                      ),
                      Switch(
                        value: _onlyCompatibleMatches,
                        activeThumbColor: const Color(0xFF7A132B),
                        onChanged: (val) => setState(() => _onlyCompatibleMatches = val),
                      ),
                    ],
                  ),
                  if (_onlyCompatibleMatches) ...[
                    const SizedBox(height: 8),

                    // 1. சுத்த ஜாதகம் (Sutham Jathagam)
                    _buildDoshamOption(
                      value: 'none',
                      title: "சுத்த ஜாதகம்",
                    ),
                    const SizedBox(height: 8),

                    // 2. செவ்வாய் ஜாதகம் (Chevvai Jathagam)
                    _buildDoshamOption(
                      value: 'chevvai',
                      title: "செவ்வாய் ஜாதகம்",
                    ),
                    const SizedBox(height: 8),

                    // 3. ராகு - கேது ஜாதகம் (Rahu-Ketu Jathagam)
                    _buildDoshamOption(
                      value: 'rahu_ketu',
                      title: "ராகு - கேது ஜாதகம்",
                    ),
                    const SizedBox(height: 8),

                    // 4. ராகு - கேது செவ்வாய் ஜாதகம் (Rahu-Ketu Chevvai Jathagam)
                    _buildDoshamOption(
                      value: 'chevvai_rahu_ketu',
                      title: "ராகு - கேது செவ்வாய் ஜாதகம்",
                    ),
                    const SizedBox(height: 8),

                    // 5. மறுமணம் ஜாதகம் (Marumanam Jathagam)
                    _buildDoshamOption(
                      value: 'marumanam',
                      title: "மறுமணம் ஜாதகம்",
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    const Text(
                      "அனைத்து ஜாதக வரன்களும் காட்டப்படும்",
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF1B6B38), fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Fixed Age Selector
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE0D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.cake_outlined, color: Color(0xFF7A132B), size: 18),
                          SizedBox(width: 8),
                          Text(
                            "வயது வடிகட்டி (Age)",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF332024)),
                          ),
                        ],
                      ),
                      Switch(
                        value: _filterByAge,
                        activeThumbColor: const Color(0xFF7A132B),
                        onChanged: (val) => setState(() => _filterByAge = val),
                      ),
                    ],
                  ),
                  if (!_filterByAge)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        "அனைத்து வயது வரன்களும்",
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF1B6B38), fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (_filterByAge) ...[
                    const SizedBox(height: 8),
                    // Stepper & Fixed Age Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "தேர்ந்தெடுத்த வயது:",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF6B585C), fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (_fixedAge > 18) {
                                  setState(() => _fixedAge--);
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF3EC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFEADBCE)),
                                ),
                                child: const Icon(Icons.remove, size: 16, color: Color(0xFF7A132B)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7A132B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "$_fixedAge வயது",
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                if (_fixedAge < 60) {
                                  setState(() => _fixedAge++);
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF3EC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFEADBCE)),
                                ),
                                child: const Icon(Icons.add, size: 16, color: Color(0xFF7A132B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Single Slider
                    Slider(
                      value: _fixedAge.toDouble(),
                      min: 18,
                      max: 60,
                      divisions: 42,
                      label: "$_fixedAge",
                      activeColor: const Color(0xFF7A132B),
                      inactiveColor: const Color(0xFFEADBCE),
                      onChanged: (val) => setState(() => _fixedAge = val.round()),
                    ),
                    const SizedBox(height: 4),

                    // Tolerance Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _exactAgeMatch
                                ? "$_fixedAge வயது மட்டும்"
                                : "$_fixedAge வயது (±1 வருடம்)",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B585C)),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _exactAgeMatch = !_exactAgeMatch),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _exactAgeMatch,
                                activeColor: const Color(0xFF7A132B),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (v) => setState(() => _exactAgeMatch = v ?? false),
                              ),
                              const Text(
                                "துல்லிய வயது மட்டும்",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 5. Rasi Filter (Multi-select Dropdown Menu)
            _buildMultiSelectDropdownSection(
              icon: Icons.brightness_5_rounded,
              title: "ராசி (Rasi)",
              subtitle: "விருப்பமான ராசிகளைத் தேர்வு செய்யவும்:",
              allItems: _rasisList,
              selectedSet: _selectedRasis,
              isExpanded: _isRasiExpanded,
              onToggleExpand: () => setState(() => _isRasiExpanded = !_isRasiExpanded),
              columns: 2,
              maxHeight: 220,
              onToggleItem: (item) {
                setState(() {
                  if (_selectedRasis.contains(item)) {
                    _selectedRasis.remove(item);
                  } else {
                    _selectedRasis.add(item);
                  }
                });
              },
              onSelectAll: () {
                setState(() {
                  _selectedRasis.clear();
                  _selectedRasis.addAll(_rasisList);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedRasis.clear();
                });
              },
            ),

            const SizedBox(height: 14),

            // 6. Star Filter (Multi-select Dropdown Menu with Search)
            _buildMultiSelectDropdownSection(
              icon: Icons.star_rounded,
              title: "நட்சத்திரம் (Star)",
              subtitle: "விருப்பமான நட்சத்திரங்களைத் தேர்வு செய்யவும்:",
              allItems: _starsList,
              selectedSet: _selectedStars,
              isExpanded: _isStarExpanded,
              onToggleExpand: () => setState(() => _isStarExpanded = !_isStarExpanded),
              maxHeight: 220,
              scrollController: _starScrollController,
              showSearch: true,
              searchQuery: _starSearchQuery,
              onSearchChanged: (val) => setState(() => _starSearchQuery = val),
              onToggleItem: (item) {
                setState(() {
                  if (_selectedStars.contains(item)) {
                    _selectedStars.remove(item);
                  } else {
                    _selectedStars.add(item);
                  }
                });
              },
              onSelectAll: () {
                setState(() {
                  _selectedStars.clear();
                  _selectedStars.addAll(_starsList);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedStars.clear();
                });
              },
            ),

            const SizedBox(height: 14),

            // 7. Education Filter (Multi-select Dropdown Menu)
            _buildMultiSelectDropdownSection(
              icon: Icons.school_rounded,
              title: "கல்வித் தகுதி (Education)",
              subtitle: "விருப்பமான படிப்புகளைத் தேர்வு செய்யவும்:",
              allItems: _educationList,
              selectedSet: _selectedEducations,
              isExpanded: _isEducationExpanded,
              onToggleExpand: () => setState(() => _isEducationExpanded = !_isEducationExpanded),
              columns: 1,
              maxHeight: 200,
              onToggleItem: (item) {
                setState(() {
                  if (_selectedEducations.contains(item)) {
                    _selectedEducations.remove(item);
                  } else {
                    _selectedEducations.add(item);
                  }
                });
              },
              onSelectAll: () {
                setState(() {
                  _selectedEducations.clear();
                  _selectedEducations.addAll(_educationList);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedEducations.clear();
                });
              },
            ),

            const SizedBox(height: 14),

            // 8. Location Filter (Multi-select Dropdown Menu)
            _buildMultiSelectDropdownSection(
              icon: Icons.location_on_rounded,
              title: "இருப்பிடம் / ஊர் (Location)",
              subtitle: "விருப்பமான ஊர்களைத் தேர்வு செய்யவும்:",
              allItems: _locationList,
              selectedSet: _selectedLocations,
              isExpanded: _isLocationExpanded,
              onToggleExpand: () => setState(() => _isLocationExpanded = !_isLocationExpanded),
              columns: 2,
              maxHeight: 200,
              onToggleItem: (item) {
                setState(() {
                  if (_selectedLocations.contains(item)) {
                    _selectedLocations.remove(item);
                  } else {
                    _selectedLocations.add(item);
                  }
                });
              },
              onSelectAll: () {
                setState(() {
                  _selectedLocations.clear();
                  _selectedLocations.addAll(_locationList);
                });
              },
              onClearAll: () {
                setState(() {
                  _selectedLocations.clear();
                });
              },
            ),

            const SizedBox(height: 24),

            // Search CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _applySearch,
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "வரன்களைக் காண்க (Search)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A132B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDoshamOption({
    required String value,
    required String title,
    String? subtitle,
  }) {
    final isSelected = _selectedDoshams.contains(value);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            if (_selectedDoshams.length > 1) {
              _selectedDoshams.remove(value);
            }
          } else {
            _selectedDoshams.add(value);
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEDE0D5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isSelected ? const Color(0xFF7A132B) : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF7A132B) : const Color(0xFF332024),
                ),
              ),
            ),
            if (subtitle != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7A132B).withValues(alpha: 0.1) : const Color(0xFFF5EBE1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF7A132B) : const Color(0xFF8C7355),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSelectionSummary(Set<String> selectedSet, String defaultPlaceholder) {
    if (selectedSet.isEmpty) {
      return defaultPlaceholder;
    }
    if (selectedSet.length == 1) {
      return selectedSet.first;
    }
    if (selectedSet.length == 2) {
      return "${selectedSet.first}, ${selectedSet.last}";
    }
    return "${selectedSet.first}, ${selectedSet.elementAt(1)} (+${selectedSet.length - 2})";
  }

  Widget _buildMultiSelectDropdownSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> allItems,
    required Set<String> selectedSet,
    required bool isExpanded,
    required VoidCallback onToggleExpand,
    required ValueChanged<String> onToggleItem,
    required VoidCallback onSelectAll,
    required VoidCallback onClearAll,
    bool showSearch = false,
    String? searchQuery,
    ValueChanged<String>? onSearchChanged,
    ScrollController? scrollController,
    double maxHeight = 220,
    int columns = 1,
  }) {
    final isAllSelected = selectedSet.isNotEmpty && selectedSet.length == allItems.length;
    final displayItems = (showSearch && searchQuery != null && searchQuery.trim().isNotEmpty)
        ? allItems.where((it) => it.toLowerCase().contains(searchQuery.trim().toLowerCase())).toList()
        : allItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? const Color(0xFF7A132B) : const Color(0xFFEDE0D5),
          width: isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown clickable trigger header
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: const Color(0xFF7A132B), size: 19),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF332024),
                          ),
                        ),
                      ),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: selectedSet.isEmpty
                              ? const Color(0xFFF7EFE9)
                              : (isAllSelected ? const Color(0xFFE8F5E9) : const Color(0xFFFFF9E6)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selectedSet.isEmpty
                                ? const Color(0xFFEADBCE)
                                : (isAllSelected ? const Color(0xFFA5D6A7) : const Color(0xFFE2CA7E)),
                          ),
                        ),
                        child: Text(
                          selectedSet.isEmpty
                              ? "0 தேர்வு"
                              : (isAllSelected ? "அனைத்தும் (${allItems.length})" : "${selectedSet.length} தேர்வு"),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: selectedSet.isEmpty
                                ? const Color(0xFF8C7A7E)
                                : (isAllSelected ? const Color(0xFF1B6B38) : const Color(0xFF7A132B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dropdown box appearance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: selectedSet.isEmpty ? const Color(0xFFFAF6F2) : const Color(0xFFFFFDF9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpanded ? const Color(0xFF7A132B) : const Color(0xFFEADBCE),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedSet.isEmpty
                                ? "எதுவும் தேர்ந்தெடுக்கப்படவில்லை (None selected)"
                                : _getSelectionSummary(selectedSet, "எதுவும் தேர்ந்தெடுக்கப்படவில்லை (None selected)"),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selectedSet.isEmpty ? FontWeight.normal : FontWeight.w600,
                              color: selectedSet.isEmpty ? const Color(0xFF8C7A7E) : const Color(0xFF580B23),
                              fontStyle: selectedSet.isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF7A132B),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown content when expanded
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF0E4D8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF7D6A6E)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Select All / Clear buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onSelectAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7EFE9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFEADBCE)),
                              ),
                              child: const Text(
                                "அனைத்தும்",
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: onClearAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7EFE9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFEADBCE)),
                              ),
                              child: const Text(
                                "அழி",
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showSearch) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEADBCE)),
                      ),
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: "நட்சத்திரத்தைத் தேடுக (Search Star)...",
                          hintStyle: TextStyle(fontSize: 11.5, color: Colors.grey),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A132B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBF7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEADBCE)),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(8),
                        child: columns == 2
                            ? _buildTwoColumnCheckboxes(
                                items: displayItems,
                                selectedSet: selectedSet,
                                onToggle: onToggleItem,
                              )
                            : Column(
                                children: displayItems.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: _buildCheckboxTile(
                                      title: item,
                                      isSelected: selectedSet.contains(item),
                                      onTap: () => onToggleItem(item),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onToggleExpand,
                      icon: const Icon(Icons.check_rounded, size: 16, color: Color(0xFF7A132B)),
                      label: const Text(
                        "முடிந்தது (Done)",
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A132B)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTwoColumnCheckboxes({
    required List<String> items,
    required Set<String> selectedSet,
    required ValueChanged<String> onToggle,
  }) {
    final mid = (items.length / 2).ceil();
    final col1 = items.sublist(0, mid);
    final col2 = items.sublist(mid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: col1.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildCheckboxTile(
                  title: item,
                  isSelected: selectedSet.contains(item),
                  onTap: () => onToggle(item),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: col2.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildCheckboxTile(
                  title: item,
                  isSelected: selectedSet.contains(item),
                  onTap: () => onToggle(item),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A132B) : const Color(0xFFEDE0D5),
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isSelected ? const Color(0xFF7A132B) : Colors.grey.shade400,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF7A132B) : const Color(0xFF332024),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
