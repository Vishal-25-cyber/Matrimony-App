import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import '../../core/widgets/profile_card.dart';
import '../profiles/profile_details_screen.dart';
import '../cart/contact_cart_screen.dart';
import 'search_filter_screen.dart';
import '../../core/utils/navigation_helper.dart';

class SearchResultsScreen extends StatefulWidget {
  final MockDataService mockData;
  final String title;
  final List<ProfileModel> profiles;

  const SearchResultsScreen({
    super.key,
    required this.mockData,
    this.title = 'தேடல் முடிவுகள் / Search Results',
    required this.profiles,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.mockData,
      builder: (context, _) {
        // Sync live profile state (unlocks, shortlist) from mockData
        final baseList = widget.profiles
            .map((p) => widget.mockData.getProfileById(p.id) ?? p)
            .toList();

        // Apply in-page search filter if user types in search box
        final displayList = _filterQuery.isEmpty
            ? baseList
            : baseList.where((p) {
                final q = _filterQuery.toLowerCase();
                return p.name.toLowerCase().contains(q) ||
                    (p.nameTamil?.toLowerCase().contains(q) ?? false) ||
                    p.id.toLowerCase().contains(q) ||
                    p.location.toLowerCase().contains(q) ||
                    p.occupation.toLowerCase().contains(q) ||
                    p.education.toLowerCase().contains(q) ||
                    (p.star?.toLowerCase().contains(q) ?? false) ||
                    (p.rasi?.toLowerCase().contains(q) ?? false);
              }).toList();

        final cartCount = widget.mockData.cartCount;
        final totalAmount = widget.mockData.cartTotalAmount;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7A132B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: "பின்செல்க / Back",
              onPressed: () => SafeNavigation.safePop(context, initialIndex: 1),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${displayList.length} வரன்கள் கண்டறியப்பட்டது • ₹25/contact",
                  style: const TextStyle(fontSize: 10, color: Color(0xFFF0D68A), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                tooltip: "வடிகட்டி / Filter",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchFilterScreen(mockData: widget.mockData),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Live in-page filter search bar
              if (baseList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: TextField(
                    controller: _queryController,
                    onChanged: (val) => setState(() => _filterQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: "முடிவுகளில் தேடுக (பெயர், ID, ஊர், படிப்பு)...",
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E8F92)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF7A132B)),
                      suffixIcon: _filterQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _queryController.clear();
                                setState(() => _filterQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2D6CB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2D6CB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF7A132B), width: 1.5),
                      ),
                    ),
                  ),
                ),

              // Results List or Empty State
              Expanded(
                child: displayList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                "பொருத்தமான வரன்கள் இல்லை",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF580B23)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _filterQuery.isNotEmpty
                                    ? "'$_filterQuery' என்ற தேடலுக்கு பொருத்தமான வரன்கள் இல்லை."
                                    : "தேடல் நிபந்தனைகளை மாற்றி மீண்டும் முயற்சிக்கவும்.",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7A132B),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (_filterQuery.isNotEmpty) {
                                    _queryController.clear();
                                    setState(() => _filterQuery = '');
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(_filterQuery.isNotEmpty
                                    ? "தேடலை நீக்குக / Clear Search"
                                    : "வடிகட்டி மாற்று / Edit Filters"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(14, 6, 14, cartCount > 0 ? 80 : 14),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final profile = displayList[index];

                          return ProfileCard(
                            profile: profile,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileDetailsScreen(
                                    profileId: profile.id,
                                    mockData: widget.mockData,
                                  ),
                                ),
                              );
                            },
                            onShortlistToggle: () {
                              final wasShortlisted = profile.isShortlisted;
                              widget.mockData.toggleShortlist(profile.id);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    wasShortlisted
                                        ? "${profile.name} விருப்பப்பட்டியலில் இருந்து நீக்கப்பட்டது"
                                        : "${profile.name} விருப்பப்பட்டியலில் சேர்க்கப்பட்டது! ✓ (Liked)",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF7A132B),
                                ),
                              );
                            },
                            onSendInterest: () => widget.mockData.sendInterest(profile.id),
                            mockData: widget.mockData,
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomSheet: cartCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF580B23),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "கூடை: $cartCount வரன்கள்",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "மொத்தம்: ₹${totalAmount.toInt()}",
                            style: const TextStyle(color: Color(0xFFF0D68A), fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF580B23),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContactCartScreen(
                                mockData: widget.mockData,
                                initialTabIndex: 2,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text(
                          "QR கட்டணம் செலுத்த / Pay QR",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
