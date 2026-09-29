import 'package:flutter/material.dart';
import '../core/widgets/horoscope_comparison_dialog.dart';
import '../services/mock_data_service.dart';
import 'home/home_screen.dart';
import 'profiles/my_profile_screen.dart';
import 'search/search_filter_screen.dart';
import 'shortlist/shortlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final MockDataService _mockData = MockDataService();
  int _searchRefreshKey = 0; // incremented each time user taps Search tab while on it
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      HomeScreen(
        mockData: _mockData,
        onNavigateToTab: _onTabTapped,
      ),
      SearchFilterScreen(
        key: ValueKey('search_$_searchRefreshKey'),
        mockData: _mockData,
        onBackToHome: () => _onTabTapped(0),
      ),
      HoroscopeComparisonDialog(
        mockData: _mockData,
        initialShowUpload: true,
        isDialog: false,
      ),
      ShortlistScreen(
        mockData: _mockData,
        onBackToHome: () => _onTabTapped(0),
      ),
      MyProfileScreen(
        mockData: _mockData,
        onBackToHome: () => _onTabTapped(0),
      ),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index && index == 1) {
      // Re-tapping Search tab: refresh / reset the search screen
      setState(() {
        _searchRefreshKey++;
        _buildPages();
      });
    } else if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _mockData,
      builder: (context, _) {
        final shortlistedCount = _mockData.shortlistedProfiles.length;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_currentIndex != 0) {
              _onTabTapped(0);
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF580B23),
              unselectedItemColor: const Color(0xFF7E6F72),
              selectedFontSize: 11,
              unselectedFontSize: 10.5,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              showUnselectedLabels: true,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 22),
                  activeIcon: Icon(Icons.home_rounded, size: 22),
                  label: 'முகப்பு',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined, size: 22),
                  activeIcon: Icon(Icons.search_rounded, size: 22),
                  label: 'தேடல்',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.compare_arrows_rounded, size: 22),
                  activeIcon: Icon(Icons.compare_arrows_rounded, size: 22),
                  label: 'பொருத்தம்',
                ),
                BottomNavigationBarItem(
                  icon: shortlistedCount > 0
                      ? Badge(
                          backgroundColor: const Color(0xFF8C1D38),
                          label: Text(
                            '$shortlistedCount',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          child: const Icon(Icons.favorite_border_rounded, size: 22),
                        )
                      : const Icon(Icons.favorite_border_rounded, size: 22),
                  activeIcon: const Icon(Icons.favorite_rounded, size: 22),
                  label: 'விருப்பம்',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  activeIcon: Icon(Icons.person_rounded, size: 22),
                  label: 'கணக்கு',
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
