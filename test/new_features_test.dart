import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrimony_app/models/profile_model.dart';
import 'package:matrimony_app/models/horoscope_chart_model.dart';
import 'package:matrimony_app/services/mock_data_service.dart';
import 'package:matrimony_app/services/cloudflare_r2_service.dart';
import 'package:matrimony_app/services/mongodb_service.dart';
import 'package:matrimony_app/services/auth_service.dart';

void main() {
  setUpAll(() {
    CloudflareR2Service.isTestMode = true;
  });

  group('Smart Horoscope & Caste Matcher Tests', () {
    late MockDataService mockData;

    setUp(() {
      mockData = MockDataService();
    });

    test('Filter by Bride and Pandarathar Caste alone', () {
      final brides = mockData.filterSmartMatches(
        lookingForGender: 'Bride',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'all',
      );

      expect(brides.isNotEmpty, isTrue);
      for (final b in brides) {
        expect(b.gender, 'Bride');
        expect(
          (b.caste ?? b.community).toLowerCase().contains('pandarathar') ||
              (b.subSect?.toLowerCase().contains('pandarathar') ?? false),
          isTrue,
        );
      }
    });

    test('Filter by Groom and Pandarathar Caste alone', () {
      final grooms = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'all',
      );

      expect(grooms.isNotEmpty, isTrue);
      for (final g in grooms) {
        expect(g.gender, 'Groom');
      }
    });

    test('Chevvai Dosham compatibility: only matches candidates with Chevvai Dosham', () {
      final chevvaiMatches = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'chevvai',
      );

      expect(chevvaiMatches.isNotEmpty, isTrue);
      for (final m in chevvaiMatches) {
        final hasChevvai = (m.chevvaiDosham?.contains('உண்டு') == true ||
            m.chevvaiDosham?.toLowerCase().contains('yes') == true ||
            m.doshamType == 'chevvai' ||
            m.doshamType == 'chevvai_rahu_ketu');
        expect(hasChevvai, isTrue);
      }
    });

    test('Shudha Jathagam compatibility: only matches candidates without any Dosham', () {
      final shudhaMatches = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'none',
      );

      expect(shudhaMatches.isNotEmpty, isTrue);
      for (final m in shudhaMatches) {
        final hasDosham = (m.chevvaiDosham?.contains('உண்டு') == true ||
            m.chevvaiDosham?.toLowerCase().contains('yes') == true ||
            m.doshamType == 'chevvai' ||
            m.doshamType == 'rahu_ketu' ||
            m.doshamType == 'chevvai_rahu_ketu' ||
            m.doshamType == 'kalathra');
        expect(hasDosham, isFalse);
      }
    });

    test('Rahu-Ketu Dosham compatibility: only matches candidates with Rahu-Ketu Dosham', () {
      final rahuKetuMatches = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'rahu_ketu',
      );

      expect(rahuKetuMatches.isNotEmpty, isTrue);
      for (final m in rahuKetuMatches) {
        final hasRahuKetu = (m.doshamType == 'rahu_ketu' || m.doshamType == 'chevvai_rahu_ketu');
        expect(hasRahuKetu, isTrue);
      }
    });

    test('Chevvai + Rahu-Ketu Double Dosham compatibility: matches Double Dosham candidates', () {
      final doubleMatches = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'chevvai_rahu_ketu',
      );

      expect(doubleMatches.isNotEmpty, isTrue);
      for (final m in doubleMatches) {
        expect(m.doshamType, 'chevvai_rahu_ketu');
      }
    });

    test('Kalathira Dosham compatibility: matches Kalathira Dosham candidates', () {
      final kalathraMatches = mockData.filterSmartMatches(
        lookingForGender: 'Groom',
        caste: 'Pandarathar (பண்டாரத்தார்)',
        myDosham: 'kalathra',
      );

      expect(kalathraMatches.isNotEmpty, isTrue);
      for (final m in kalathraMatches) {
        expect(m.doshamType, 'kalathra');
      }
    });

    test('Fixed Age filter with exactAgeMatch = true: only matches candidates with exact fixed age', () {
      final matches = mockData.filterSmartMatches(
        lookingForGender: 'Bride',
        fixedAge: 25,
        exactAgeMatch: true,
      );

      expect(matches.isNotEmpty, isTrue);
      for (final m in matches) {
        expect(m.age, 25);
      }
    });

    test('Fixed Age filter with exactAgeMatch = false: matches within ±1 year of fixed age', () {
      final matches = mockData.filterSmartMatches(
        lookingForGender: 'Bride',
        fixedAge: 25,
        exactAgeMatch: false,
      );

      expect(matches.isNotEmpty, isTrue);
      for (final m in matches) {
        expect((m.age - 25).abs() <= 1, isTrue);
      }
    });
  });

  group('Contact Cart & ₹25 QR Payment Workflow Tests', () {
    late MockDataService mockData;

    setUp(() {
      mockData = MockDataService(fresh: true);
    });

    test('Cart count and total amount calculation (₹25 per profile)', () {
      expect(mockData.cartCount, 0);
      expect(mockData.cartTotalAmount, 0.0);

      // Add 1 profile
      mockData.addToCart("PM-1001");
      expect(mockData.cartCount, 1);
      expect(mockData.cartTotalAmount, 25.0);
      expect(mockData.isInCart("PM-1001"), isTrue);

      // Add second profile
      mockData.addToCart("PM-1002");
      expect(mockData.cartCount, 2);
      expect(mockData.cartTotalAmount, 50.0);

      // Add third profile
      mockData.addToCart("PM-1004");
      expect(mockData.cartCount, 3);
      expect(mockData.cartTotalAmount, 75.0);

      // Toggle off
      mockData.toggleCart("PM-1002");
      expect(mockData.cartCount, 2);
      expect(mockData.cartTotalAmount, 50.0);

      // Clear cart
      mockData.clearCart();
      expect(mockData.cartCount, 0);
      expect(mockData.cartTotalAmount, 0.0);
    });

    test('Submit payment request creates pending request with UTR', () {
      mockData.addToCart("PM-1001");
      mockData.addToCart("PM-1005");

      expect(mockData.pendingPaymentRequests.length, 0);

      // Submit with 12-digit UTR
      const testUtr = "426891045231";
      mockData.submitPaymentRequest(utrNumber: testUtr);

      expect(mockData.cartCount, 0); // Cart is cleared after submission
      expect(mockData.pendingPaymentRequests.length, 1);

      final req = mockData.pendingPaymentRequests.first;
      expect(req.totalAmount, 50.0);
      expect(req.utrNumber, testUtr);
      expect(req.profileIds, containsAll(["PM-1001", "PM-1005"]));
      expect(req.status, 'pending');
    });

    test('Admin approval unlocks contacts and updates notifications', () {
      mockData.addToCart("PM-1001");
      mockData.submitPaymentRequest(utrNumber: "998877665544");

      final req = mockData.pendingPaymentRequests.first;
      final profileBefore = mockData.getProfileById("PM-1001");
      expect(profileBefore?.isContactUnlocked, isFalse);

      // Admin approves
      mockData.approvePaymentRequest(req.id);

      expect(mockData.pendingPaymentRequests.length, 0);
      final profileAfter = mockData.getProfileById("PM-1001");
      expect(profileAfter?.isContactUnlocked, isTrue);

      // User notification created
      final latestNotif = mockData.notifications.first;
      expect(latestNotif.title, contains("திறக்கப்பட்டது"));
    });

    test('Record direct payment persists to MongoDB and updates payment list', () {
      final initialCount = mockData.paymentRequests.length;
      mockData.recordDirectPayment(
        utrNumber: "778899001122",
        amount: 25.0,
        profileIds: ["PM-1003"],
        profileNames: ["Sneha P. (PM-1003)"],
      );

      expect(mockData.paymentRequests.length, initialCount + 1);
      final newPay = mockData.paymentRequests.first;
      expect(newPay.utrNumber, "778899001122");
      expect(newPay.totalAmount, 25.0);
      expect(newPay.profileIds, contains("PM-1003"));
      expect(newPay.status, "pending");
    });

    test('Unlocked profiles getter includes profiles with approved payments', () {
      final unlocked = mockData.unlockedProfiles;
      expect(unlocked.isNotEmpty, isTrue);
      expect(unlocked.any((p) => p.id == "PM-1001"), isTrue);
    });
  });

  group('Admin Profile Management Tests', () {
    late MockDataService mockData;

    setUp(() {
      mockData = MockDataService();
    });

    test('Admin can add new profile with Cloudflare R2 certificate URL', () {
      final initialCount = mockData.allProfiles.length;
      final newCandidate = ProfileModel(
        id: "PM-9999",
        name: "Test Candidate",
        gender: "Bride",
        age: 25,
        height: "5' 4\"",
        maritalStatus: "Never Married",
        motherTongue: "Tamil",
        religion: "Hindu",
        community: "Pandarathar (பண்டாரத்தார்)",
        caste: "Pandarathar (பண்டாரத்தார்)",
        education: "B.Tech",
        occupation: "Engineer",
        company: "Tech Corp",
        annualIncome: "₹10,00,000 PA",
        location: "Coimbatore",
        about: "Traditional girl",
        fatherName: "Father",
        motherName: "Mother",
        siblings: "None",
        familyLocation: "Coimbatore",
        familyDetails: "Pandarathar family",
        preferredAge: "26 - 30 Yrs",
        preferredLocation: "Coimbatore",
        preferredEducation: "Graduate",
        preferredOccupation: "IT",
        r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-9999.pdf",
        doshamType: "chevvai",
        phone: "+91 98765 43210",
        whatsapp: "+91 98765 43210",
        email: "test@pandarathar.com",
        avatarSeed: "TestCandidate",
      );

      mockData.addProfile(newCandidate);
      expect(mockData.allProfiles.length, initialCount + 1);

      final fetched = mockData.getProfileById("PM-9999");
      expect(fetched, isNotNull);
      expect(fetched?.r2CertificateUrl, "https://pub-r2.pandarathar-matrimony.com/certificates/PM-9999.pdf");
      expect(fetched?.doshamType, "chevvai");

      // Admin deletes profile
      mockData.deleteProfile("PM-9999");
      expect(mockData.allProfiles.length, initialCount);
    });

    test('Cloudflare R2 service uploads profile image to matrimony-profile-images bucket profiles/ folder', () async {
      final r2 = CloudflareR2Service();
      final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]); // Sample image bytes
      final url = await r2.uploadProfileImage(
        imageBytes: bytes,
        fileName: 'karthik_profile.png',
      );
      expect(url, contains('matrimony-profile-images'));
      expect(url, contains('profiles/'));
    });

    test('Admin can store and update custom Rasi and Navamsam horoscope chart tables', () {
      final customRasi = {
        'mesham': 'லக்னம், புதன்',
        'rishabam': 'சந்திரன்',
        'mithunam': 'சூரியன்',
        'kadagam': 'குரு',
        'simmam': '-',
        'kanni': '-',
        'thulam': 'சுக்கிரன்',
        'viruchigam': '-',
        'dhanusu': 'கேது',
        'makaram': 'சனி',
        'kumbam': '-',
        'meenam': 'செவ்வாய்',
      };

      final customNav = {
        'mesham': 'செவ்வாய்',
        'rishabam': 'குரு',
        'mithunam': 'லக்னம்',
        'kadagam': '-',
        'simmam': 'சந்திரன்',
        'kanni': 'கேது',
        'thulam': '-',
        'viruchigam': 'ராகு',
        'dhanusu': 'சுக்கிரன்',
        'makaram': 'சனி',
        'kumbam': 'சூரியன்',
        'meenam': 'புதன்',
      };

      final candidate = ProfileModel(
        id: "PM-8888",
        name: "Chart Candidate",
        gender: "Groom",
        age: 28,
        height: "5' 9\"",
        maritalStatus: "Never Married",
        motherTongue: "Tamil",
        religion: "Hindu",
        community: "Pandarathar (பண்டாரத்தார்)",
        education: "M.Tech",
        occupation: "Lead Engineer",
        company: "Global Tech",
        annualIncome: "₹18,00,000 PA",
        location: "Chennai",
        about: "Family oriented",
        fatherName: "Father",
        motherName: "Mother",
        siblings: "1 Brother",
        familyLocation: "Chennai",
        familyDetails: "Traditional",
        preferredAge: "23 - 26 Yrs",
        preferredLocation: "Tamil Nadu",
        preferredEducation: "Any Degree",
        preferredOccupation: "Working",
        phone: "+91 94444 11223",
        whatsapp: "+91 94444 11223",
        email: "chart@pandarathar.com",
        avatarSeed: "ChartGroom",
        rasiChart: customRasi,
        navamsamChart: customNav,
      );

      mockData.addProfile(candidate);
      final saved = mockData.getProfileById("PM-8888");
      expect(saved?.rasiChart?['mesham'], 'லக்னம், புதன்');
      expect(saved?.navamsamChart?['meenam'], 'புதன்');

      // Verify grid matrix generator
      final rasiMatrix = HoroscopeChartModel.buildGridMatrix(saved!.getEffectiveRasiChart());
      expect(rasiMatrix.length, 4);
      expect(rasiMatrix[0][1], contains("மேஷம்\nலக்னம், புதன்"));

      // Admin updates chart
      final updatedRasi = Map<String, String>.from(customRasi);
      updatedRasi['mesham'] = 'லக்னம், புதன், குரு';
      final updatedProfile = saved.copyWith(rasiChart: updatedRasi);
      mockData.updateProfile(updatedProfile);

      final reFetched = mockData.getProfileById("PM-8888");
      expect(reFetched?.rasiChart?['mesham'], 'லக்னம், புதன், குரு');
    });
  });

  group('Accurate Search Filtering Tests', () {
    late MockDataService mockData;

    setUp(() {
      mockData = MockDataService();
    });

    test('Search by Profile ID alone returns only that specific profile', () {
      final results = mockData.filterSmartMatches(searchQuery: 'PM-1002');
      expect(results.length, 1);
      expect(results.first.id, 'PM-1002');
      expect(results.first.name, 'Kavitha M.');
    });

    test('Search by Name alone returns only the exact candidate', () {
      final results = mockData.filterSmartMatches(searchQuery: 'Soundarya');
      expect(results.length, 1);
      expect(results.first.name, 'Soundarya R.');
      expect(results.first.id, 'PM-1001');
    });

    test('Search by Tamil Name alone returns only the matching candidate', () {
      final results = mockData.filterSmartMatches(searchQuery: 'சௌந்தர்யா');
      expect(results.length, 1);
      expect(results.first.nameTamil, 'சௌந்தர்யா R.');
    });

    test('Search with non-matching query returns empty list and does NOT dump all profiles', () {
      final results = mockData.filterSmartMatches(searchQuery: 'NonExistentPersonName12345');
      expect(results.isEmpty, isTrue);
    });

    test('Search by Education returns only matching candidates', () {
      final doctors = mockData.filterSmartMatches(education: 'Doctor / MBBS / MD');
      expect(doctors.isNotEmpty, isTrue);
      for (final doc in doctors) {
        expect(
          doc.education.toLowerCase().contains('mbbs') ||
              doc.education.toLowerCase().contains('doctor') ||
              doc.education.toLowerCase().contains('md') ||
              doc.occupation.toLowerCase().contains('doctor'),
          isTrue,
        );
      }
    });

    test('Search by Location returns only candidates in that location', () {
      final maduraiMatches = mockData.filterSmartMatches(location: 'Madurai (மதுரை)');
      expect(maduraiMatches.isNotEmpty, isTrue);
      for (final m in maduraiMatches) {
        expect(m.location.toLowerCase(), contains('madurai'));
      }
    });

    test('Search by Caste returns only matching Pandarathar community', () {
      final casteMatches = mockData.filterSmartMatches(caste: 'Pandarathar (பண்டாரத்தார்)');
      expect(casteMatches.isNotEmpty, isTrue);
      for (final p in casteMatches) {
        final c = (p.caste ?? p.community).toLowerCase();
        final s = (p.subSect ?? '').toLowerCase();
        expect(
          c.contains('pandarathar') ||
              c.contains('பண்டாரத்தார்') ||
              s.contains('pandarathar') ||
              s.contains('பண்டாரத்தார்'),
          isTrue,
        );
      }
    });

    test('MongoDB Atlas service connects to live portfolio cluster and initializes health checks', () async {
      final mongoService = MongoDBService();
      expect(MongoDBService.atlasUri, contains('portfolio.mo5wnyq.mongodb.net'));
      expect(MongoDBService.atlasUri, contains('vishal250820_db_user'));

      final health = await mongoService.checkConnectionHealth();
      expect(health.containsKey('cluster'), isTrue);
      expect(health['cluster'], 'portfolio.mo5wnyq.mongodb.net');
    });

    test('User Likes / Shortlist flow: only liked profiles appear, otherwise nothing is shown', () {
      final freshMock = MockDataService(fresh: true);
      // 1. Initially no profiles are liked / shortlisted
      expect(freshMock.shortlistedProfiles.isEmpty, isTrue);

      // 2. User likes one specific profile (Soundarya R. PM-1001)
      freshMock.toggleShortlist('PM-1001');
      expect(freshMock.shortlistedProfiles.length, equals(1));
      expect(freshMock.shortlistedProfiles.first.id, equals('PM-1001'));
      expect(freshMock.shortlistedProfiles.first.name, equals('Soundarya R.'));

      // 3. User unlikes the profile
      freshMock.toggleShortlist('PM-1001');
      expect(freshMock.shortlistedProfiles.isEmpty, isTrue);
    });

    test('Multi-select Horoscope doshams matches profiles matching ANY selected dosham', () {
      final multiDoshamMatches = mockData.filterSmartMatches(
        doshams: ['chevvai', 'rahu_ketu'],
      );
      expect(multiDoshamMatches.isNotEmpty, isTrue);
      for (final p in multiDoshamMatches) {
        final matches = (p.doshamType == 'chevvai' ||
            p.doshamType == 'rahu_ketu' ||
            p.doshamType == 'chevvai_rahu_ketu' ||
            p.chevvaiDosham?.toLowerCase().contains('yes') == true);
        expect(matches, isTrue);
      }
    });

    test('Multi-select Rasi and Star filters return candidates matching chosen rasis/stars', () {
      final multiRasiMatches = mockData.filterSmartMatches(
        rasis: ['மேஷம் (Mesham)', 'துலாம் (Thulam)'],
      );
      expect(multiRasiMatches.isNotEmpty, isTrue);
      for (final p in multiRasiMatches) {
        expect(
          p.rasi?.toLowerCase().contains('mesham') == true ||
              p.rasi?.toLowerCase().contains('மேஷம்') == true ||
              p.rasi?.toLowerCase().contains('thulam') == true ||
              p.rasi?.toLowerCase().contains('துலாம்') == true,
          isTrue,
        );
      }
    });

    test('Brand new user account has 0 unlocked contacts, 0 shortlisted, and 0 matches until horoscope is registered', () {
      final freshService = MockDataService();
      final newRegisteredUser = UserAccount(
        name: "Muthu Kumaran",
        username: "9842100001",
        phone: "9842100001",
        email: "muthu@pandarathar.com",
        password: "secretpassword",
        gender: "Searching for Bride",
      );

      freshService.syncWithAuth(newRegisteredUser);

      // Verify gender correctly resolved to Groom (since seeking Bride)
      expect(freshService.currentUser.gender, 'Groom');
      expect(freshService.currentUser.name, 'Muthu Kumaran');

      // Unlocked contacts must be 0 for a brand new user (no cross-account duplicate data)
      expect(freshService.unlockedProfiles.length, 0);

      // Shortlisted profiles must be 0
      expect(freshService.shortlistedProfiles.length, 0);

      // Matches must be 0 until fresh user fills in horoscope details
      expect(freshService.getRealMatchingCount(freshService.currentUser), 0);

      // Once the user updates their horoscope star/rasi, real matches calculate dynamically
      final userWithHoroscope = freshService.currentUser.copyWith(
        star: "உத்திரம் (Uthiradam)",
        rasi: "சிம்மம் (Simmam)",
        doshamType: "none",
      );
      freshService.updateUserProfile(userWithHoroscope);

      expect(freshService.getRealMatchingCount(freshService.currentUser), greaterThan(0));
    });

    test('User registration stores credentials and password in MongoDB database and cache', () async {
      final auth = AuthService();
      final regResult = await auth.register(
        name: "Ananya Pandarathar",
        usernameOrPhone: "9842155667",
        phone: "9842155667",
        password: "ananyaPass123",
        email: "ananya@pandarathar.com",
        gender: "Searching for Groom",
      );

      expect(regResult.success, isTrue);

      // Verify credentials and password are stored in MongoDB database cache
      final dbAccount = await MongoDBService().getUserAccount("9842155667");
      expect(dbAccount, isNotNull);
      expect(dbAccount!['phone'], "9842155667");
      expect(dbAccount['password'], "ananyaPass123");
      expect(dbAccount['email'], "ananya@pandarathar.com");
      expect(dbAccount['name'], "Ananya Pandarathar");
    });

    test('Subsequent login checks and authenticates against MongoDB credentials', () async {
      final auth = AuthService();

      // 1. Wrong password must be rejected
      final failResult = await auth.login("9842155667", "wrongPassword");
      expect(failResult.success, isFalse);
      expect(failResult.message, contains("கடவுச்சொல்"));

      // 2. Correct password must authenticate successfully
      final successResult = await auth.login("9842155667", "ananyaPass123");
      expect(successResult.success, isTrue);
      expect(successResult.user, isNotNull);
      expect(successResult.user!.name, "Ananya Pandarathar");
      expect(successResult.user!.phone, "9842155667");
    });

    test('Particular user details alone show perfectly and persist across sessions without leaking', () async {
      final auth = AuthService();
      final service = MockDataService();

      // Login as Ananya
      final loginResult = await auth.login("9842155667", "ananyaPass123");
      expect(loginResult.success, isTrue);

      await service.syncWithAuthAsync(loginResult.user);

      // Verify Ananya's details
      expect(service.currentUser.name, "Ananya Pandarathar");
      expect(service.currentUser.gender, "Bride"); // Resolved from Searching for Groom
      expect(service.currentUser.phone, "9842155667");

      // Ananya customizes her profile with specific family, education and astrological details
      final ananyaCustomProfile = service.currentUser.copyWith(
        education: "M.B.B.S., M.D.",
        occupation: "Consultant Physician",
        fatherName: "Dr. Ramanathan",
        motherName: "Smt. Meenakshi",
        star: "ரோகிணி (Rohini)",
        rasi: "ரிஷபம் (Rishabham)",
        gothram: "சிவகோத்திரம் (Siva Gothram)",
        location: "Madurai, Tamil Nadu",
      );
      service.updateUserProfile(ananyaCustomProfile);

      // Verify details saved in MongoDB database
      final savedInDb = await MongoDBService().getProfileByIdOrPhone("9842155667");
      expect(savedInDb, isNotNull);
      expect(savedInDb!['education'], "M.B.B.S., M.D.");
      expect(savedInDb['fatherName'], "Dr. Ramanathan");
      expect(savedInDb['star'], "ரோகிணி (Rohini)");

      // Now user logs out and Karthik logs in
      auth.logout();
      service.syncWithAuth(null);

      final karthikLogin = await auth.login("9876543210", "password123");
      expect(karthikLogin.success, isTrue);
      await service.syncWithAuthAsync(karthikLogin.user);

      // Karthik's profile shows HIS details alone perfectly (not Ananya's doctor/father details)
      expect(service.currentUser.name, "Karthik Sundaram");
      expect(service.currentUser.gender, "Groom");
      expect(service.currentUser.education, isNot("M.B.B.S., M.D."));
      expect(service.currentUser.fatherName, isNot("Dr. Ramanathan"));

      // Later, Ananya logs in another time on the app
      auth.logout();
      service.syncWithAuth(null);

      final ananyaReLogin = await auth.login("9842155667", "ananyaPass123");
      expect(ananyaReLogin.success, isTrue);
      await service.syncWithAuthAsync(ananyaReLogin.user);

      // Ananya's exact details are retrieved from database and show perfectly
      expect(service.currentUser.name, "Ananya Pandarathar");
      expect(service.currentUser.gender, "Bride");
      expect(service.currentUser.education, "M.B.B.S., M.D.");
      expect(service.currentUser.fatherName, "Dr. Ramanathan");
      expect(service.currentUser.motherName, "Smt. Meenakshi");
      expect(service.currentUser.star, "ரோகிணி (Rohini)");
      expect(service.currentUser.rasi, "ரிஷபம் (Rishabham)");
      expect(service.currentUser.location, "Madurai, Tamil Nadu");
    });

    test('Mobile number and email validation rules enforce exact 10 digits starting with 6-9', () async {
      final auth = AuthService();

      // 1. Invalid length (<10 digits)
      final tooShort = await auth.register(
        name: "Test User",
        usernameOrPhone: "638118048",
        phone: "638118048",
        email: "test@pandarathar.com",
        password: "password123",
        gender: "Groom",
      );
      expect(tooShort.success, isFalse);
      expect(tooShort.message, contains("10-இலக்க கைபேசி"));

      // 2. Starts with invalid leading digit (e.g. 1)
      final invalidStart = await auth.register(
        name: "Test User",
        usernameOrPhone: "1234567890",
        phone: "1234567890",
        email: "test@pandarathar.com",
        password: "password123",
        gender: "Groom",
      );
      expect(invalidStart.success, isFalse);
      expect(invalidStart.message, contains("6, 7, 8 அல்லது 9"));

      // 3. Invalid email format
      final invalidEmail = await auth.register(
        name: "Test User",
        usernameOrPhone: "6381180499",
        phone: "6381180499",
        email: "not-an-email",
        password: "password123",
        gender: "Groom",
      );
      expect(invalidEmail.success, isFalse);
      expect(invalidEmail.message, contains("மின்னஞ்சல்"));

      // 4. Valid mobile number (10 digits starting with 6) & valid email succeeds
      final validUser = await auth.register(
        name: "Valid User",
        usernameOrPhone: "6381180499",
        phone: "6381180499",
        email: "valid@pandarathar.com",
        password: "password123",
        gender: "Groom",
      );
      expect(validUser.success, isTrue);

      // 5. Login normalization with 10-digit number or +91 works
      final login10 = await auth.login("6381180499", "password123");
      expect(login10.success, isTrue);
    });

    test('Soundarya R. and catalog candidates preserve photo asset on serialization and Atlas sync', () async {
      // 1. Check Soundarya R. profile has default catalog imageAsset
      final soundarya = ProfileModel.fromMap({
        'id': 'PM-1001',
        'name': 'Soundarya R.',
        'gender': 'Bride',
      });
      expect(soundarya.displayImageAsset, 'assets/images/bride_soundarya.jpg');

      // 2. toMap serializes imageAsset
      final map = soundarya.toMap();
      expect(map['imageAsset'], 'assets/images/bride_soundarya.jpg');

      // 3. fromMap deserializes imageAsset even if map imageAsset was missing from Atlas document
      final fromAtlasWithoutAsset = ProfileModel.fromMap({
        'id': 'PM-1001',
        'name': 'Soundarya R.',
        'gender': 'Bride',
      });
      expect(fromAtlasWithoutAsset.imageAsset, 'assets/images/bride_soundarya.jpg');
      expect(fromAtlasWithoutAsset.displayImageAsset, 'assets/images/bride_soundarya.jpg');

      // 4. Other catalog profiles also resolve correctly
      final kavitha = ProfileModel.fromMap({'id': 'PM-1002', 'name': 'Kavitha M.'});
      expect(kavitha.displayImageAsset, 'assets/images/doctor_kavitha.jpg');

      final sneha = ProfileModel.fromMap({'id': 'PM-1003', 'name': 'Sneha P.'});
      expect(sneha.displayImageAsset, 'assets/images/bride_sneha.jpg');

      final karthik = ProfileModel.fromMap({'id': 'PM-1006', 'name': 'Vignesh S.'});
      expect(karthik.displayImageAsset, 'assets/images/user_karthik.jpg');
    });
  });
}


