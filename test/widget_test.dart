import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrimony_app/main.dart';
import 'package:matrimony_app/core/constants/app_constants.dart';
import 'package:matrimony_app/features/main_navigation_screen.dart';
import 'package:matrimony_app/features/auth/login_screen.dart';
import 'package:matrimony_app/services/mock_data_service.dart';
import 'package:matrimony_app/features/home/home_screen.dart';
import 'package:matrimony_app/features/home/menu_drawer.dart';
import 'package:matrimony_app/features/profiles/profile_details_screen.dart';
import 'package:matrimony_app/features/profiles/edit_profile_screen.dart';
import 'package:matrimony_app/core/widgets/profile_card.dart';
import 'package:matrimony_app/core/widgets/horoscope_comparison_dialog.dart';
import 'package:matrimony_app/core/widgets/horoscope_certificate_dialog.dart';
import 'package:matrimony_app/core/widgets/big_horoscope_charts_dialog.dart';
import 'package:matrimony_app/features/search/search_results_screen.dart';
import 'package:matrimony_app/features/cart/contact_cart_screen.dart';
import 'package:matrimony_app/features/settings/settings_screen.dart';
import 'package:matrimony_app/services/auth_service.dart';
import 'package:matrimony_app/services/mongodb_service.dart';
import 'package:matrimony_app/features/profiles/my_profile_screen.dart';
import 'package:matrimony_app/core/widgets/avatar_image.dart';
import 'dart:typed_data';
import 'package:matrimony_app/features/shortlist/shortlist_screen.dart';
import 'package:matrimony_app/features/auth/splash_screen.dart';

