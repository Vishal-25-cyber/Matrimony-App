import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final isDesktop = constraints.maxWidth >= 1024;

              // Tablet & Desktop Responsive Layout with NavigationRail
              if (isWide) {
                return Scaffold(
                  body: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _onTabTapped,
                        extended: isDesktop,
                        minExtendedWidth: 200,
                        backgroundColor: Colors.white,
                        selectedIconTheme: const IconThemeData(color: Color(0xFF7A132B), size: 24),
                        unselectedIconTheme: const IconThemeData(color: Color(0xFF7E6F72), size: 22),
                        selectedLabelTextStyle: const TextStyle(
                          color: Color(0xFF7A132B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        unselectedLabelTextStyle: const TextStyle(
                          color: Color(0xFF7E6F72),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/images/founder_arumugam.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 10),
                                const Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppConstants.appNameTamil,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7A132B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        AppConstants.appNameEnglish,
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8C797C),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        destinations: [
                          const NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: Text('முகப்பு'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.search_outlined),
                            selectedIcon: Icon(Icons.search_rounded),
                            label: Text('தேடல்'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.compare_arrows_rounded),
                            selectedIcon: Icon(Icons.compare_arrows_rounded),
                            label: Text('பொருத்தம்'),
                          ),
                          NavigationRailDestination(
                            icon: shortlistedCount > 0
                                ? Badge(
                                    backgroundColor: const Color(0xFF8C1D38),
                                    label: Text(
                                      '$shortlistedCount',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    child: const Icon(Icons.favorite_border_rounded),
                                  )
                                : const Icon(Icons.favorite_border_rounded),
                            selectedIcon: const Icon(Icons.favorite_rounded),
                            label: const Text('விருப்பம்'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.person_outline_rounded),
                            selectedIcon: Icon(Icons.person_rounded),
                            label: Text('கணக்கு'),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEADBCE)),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Mobile Layout with BottomNavigationBar
              return Scaffold(
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
              );
            },
          ),
        );
      },
    );
  }
}