void main() {
  testWidgets('MatrimonyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MatrimonyApp());
    expect(find.text(AppConstants.appName), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('LoginScreen renders and switches tabs without overflow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify login button is present
    expect(find.text('உள்நுழைவு / Login'), findsWidgets);

    // Tap switch to signup
    final signUpLink = find.text('பதிவு செய்க / Sign Up');
    expect(signUpLink, findsWidgets);
    await tester.tap(signUpLink.first);
    await tester.pumpAndSettle();

    // Verify we are on step 1 of signup
    expect(find.text('Step 1 of 3'), findsOneWidget);

    // Switch back to login
    final loginLink = find.text('உள்நுழைக / Login');
    expect(loginLink, findsOneWidget);
    await tester.ensureVisible(loginLink);
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(find.text('உள்நுழைவு / Login'), findsWidgets);
  });

  testWidgets('MainNavigationScreen renders all tabs cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom nav items
    expect(find.text('முகப்பு'), findsOneWidget);
    expect(find.text('தேடல்'), findsOneWidget);
    expect(find.text('பொருத்தம்'), findsOneWidget);
    expect(find.text('விருப்பம்'), findsOneWidget);
    expect(find.text('கணக்கு'), findsOneWidget);

    // Switch to Search tab
    await tester.tap(find.text('தேடல்'));
    await tester.pumpAndSettle();

    // Switch to Porutham tab
    await tester.tap(find.text('பொருத்தம்'));
    await tester.pumpAndSettle();

    // Switch to Shortlist tab
    await tester.tap(find.text('விருப்பம்'));
    await tester.pumpAndSettle();

    // Switch to Profile tab
    await tester.tap(find.text('கணக்கு'));
    await tester.pumpAndSettle();

    // Switch back to Home
    await tester.tap(find.text('முகப்பு'));
    await tester.pumpAndSettle();
  });

  testWidgets('HomeScreen renders quick services and menu drawer', (WidgetTester tester) async {
    final mockData = MockDataService();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          mockData: mockData,
          onNavigateToTab: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Mini Member Dashboard
    expect(find.textContaining('வணக்கம்'), findsOneWidget);
    expect(find.text('விருப்பங்கள்'), findsOneWidget);
    expect(find.text('பொருத்தங்கள்'), findsOneWidget);
    expect(find.text('தொடர்புகள்'), findsOneWidget);
    expect(find.textContaining('சென்னிமலை ஆறுமுகம்'), findsNothing);

    // Open Drawer
    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.byType(AppMenuDrawer), findsOneWidget);
    expect(find.text('எங்களை பற்றி / About Us'), findsOneWidget);

    // Tap About Us in drawer
    await tester.tap(find.text('எங்களை பற்றி / About Us'));
    await tester.pumpAndSettle();

    // Verify dialog opened without overflow
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('சரி / Close'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('சரி / Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('Free horoscope and locked contact payment unlock flow test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockData = MockDataService();
    // Get first profile which has isContactUnlocked = false
    final profile = mockData.allProfiles.firstWhere((p) => !p.isContactUnlocked);
    expect(profile.isContactUnlocked, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileDetailsScreen(
          profileId: profile.id,
          mockData: mockData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial State: Profile Details Screen renders with free details & horoscope tabs
    expect(find.textContaining(profile.name), findsWidgets);
    expect(find.text("விவரம் / Details"), findsOneWidget);
    expect(find.text("ஜாதகம் / Horoscope"), findsOneWidget);
    expect(find.text("குடும்பம் & தொடர்பு 🔒"), findsOneWidget);


    // 2. Switch to Horoscope Tab (100% Free Access without lock or preview restriction)
    await tester.tap(find.text("ஜாதகம் / Horoscope"));
    await tester.pumpAndSettle();

    // Verify free horoscope elements are shown
    expect(find.textContaining("அடிப்படை ஜாதகக் குறிப்புகள்"), findsOneWidget);
    expect(find.text("ஜாதகக் கட்டங்கள் / Astrological Charts"), findsOneWidget);
    expect(find.text("ராசிக் கட்டம்"), findsOneWidget);
    expect(find.text("நவாம்சக் கட்டம்"), findsOneWidget);
    expect(find.textContaining("ஜாதகக் கட்டங்களைப் பதிவிறக்குக"), findsOneWidget);

    // 3. Switch to Family & Contact Tab (Locked before payment)
    await tester.tap(find.text("குடும்பம் & தொடர்பு 🔒"));
    await tester.pumpAndSettle();

    // Verify contact is locked and unlock button is present
    expect(find.text("நேரடி தொடர்பு எண்கள் பூட்டப்பட்டுள்ளது"), findsOneWidget);
    expect(find.text("💳 ₹25 செலுத்தி தொடர்பு எண் பெற / Unlock Contact"), findsOneWidget);

    // 4. Tap Unlock Contact button to open ContactUnlockDialog modal
    final unlockButton = find.text("💳 ₹25 செலுத்தி தொடர்பு எண் பெற / Unlock Contact");
    await tester.ensureVisible(unlockButton);
    await tester.tap(unlockButton);
    await tester.pumpAndSettle();

    // Verify ContactUnlockDialog is displayed
    expect(find.text("தொடர்பு விவரங்கள் திறப்பு"), findsOneWidget);
    expect(find.text("UPI ID: pandarathar@upi"), findsOneWidget);
    expect(find.text("₹25 செலுத்தி தொடர்பை திறக்கவும்"), findsOneWidget);

    // 5. Complete simulated payment
    final payButton = find.text("₹25 செலுத்தி தொடர்பை திறக்கவும்");
    await tester.tap(payButton);
    await tester.pump(); // Triggers setState(_isProcessing = true)

    // Advance simulated payment delay (900ms processing + 700ms success)
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // 6. Verify Profile Contact is now unlocked in MockDataService
    final updatedProfile = mockData.getProfileById(profile.id);
    expect(updatedProfile?.isContactUnlocked, isTrue);

    // 7. Verify ProfileDetailsScreen has updated to full unlocked contact state
    expect(find.text("குடும்பம் & தொடர்பு ✓"), findsOneWidget);
    expect(find.text("திறக்கப்பட்டது ✓"), findsOneWidget);
    expect(find.text(profile.phone), findsWidgets);
    expect(find.text("அழைக்க / Call"), findsOneWidget);
    expect(find.text("WhatsApp"), findsWidgets);
  });

  testWidgets('ProfileCard buttons have fixed aligned height and zero AI sparkle icons', (WidgetTester tester) async {
    final mockData = MockDataService(fresh: true);
    final profile = mockData.allProfiles.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            profile: profile,
            mockData: mockData,
            onTap: () {},
            onShortlistToggle: () {},
            onSendInterest: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both action buttons are rendered
    final viewBtnFinder = find.widgetWithText(OutlinedButton, 'விவரம் / View');
    final payBtnFinder = find.widgetWithText(ElevatedButton, 'விருப்பம் ₹25');
    expect(viewBtnFinder, findsOneWidget);
    expect(payBtnFinder, findsOneWidget);

    // Verify both buttons are wrapped in fixed 38px height SizedBox containers
    final viewSizedBox = tester.widget<SizedBox>(
      find.ancestor(of: viewBtnFinder, matching: find.byType(SizedBox)).first,
    );
    final paySizedBox = tester.widget<SizedBox>(
      find.ancestor(of: payBtnFinder, matching: find.byType(SizedBox)).first,
    );
    expect(viewSizedBox.height, 38.0);
    expect(paySizedBox.height, 38.0);

    // Verify zero AI sparkle icons (Icons.auto_awesome) exist in ProfileCard
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsNothing);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsNothing);
  });

  testWidgets('SearchResultsScreen shows only matching profiles and empty state when 0 matches', (WidgetTester tester) async {
    final mockData = MockDataService();
    // 1. Test when search returns 1 profile
    final singleProfile = [mockData.getProfileById('PM-1002')!];
    await tester.pumpWidget(
      MaterialApp(
        home: SearchResultsScreen(
          profiles: singleProfile,
          mockData: mockData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify exactly 1 profile card is shown (Kavitha M.)
    expect(find.textContaining('Kavitha M.'), findsOneWidget);
    expect(find.textContaining('Soundarya R.'), findsNothing);
    expect(find.textContaining('1 வரன்கள் கண்டறியப்பட்டது'), findsOneWidget);

    // 2. Test when search returns 0 profiles (empty list)
    await tester.pumpWidget(
      MaterialApp(
        home: SearchResultsScreen(
          profiles: const [],
          mockData: mockData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify it shows the empty state and NOT all profiles!
    expect(find.text('பொருத்தமான வரன்கள் இல்லை'), findsOneWidget);
    expect(find.textContaining('Kavitha M.'), findsNothing);
    expect(find.textContaining('Soundarya R.'), findsNothing);
  });

  testWidgets('HoroscopeComparisonDialog displays Tamil title நட்சத்திரப் பொருத்தம் and showcases single star porutham chart image', (WidgetTester tester) async {
    final mockData = MockDataService();
    final soundarya = mockData.getProfileById('PM-1001')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoroscopeComparisonDialog(
            brideOrProfile1: soundarya,
            mockData: mockData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title in Tamil wordings: நட்சத்திரப் பொருத்தம்
    expect(find.textContaining('நட்சத்திரப் பொருத்தம்'), findsWidgets);
    expect(find.textContaining('விவாக நட்சத்திரப் பொருத்த அட்டவணை'), findsOneWidget);

    // Verify star porutham chart image is showcased
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ShortlistScreen acts as a cart calculating ₹25 per profile and submits payment details with QR code', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    MockDataService.resetForTesting();
    final mockData = MockDataService();

    // Ensure 2 locked profiles are shortlisted
    if (!mockData.getProfileById('PM-1002')!.isShortlisted) {
      mockData.toggleShortlist('PM-1002');
    }
    if (!mockData.getProfileById('PM-1003')!.isShortlisted) {
      mockData.toggleShortlist('PM-1003');
    }

    await tester.pumpWidget(
      MaterialApp(
        home: ShortlistScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Cart Summary Header and pricing calculation: 2 வரன்கள் × ₹25
    expect(find.textContaining('விருப்பப்பட்ட வரன்கள்'), findsWidgets);
    expect(find.textContaining('வரன்கள் × ₹25'), findsWidgets);
    expect(find.textContaining('₹50'), findsWidgets);

    // Find and tap the Pay / QR button
    final payBtn = find.textContaining('செலுத்துக').first;
    await tester.ensureVisible(payBtn);
    await tester.tap(payBtn);
    await tester.pumpAndSettle();

    // Verify Payment BottomSheet opened with QR code and Form Fields
    expect(find.textContaining('QR கட்டணம் & தொடர்பு திறத்தல்'), findsOneWidget);
    expect(find.textContaining('pandaratharmatrimony@upi'), findsOneWidget);
    expect(find.textContaining('செலுத்துபவர் பெயர்'), findsOneWidget);
    expect(find.textContaining('செலுத்தப்பட்ட தொகை'), findsOneWidget);
    expect(find.textContaining('பரிவர்த்தனை எண்'), findsOneWidget);

    // Enter 12-digit UTR
    final utrField = find.widgetWithText(TextField, 'பரிவர்த்தனை எண் / Transaction ID / UTR *');
    expect(utrField, findsOneWidget);
    await tester.enterText(utrField, '426891045231');
    await tester.pumpAndSettle();

    // Submit payment
    final submitBtn = find.textContaining('ஒப்புதலுக்கு சமர்ப்பிக்கவும்');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify submission status
    expect(find.textContaining('கட்டணம் சரிபார்க்கப்படுகிறது'), findsOneWidget);
  });

  testWidgets('ShortlistScreen admin approval unlocks full contact details and phone for liked profiles', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    MockDataService.resetForTesting();
    final mockData = MockDataService();

    // Shortlist profile PM-1002 (Kavitha)
    if (!mockData.getProfileById('PM-1002')!.isShortlisted) {
      mockData.toggleShortlist('PM-1002');
    }

    // Submit payment for this profile
    mockData.submitPaymentRequestWithDetails(
      userName: "Karthik Sundaram",
      amount: 25.0,
      utrNumber: "UPI491820491823",
      profileIds: ["PM-1002"],
      profileNames: ["Kavitha M. (PM-1002)"],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ShortlistScreen(mockData: mockData, isAdmin: true),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Pending Status
    expect(find.textContaining('கட்டணம் சரிபார்க்கப்படுகிறது'), findsOneWidget);

    // Tap Admin Quick Approve button
    final approveBtn = find.textContaining('நிர்வாகி உடனடி ஒப்புதல்');
    expect(approveBtn, findsOneWidget);
    await tester.tap(approveBtn);
    await tester.pumpAndSettle();

    // Verify profile is now UNLOCKED with Unlocked status and View button
    expect(find.textContaining('Unlocked ✓'), findsOneWidget);

    // Tap View Contact button to open unlocked details modal
    final viewBtn = find.textContaining('தொடர்பு பார்க்க / View');
    expect(viewBtn, findsOneWidget);
    await tester.tap(viewBtn);
    await tester.pumpAndSettle();

    // Verify contact modal shows unlocked title and WhatsApp button
    expect(find.textContaining('தொடர்பு விவரங்கள் திறக்கப்பட்டது ✓'), findsOneWidget);
    expect(find.textContaining('வாட்ஸ்அப்'), findsWidgets);
  });

  testWidgets('HoroscopeCertificateDialog shows comparison option and download button', (WidgetTester tester) async {
    final mockData = MockDataService();
    final soundarya = mockData.getProfileById('PM-1001')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoroscopeCertificateDialog(
            profile: soundarya,
            mockData: mockData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both download button and compare horoscopes card exist
    expect(find.textContaining('ஜாதகத்தைப் பதிவிறக்குக'), findsOneWidget);
    expect(find.textContaining('இரு ஜாதகப் பொருத்தம் பார்க்க'), findsOneWidget);
    expect(find.text('பொருத்தம் பார்'), findsOneWidget);
  });

  testWidgets('BigHoroscopeChartsDialog displays the enlarged horoscope chart tables cleanly', (WidgetTester tester) async {
    final mockData = MockDataService();
    final soundarya = mockData.getProfileById('PM-1001')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BigHoroscopeChartsDialog(profile: soundarya),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and chart tables are displayed big
    expect(find.textContaining('ஜாதகக் கட்டங்கள் (பெரிதாக)'), findsOneWidget);
    expect(find.textContaining('ராசி & நவாம்சம் (Both)'), findsOneWidget);
    expect(find.textContaining('ராசிக் கட்டம் (Rasi)'), findsOneWidget);
    expect(find.textContaining('நவாம்சக் கட்டம் (Navamsam)'), findsOneWidget);
    expect(find.text('ராசி'), findsWidgets);
    expect(find.text('நவாம்சம்'), findsWidgets);
    expect(find.textContaining('ஜாதகக் கட்டங்களைப் பதிவிறக்குக (PNG)'), findsOneWidget);

    // Switch to Rasi only view
    await tester.tap(find.textContaining('ராசிக் கட்டம் (Rasi)'));
    await tester.pumpAndSettle();
    expect(find.text('ராசி'), findsOneWidget);
  });

  testWidgets('EditProfileScreen renders cleanly with professional card layout', (WidgetTester tester) async {
    final mockData = MockDataService();

    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and save button
    expect(find.text('சுயவிவரம் திருத்துதல்'), findsOneWidget);
    expect(find.textContaining('Save Profile'), findsOneWidget);

    // Verify photo section and signup details
    expect(find.textContaining('சுயவிவரப் படம்'), findsOneWidget);
    expect(find.textContaining('பதிவு விவரங்கள்'), findsOneWidget);
    expect(find.textContaining('முழு பெயர்'), findsOneWidget);
    expect(find.textContaining('கைபேசி எண்'), findsOneWidget);
    expect(find.textContaining('மின்னஞ்சல்'), findsOneWidget);

    // Test saving profile
    await tester.tap(find.textContaining('Save Profile'));
    await tester.pumpAndSettle();
  });

  testWidgets('EditProfileScreen changes reflect in database and auth store', (WidgetTester tester) async {
    final mockData = MockDataService();
    final mongoDb = MongoDBService();
    final authService = AuthService();

    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Change Full Name
    final nameField = find.widgetWithText(TextField, 'Karthik');
    final targetNameField = nameField.evaluate().isNotEmpty ? nameField : find.byType(TextField).first;
    await tester.enterText(targetNameField, 'Karthik Pandarathar');

    // 2. Change Phone Number
    final phoneField = find.byType(TextField).at(1);
    await tester.enterText(phoneField, '9842199999');

    // 3. Change Email
    final emailField = find.byType(TextField).at(2);
    await tester.enterText(emailField, 'karthik.db@pandarathar.com');

    await tester.pumpAndSettle();

    // Tap Save button
    final saveBtn = find.textContaining('Save Profile');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify confirmation message
    expect(find.textContaining('தரவுத்தளத்தில் சேமிக்கப்பட்டது'), findsOneWidget);

    // Verify reflection in MockDataService
    expect(mockData.currentUser.name, 'Karthik Pandarathar');
    expect(mockData.currentUser.phone, '9842199999');
    expect(mockData.currentUser.email, 'karthik.db@pandarathar.com');

    // Verify reflection in AuthService
    expect(authService.currentUser?.name, 'Karthik Pandarathar');
    expect(authService.currentUser?.phone, '9842199999');
    expect(authService.currentUser?.email, 'karthik.db@pandarathar.com');

    // Verify reflection in MongoDB database cache
    final cachedUpdate = mongoDb.databaseCache['latest_profile_update'];
    expect(cachedUpdate, isNotNull);
    expect(cachedUpdate?['name'], 'Karthik Pandarathar');
    expect(cachedUpdate?['phone'], '9842199999');
    expect(cachedUpdate?['email'], 'karthik.db@pandarathar.com');
  });

  testWidgets('EditProfileScreen enforces 10-digit mobile and valid email validation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockData = MockDataService();

    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    final phoneField = find.byType(TextField).at(1);

    // 1. Clear phone field
    await tester.enterText(phoneField, '');
    await tester.pumpAndSettle();

    // 2. Enter an 11-digit number like 63811804888: LengthLimitingTextInputFormatter truncates to 10 digits
    await tester.enterText(phoneField, '63811804888');
    await tester.pumpAndSettle();

    final TextField phoneWidget = tester.widget(phoneField);
    expect(phoneWidget.controller?.text.length, 10);
    expect(phoneWidget.controller?.text, '6381180488');

    // 3. Enter invalid start digit (e.g. 1234567890) and check error
    await tester.enterText(phoneField, '1234567890');
    await tester.pumpAndSettle();
    expect(find.textContaining('6, 7, 8 அல்லது 9'), findsOneWidget);

    // 4. Restore valid phone number
    await tester.enterText(phoneField, '6381180488');
    await tester.pumpAndSettle();
    expect(find.textContaining('6, 7, 8 அல்லது 9'), findsNothing);

    // 5. Enter an invalid email address
    final emailField = find.byType(TextField).at(2);
    await tester.enterText(emailField, 'notanemail');
    await tester.pumpAndSettle();

    // Real-time error message should be displayed for email
    expect(find.textContaining('சரியான மின்னஞ்சல்'), findsOneWidget);

    // 6. Enter a valid email address
    await tester.enterText(emailField, 'vishal@pandarathar.com');
    await tester.pumpAndSettle();

    // Error message should disappear
    expect(find.textContaining('சரியான மின்னஞ்சல்'), findsNothing);
  });

  testWidgets('ContactCartScreen renders stored payment details, UTR and database status', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    MockDataService.resetForTesting();
    final mockData = MockDataService();

    await tester.pumpWidget(
      MaterialApp(
        home: ContactCartScreen(
          mockData: mockData,
          initialTabIndex: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. App bar and tabs render cleanly
    expect(find.text("எனது கட்டணங்கள் & தொடர்புகள்"), findsOneWidget);
    expect(find.textContaining("Payment Details"), findsOneWidget);
    expect(find.textContaining("கட்டணங்கள்"), findsWidgets);
    expect(find.textContaining("தொடர்புகள்"), findsWidgets);

    // 2. Database storage banner and indicators
    expect(find.text("சேமிக்கப்பட்ட கட்டண விவரங்கள்"), findsOneWidget);
    expect(find.text("MongoDB Database Synced & Stored Securely"), findsOneWidget);
    expect(find.text("MongoDB ✓"), findsWidgets);

    // 3. Stored payment request card details
    expect(find.text("REQ-928104"), findsOneWidget);
    expect(find.textContaining("UPI839102847192"), findsWidgets);
    expect(find.textContaining("Soundarya R."), findsWidgets);
    expect(find.textContaining("ஒப்புதல் பெற்றது"), findsWidgets);

    // 4. View Receipt Dialog opens
    final receiptBtn = find.text("ரசீது பார்க்க / View Receipt");
    expect(receiptBtn, findsOneWidget);
    await tester.tap(receiptBtn);
    await tester.pumpAndSettle();

    expect(find.text("அதிகாரப்பூர்வ கட்டண ரசீது / Official Receipt"), findsOneWidget);
    expect(find.text("MongoDB Cloud Database Verified ✓"), findsOneWidget);
    expect(find.text("சரி / Close"), findsOneWidget);

    // Close receipt dialog
    await tester.tap(find.text("சரி / Close"));
    await tester.pumpAndSettle();

    // 5. Switch to Unlocked Contacts tab
    await tester.tap(find.byIcon(Icons.contacts_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining("திறக்கப்பட்ட தொடர்புகள்"), findsWidgets);
  });

  testWidgets('SettingsScreen renders and all options work properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockData = MockDataService();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header & Section Titles
    expect(find.textContaining('Settings'), findsWidgets);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Privacy Options'), findsOneWidget);
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Logout / வெளியேறுக'), findsOneWidget);

    // 2. Open Language Dialog and select Tamil
    await tester.tap(find.text('App Language'));
    await tester.pumpAndSettle();
    expect(find.text('Select Language / மொழி'), findsOneWidget);
    await tester.tap(find.text('தமிழ் (Tamil)'));
    await tester.pumpAndSettle();
    expect(find.text('தமிழ் (Tamil)'), findsWidgets);

    // 3. Open Privacy Options Sheet
    await tester.tap(find.text('Privacy Options'));
    await tester.pumpAndSettle();
    expect(find.textContaining('தனியுரிமை அமைப்புகள்'), findsOneWidget);
    await tester.tap(find.textContaining('சேமிக்க'));
    await tester.pumpAndSettle();

    // 4. Open Notification Preferences Sheet
    await tester.tap(find.text('Notification Preferences'));
    await tester.pumpAndSettle();
    expect(find.textContaining('அறிவிப்பு விருப்பங்கள்'), findsOneWidget);
    await tester.tap(find.textContaining('சேமிக்க'));
    await tester.pumpAndSettle();

    // 5. Open Terms & Conditions Dialog
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('விதிமுறைகள் & நிபந்தனைகள்'), findsOneWidget);
    await tester.tap(find.textContaining('புரிந்துகொண்டேன்'));
    await tester.pumpAndSettle();

    // 6. Open Privacy Policy Dialog
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('தனியுரிமை கொள்கை'), findsOneWidget);
    await tester.tap(find.textContaining('சரி / Close'));
    await tester.pumpAndSettle();

    // 7. Open Change Password Dialog
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Change Password'), findsWidgets);
    await tester.tap(find.text('ரத்து / Cancel'));
    await tester.pumpAndSettle();

    // 8. Open Logout Dialog
    await tester.tap(find.text('Logout / வெளியேறுக'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Logout?'), findsOneWidget);
    await tester.tap(find.text('ரத்து / Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('MyProfileScreen displays uploaded profile image and syncs across AuthService and MockDataService', (WidgetTester tester) async {
    final mockData = MockDataService();
    // 1x1 transparent PNG bytes
    final dummyBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);

    // Apply image to current user
    mockData.updateUserProfile(
      mockData.currentUser.copyWith(
        imageBytes: dummyBytes,
        profileImageUrl: 'https://b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com/matrimony-profile-images/profiles/test.png',
      ),
    );

    // Verify AuthService also stores it
    await AuthService().updateCurrentUserAccount(
      name: mockData.currentUser.name,
      phone: mockData.currentUser.phone,
      email: mockData.currentUser.email,
      gender: mockData.currentUser.gender,
      imageBytes: dummyBytes,
      profileImageUrl: 'https://b535b7c908a09f10d27773b1b9536777.r2.cloudflarestorage.com/matrimony-profile-images/profiles/test.png',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MyProfileScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AvatarImage widget exists and receives imageBytes
    final avatarFinder = find.byType(AvatarImage);
    expect(avatarFinder, findsOneWidget);
    final avatarWidget = tester.widget<AvatarImage>(avatarFinder);
    expect(avatarWidget.imageBytes, isNotNull);
    expect(avatarWidget.imageBytes!.length, equals(dummyBytes.length));

    // Verify Image is rendered inside AvatarImage
    expect(find.byType(Image), findsOneWidget);

    // Trigger auth sync and verify image is preserved (not overwritten by null)
    mockData.syncWithAuth(AuthService().currentUserAccount);
    await tester.pumpAndSettle();

    expect(mockData.currentUser.imageBytes, isNotNull);
    final avatarAfterSync = tester.widget<AvatarImage>(avatarFinder);
    expect(avatarAfterSync.imageBytes, isNotNull);
  });

  testWidgets('ShortlistScreen renders empty state initially and shows only liked profiles when liked', (WidgetTester tester) async {
    MockDataService.resetForTesting();
    final mockData = MockDataService(fresh: true);

    await tester.pumpWidget(
      MaterialApp(
        home: ShortlistScreen(mockData: mockData),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initially no profile is liked, so empty state is displayed
    expect(find.text("விருப்பப்பட்ட வரன்கள் இல்லை"), findsOneWidget);
    expect(find.text("Soundarya R."), findsNothing);

    // 2. User likes Soundarya R. (PM-1001)
    mockData.toggleShortlist("PM-1001");
    await tester.pumpAndSettle();

    // 3. Soundarya R. alone shows in the shortlist
    expect(find.text("விருப்பப்பட்ட வரன்கள் இல்லை"), findsNothing);
    expect(find.text("Soundarya R."), findsOneWidget);
    expect(find.text("நீங்கள் விரும்பிய வரன்கள் (1) • ஒரு வரன் ₹25"), findsOneWidget);

    // 4. User unlikes Soundarya R.
    mockData.toggleShortlist("PM-1001");
    await tester.pumpAndSettle();

    // 5. Back to clean empty state
    expect(find.text("விருப்பப்பட்ட வரன்கள் இல்லை"), findsOneWidget);
    expect(find.text("Soundarya R."), findsNothing);
  });

  testWidgets('SplashScreen displays founder portrait and branding wording alone without couple artwork', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(isWelcomeMode: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Founder name & App branding
    expect(find.text(AppConstants.founderName), findsOneWidget); // சென்னிமலை ஆறுமுகம்
    expect(find.text(AppConstants.appNameTamil), findsOneWidget); // பண்டாரத்தார் மண மாலை
    expect(find.text(AppConstants.appNameEnglish), findsOneWidget); // PANDARATHAR MANA MAALAI

    // Founder image is present
    final founderImageFinder = find.byWidgetPredicate(
      (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/founder_arumugam.jpg',
    );
    expect(founderImageFinder, findsOneWidget);

    // Couple artwork card is removed completely
    final coupleImageFinder = find.byWidgetPredicate(
      (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/garland_couple.jpg',
    );
    expect(coupleImageFinder, findsNothing);
  });
}




