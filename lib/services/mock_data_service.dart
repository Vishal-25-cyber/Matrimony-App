import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../models/notification_model.dart';
import '../models/success_story_model.dart';
import '../models/payment_request_model.dart';
import '../core/constants/app_constants.dart';
import 'auth_service.dart';
import 'mongodb_service.dart';
import 'cloudflare_r2_service.dart';

class MockDataService extends ChangeNotifier {
  static MockDataService? _instance;
  factory MockDataService({bool fresh = false}) {
    if (fresh) {
      return MockDataService._internal();
    }
    return _instance ??= MockDataService._internal();
  }
  static void resetForTesting() {
    _instance = null;
    MongoDBService().clearDatabaseCache();
    CloudflareR2Service.isTestMode = true;
    AuthService().logout();
  }
  MockDataService._internal() {
    AuthService().addListener(_syncFromAuth);
    _syncFromAuth();
    for (final p in _paymentRequests) {
      MongoDBService().savePaymentRequest(p.toMap());
    }
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      _loadProfilesFromAtlasAsync();
    }
  }

  /// Generates the next sequential 4-digit Profile ID (PM-1001, PM-1002, ...)
  String generateNextProfileId() {
    int maxNumber = 1000;
    for (final p in _profiles) {
      final match = RegExp(r'^PM-?(\d+)$').firstMatch(p.id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num > maxNumber && num < 9000) {
          maxNumber = num;
        }
      }
    }
    return 'PM-${maxNumber + 1}';
  }

  void _syncFromAuth() {
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      syncWithAuth(authUser);
    }
  }

  void syncWithAuth(UserAccount? authUser) {
    if (authUser == null) {
      // Reset to default guest/unauthenticated state
      currentUser = ProfileModel(
        id: "PM-1000",
        name: "Karthik",
        nameTamil: "கார்த்திக்",
        gender: "Groom",
        age: 28,
        height: "5'10\" (178 cm)",
        maritalStatus: "Never Married",
        motherTongue: "Tamil",
        motherTongueTamil: "தமிழ்",
        religion: "Hindu",
        community: AppConstants.communityName,
        subSect: "பண்டாரத்தார் (Pandarathar)",
        star: "உத்திரம் (Uthiradam)",
        rasi: "சிம்மம் (Simmam)",
        gothram: "சிவகோத்திரம் (Siva Gothram)",
        education: "B.E. Computer Science",
        degree: "B.E. CSE",
        occupation: "Senior Software Engineer",
        company: "TCS Global",
        annualIncome: "₹14,00,000 PA",
        location: "Coimbatore, Tamil Nadu",
        about: "I am a simple, family-oriented professional from Pandarathar community.",
        fatherName: "K. Sundaram",
        motherName: "S. Lakshmi",
        siblings: "1 Younger Sister",
        familyLocation: "Coimbatore",
        familyDetails: "Upper Middle Class, Nuclear Family.",
        preferredAge: "22 - 27 Yrs",
        preferredLocation: "Coimbatore, Chennai",
        preferredEducation: "Degree",
        preferredOccupation: "Professional",
        phone: "+91 98765 43210",
        whatsapp: "+91 98765 43210",
        email: "karthik.pm@pandarathar.com",
        avatarSeed: "Karthik",
      );
      for (var p in _profiles) {
        p.isShortlisted = false;
      }
      notifyListeners();
      return;
    }

    final cleanPhone = authUser.phone.replaceAll(RegExp(r'\D'), '');
    final userId = "PM-${cleanPhone.length >= 4 ? cleanPhone.substring(cleanPhone.length - 4) : '1000'}";

    // 1. Check if this exact user already has a saved profile in MongoDB cache / DB
    final cache = MongoDBService().databaseCache;
    final cachedUser = cleanPhone.isNotEmpty
        ? (cache['user_phone_$cleanPhone'] ?? cache['user_phone_${authUser.phone}'])
        : null;

    final cachedProfile = cleanPhone.isNotEmpty
        ? (cache['profile_phone_$cleanPhone'] ??
           cache['profile_phone_${authUser.phone}'] ??
           cache['profile_id_$userId'])
        : cache['profile_id_$userId'];

    final rawDbImg = cachedUser?['profileImageUrl']?.toString() ??
        cachedUser?['r2ProfileImageUrl']?.toString() ??
        cachedProfile?['profileImageUrl']?.toString() ??
        cachedProfile?['r2ProfileImageUrl']?.toString();

    final effectiveImageBytes = authUser.imageBytes ?? currentUser.imageBytes;
    final effectiveImageUrl = (authUser.profileImageUrl != null && authUser.profileImageUrl!.isNotEmpty)
        ? authUser.profileImageUrl
        : ((rawDbImg != null && rawDbImg.isNotEmpty)
            ? CloudflareR2Service().ensureDisplayableUrl(rawDbImg)
            : (currentUser.profileImageUrl != null && currentUser.profileImageUrl!.isNotEmpty
                ? currentUser.profileImageUrl
                : null));

    final gLower = authUser.gender.toLowerCase().trim();
    final bool isUserBride = gLower.contains('searching for groom') ||
        (!gLower.contains('searching for bride') && (gLower == 'bride' || gLower.contains('female')));
    final String resolvedGender = isUserBride ? "Bride" : "Groom";

    if (cachedProfile != null) {
      final loaded = ProfileModel.fromMap(cachedProfile);
      final finalImg = effectiveImageUrl ?? (loaded.profileImageUrl != null && loaded.profileImageUrl!.isNotEmpty
          ? CloudflareR2Service().ensureDisplayableUrl(loaded.profileImageUrl)
          : null);
      currentUser = loaded.copyWith(
        id: loaded.id.isNotEmpty ? loaded.id : userId,
        name: authUser.name.isNotEmpty ? authUser.name : loaded.name,
        nameTamil: authUser.name.isNotEmpty ? authUser.name : loaded.nameTamil,
        phone: authUser.phone.isNotEmpty ? authUser.phone : loaded.phone,
        whatsapp: authUser.phone.isNotEmpty ? authUser.phone : loaded.whatsapp,
        email: authUser.email.isNotEmpty ? authUser.email : loaded.email,
        gender: resolvedGender,
        imageBytes: effectiveImageBytes ?? loaded.imageBytes,
        profileImageUrl: finalImg,
      );
    } else {
      // 2. Check if the user's phone strictly matches a pre-existing profile in the catalog
      ProfileModel? catalogMatch;
      if (cleanPhone.isNotEmpty) {
        for (int i = 0; i < _profiles.length; i++) {
          final p = _profiles[i];
          if (p.phone.isNotEmpty && p.phone.replaceAll(RegExp(r'\D'), '') == cleanPhone) {
            catalogMatch = p;
            break;
          }
        }
      }

      if (catalogMatch != null) {
        final updatedP = catalogMatch.copyWith(
          name: authUser.name,
          nameTamil: authUser.name,
          phone: authUser.phone,
          whatsapp: authUser.phone,
          email: authUser.email,
          gender: resolvedGender,
          imageBytes: effectiveImageBytes ?? catalogMatch.imageBytes,
          profileImageUrl: effectiveImageUrl ?? catalogMatch.profileImageUrl,
        );
        currentUser = updatedP;
      } else {
        // 3. Dedicated clean profile for this specific user
        currentUser = ProfileModel(
          id: userId,
          name: authUser.name,
          nameTamil: authUser.name,
          gender: resolvedGender,
          age: 26,
          height: isUserBride ? "5'3\"" : "5'9\"",
          maritalStatus: "Never Married",
          motherTongue: "Tamil",
          motherTongueTamil: "தமிழ்",
          religion: "Hindu",
          community: AppConstants.communityName,
          subSect: "பண்டாரத்தார் (Pandarathar)",
          caste: "Pandarathar (பண்டாரத்தார்)",
          education: "",
          occupation: "",
          company: "",
          annualIncome: "",
          location: "",
          about: "Looking for an understanding partner from Pandarathar community.",
          fatherName: "",
          motherName: "",
          siblings: "",
          familyLocation: "",
          familyDetails: "",
          preferredAge: isUserBride ? "27 - 31 Yrs" : "22 - 26 Yrs",
          preferredLocation: "Tamil Nadu",
          preferredEducation: "Degree",
          preferredOccupation: "Professional",
          phone: authUser.phone,
          whatsapp: authUser.phone,
          email: authUser.email.isNotEmpty ? authUser.email : "${authUser.phone}@pandarathar.com",
          isOnline: true,
          isVerified: true,
          imageAsset: null,
          imageBytes: effectiveImageBytes,
          profileImageUrl: effectiveImageUrl,
          avatarSeed: authUser.name.isNotEmpty ? authUser.name : 'User',
        );

        // Store this initial profile in MongoDB database cache immediately
        MongoDBService().updateUserProfile(currentUser.toMap());
      }
    }

    // 4. Load shortlist / likes strictly for THIS user alone
    final cachedShortlist = MongoDBService().databaseCache['shortlist_${currentUser.id}'] ??
        (cleanPhone.isNotEmpty ? MongoDBService().databaseCache['shortlist_$cleanPhone'] : null);
    if (cachedShortlist != null && cachedShortlist['profileIds'] is List) {
      final ids = Set<String>.from((cachedShortlist['profileIds'] as List).map((e) => e.toString()));
      for (var p in _profiles) {
        p.isShortlisted = ids.contains(p.id);
      }
    } else {
      // Check if user is the same user or if we should preserve current session shortlist
      final isSameUser = cleanPhone.isNotEmpty && currentUser.phone.replaceAll(RegExp(r'\D'), '') == cleanPhone;
      if (isSameUser) {
        final currentLiked = _profiles.where((p) => p.isShortlisted).map((p) => p.id).toList();
        if (currentLiked.isNotEmpty) {
          MongoDBService().saveShortlist(
            userId: currentUser.id,
            userPhone: currentUser.phone,
            profileIds: currentLiked,
          );
        }
      } else {
        // Different user account without a cached shortlist
        for (var p in _profiles) {
          p.isShortlisted = false;
        }
      }
    }

    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      _loadShortlistAndPaymentsFromAtlasAsync(currentUser.id, cleanPhone);
    }

    notifyListeners();
  }

  /// Asynchronously fetch saved shortlist and payment requests from MongoDB Atlas
  Future<void> _loadShortlistAndPaymentsFromAtlasAsync(String userId, String cleanPhone) async {
    try {
      // 1. Fetch shortlist from Atlas
      final doc = await MongoDBService().getShortlist(userId, userPhone: cleanPhone);
      if (doc != null && doc['profileIds'] is List) {
        final ids = Set<String>.from((doc['profileIds'] as List).map((e) => e.toString()));
        bool changed = false;
        for (var p in _profiles) {
          final shouldBeLiked = ids.contains(p.id);
          if (p.isShortlisted != shouldBeLiked) {
            p.isShortlisted = shouldBeLiked;
            changed = true;
          }
        }
        if (changed) {
          notifyListeners();
        }
      }

      // 2. Fetch payments from Atlas
      final payments = await MongoDBService().getPaymentRequests(userId: userId, userPhone: cleanPhone);
      if (payments.isNotEmpty) {
        bool paymentsChanged = false;
        for (final pMap in payments) {
          final id = pMap['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final existingIdx = _paymentRequests.indexWhere((r) => r.id == id);
          final rawProfileIds = pMap['profileIds'];
          final List<String> profileIdsList = (rawProfileIds is List)
              ? rawProfileIds.map((e) => e.toString()).toList()
              : (rawProfileIds?.toString().split(RegExp(r'\s+')) ?? []);
          final rawProfileNames = pMap['profileNames'];
          final List<String> profileNamesList = (rawProfileNames is List)
              ? rawProfileNames.map((e) => e.toString()).toList()
              : (rawProfileNames?.toString().split(',') ?? []);

          final reqModel = PaymentRequestModel(
            id: id,
            userId: pMap['userId']?.toString() ?? userId,
            userName: pMap['userName']?.toString() ?? currentUser.name,
            userPhone: pMap['userPhone']?.toString() ?? currentUser.phone,
            profileIds: profileIdsList,
            profileNames: profileNamesList,
            totalAmount: (pMap['totalAmount'] is num) ? (pMap['totalAmount'] as num).toDouble() : 50.0,
            utrNumber: pMap['utrNumber']?.toString() ?? '',
            timestamp: DateTime.tryParse(pMap['timestamp']?.toString() ?? '') ?? DateTime.now(),
            status: pMap['status']?.toString() ?? 'pending',
          );

          if (existingIdx != -1) {
            _paymentRequests[existingIdx] = reqModel;
          } else {
            _paymentRequests.insert(0, reqModel);
          }
          paymentsChanged = true;

          if (reqModel.status == 'approved') {
            for (final pid in reqModel.profileIds) {
              final pIdx = _profiles.indexWhere((p) => p.id == pid);
              if (pIdx != -1) {
                _profiles[pIdx].isContactUnlocked = true;
                _profiles[pIdx].isHoroscopeUnlocked = true;
              }
            }
          }
        }
        if (paymentsChanged) {
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  /// Asynchronously fetch saved profile details from MongoDB Atlas before syncing
  Future<void> syncWithAuthAsync(UserAccount? authUser) async {
    if (authUser == null) {
      syncWithAuth(null);
      return;
    }
    final cleanPhone = authUser.phone.replaceAll(RegExp(r'\D'), '');
    final userId = "PM-${cleanPhone.length >= 4 ? cleanPhone.substring(cleanPhone.length - 4) : '1000'}";

    // 1. Fetch user account from Atlas (contains profileImageUrl)
    final userDoc = await MongoDBService().getUserAccount(cleanPhone.isNotEmpty ? cleanPhone : authUser.username);
    // 2. Fetch profile from Atlas
    final dbDoc = await MongoDBService().getProfileByIdOrPhone(cleanPhone.isNotEmpty ? cleanPhone : userId);

    final rawImg = userDoc?['profileImageUrl']?.toString() ??
        userDoc?['r2ProfileImageUrl']?.toString() ??
        dbDoc?['profileImageUrl']?.toString() ??
        dbDoc?['r2ProfileImageUrl']?.toString();

    if (rawImg != null && rawImg.isNotEmpty) {
      final displayUrl = CloudflareR2Service().ensureDisplayableUrl(rawImg);
      authUser = authUser.copyWith(profileImageUrl: displayUrl);
      AuthService().updateCurrentUserAccount(
        name: authUser.name,
        phone: authUser.phone,
        email: authUser.email,
        gender: authUser.gender,
        profileImageUrl: displayUrl,
      );
    }

    if (dbDoc != null) {
      if (cleanPhone.isNotEmpty) {
        MongoDBService().putInCache('profile_phone_$cleanPhone', dbDoc);
      }
      MongoDBService().putInCache('profile_id_$userId', dbDoc);
    }

    syncWithAuth(authUser);

    // 3. Load shortlists and payments from Atlas
    await _loadShortlistAndPaymentsFromAtlasAsync(userId, cleanPhone);
  }

  // Current logged in user profile
  ProfileModel currentUser = ProfileModel(
    id: "PM-1000",
    name: "Karthik",
    nameTamil: "கார்த்திக்",
    gender: "Groom",
    age: 28,
    height: "5'10\" (178 cm)",
    maritalStatus: "Never Married",
    motherTongue: "Tamil",
    motherTongueTamil: "தமிழ்",
    religion: "Hindu",
    community: AppConstants.communityName,
    subSect: "பண்டாரத்தார் (Pandarathar)",
    star: "உத்திரம் (Uthiradam)",
    rasi: "சிம்மம் (Simmam)",
    gothram: "சிவகோத்திரம் (Siva Gothram)",
    education: "B.E. Computer Science",
    degree: "B.E. CSE",
    occupation: "Senior Software Engineer",
    company: "TCS Global",
    annualIncome: "₹14,00,000 PA",
    location: "Coimbatore, Tamil Nadu",
    about: "I am a simple, family-oriented professional from Pandarathar community who values traditions while embracing modern views. Looking for an understanding life partner.",
    fatherName: "K. Sundaram (Business)",
    motherName: "S. Lakshmi (Homemaker)",
    siblings: "1 Younger Sister (Married)",
    familyLocation: "Coimbatore",
    familyDetails: "Upper Middle Class, Nuclear Family with strong traditional values.",
    preferredAge: "22 - 27 Yrs",
    preferredLocation: "Coimbatore, Chennai, Thanjavur",
    preferredEducation: "Bachelor's or Master's Degree",
    preferredOccupation: "IT / Professional / Doctor / Teaching",
    isOnline: true,
    isVerified: true,
    imageAsset: null,
    phone: "+91 98765 43210",
    whatsapp: "+91 98765 43210",
    email: "karthik.pm@pandarathar.com",
    avatarSeed: "Karthik",
    avatarColorHex: "6B1E2E",
  );

  // Mock profile repository with the exact profiles from the screenshots
  final List<ProfileModel> _profiles = [
    // Featured Candidate: Soundarya R.
    ProfileModel(
      id: "PM-1001",
      name: "Soundarya R.",
      nameTamil: "சௌந்தர்யா R.",
      gender: "Bride",
      age: 25,
      height: "5' 4\" (162 cm)",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      doshamType: "none",
      star: "ரோகிணி (Rohini)",
      rasi: "ரிஷபம் (Rishabham)",
      gothram: "Siva Gothram (சிவகோத்திரம்)",
      dob: "14 May 1999",
      chevvaiDosham: "இல்லை / No",
      education: "B.Tech Information Technology, First Class Honors",
      degree: "M.Sc., B.Ed",
      occupation: "Software Engineer at Cognizant",
      company: "Cognizant / Infosys, Sr. Analyst",
      annualIncome: "₹12,00,000 PA (₹12 LPA)",
      location: "Coimbatore, Tamil Nadu",
      about: "Traditional yet modern Pandarathar girl, raised with strong cultural values and family orientation. Enjoys Carnatic music, reading, and temple visits. Passionate about software innovation while preserving traditional Tamil heritage and culinary arts.",
      fatherName: "R. Rajendran",
      motherName: "Meenakshi Rajendran",
      siblings: "1 Younger Brother (தம்பி)",
      familyLocation: "Coimbatore / Thanjavur",
      familyDetails: "Father: Govt Executive (Retired, PWD Tamil Nadu)\nMother: Homemaker (குடும்பத் தலைவி)\nBrother: BE Mechanical, working at L&T Chennai",
      preferredAge: "26 - 31 Yrs",
      preferredLocation: "Coimbatore, Thanjavur, Chennai",
      preferredEducation: "B.E / B.Tech / PG / Doctorate",
      preferredOccupation: "Software / IT / Engineering / Banking",
      poruthamScore: "8.5 / 10",
      poruthamLabel: "உத்தம பொருத்தம் (High Match)",
      harmonyPercentage: "98%",
      kootuPorutham: "10/10 கூத்து பொருத்தம்",
      specialBadge: "Trust Verified",
      imageAsset: "assets/images/bride_soundarya.jpg",
      hobbies: [
        "Classical Music",
        "Spiritual / Bhakti",
        "Books & History",
        "Vegetarian"
      ],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98421 11001",
      whatsapp: "+91 98421 11001",
      email: "soundarya.r@pandarathar.com",
      avatarSeed: "Soundarya",
      avatarColorHex: "6B1E2E",
    ),

    // Candidate 2: Kavitha M. (Doctor)
    ProfileModel(
      id: "PM-1002",
      name: "Kavitha M.",
      nameTamil: "கவிதா M.",
      gender: "Bride",
      age: 24,
      height: "5' 2\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      doshamType: "none",
      star: "உத்திரம் (Uthiram)",
      rasi: "கன்னி (Kanni)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "22 Aug 2000",
      chevvaiDosham: "இல்லை / No",
      education: "MBBS Doctor",
      degree: "MBBS",
      occupation: "Doctor / Healthcare",
      company: "Meenakshi Mission Hospital, Madurai",
      annualIncome: "₹10,00,000 PA",
      location: "Madurai (மதுரை), Tamil Nadu",
      about: "Compassionate healthcare professional dedicated to patient wellness and family traditions. Values mutual respect, warmth and Indian heritage.",
      fatherName: "M. Murugan (Government Officer)",
      motherName: "M. Saradha (Homemaker)",
      siblings: "None (Only Daughter)",
      familyLocation: "Madurai",
      familyDetails: "Reputed family in Madurai with high social standing and ethical principles.",
      preferredAge: "25 - 29 Yrs",
      preferredLocation: "Madurai, Coimbatore, Chennai",
      preferredEducation: "Doctor / Healthcare / IT",
      preferredOccupation: "Doctor / Engineer / Civil Services",
      poruthamScore: "8.5/10",
      poruthamLabel: "8.5/10 பொருத்தம்",
      harmonyPercentage: "92%",
      kootuPorutham: "9/10 கூத்து பொருத்தம்",
      specialBadge: "Doctor",
      imageAsset: "assets/images/doctor_kavitha.jpg",
      hobbies: ["Yoga & Health", "Reading", "Devotional Music"],
      isOnline: false,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'received',
      isContactUnlocked: false,
      phone: "+91 97890 22002",
      whatsapp: "+91 97890 22002",
      email: "dr.kavitha@pandarathar.com",
      avatarSeed: "Kavitha",
      avatarColorHex: "8C2C41",
    ),

    // Candidate 3: Sneha P. (Bank Officer)
    ProfileModel(
      id: "PM-1003",
      name: "Sneha P.",
      nameTamil: "ஸ்நேகா P.",
      gender: "Bride",
      age: 26,
      height: "5' 5\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      doshamType: "none",
      star: "அஸ்தம் (Hastham)",
      rasi: "கன்னி (Kanni)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "10 Feb 1998",
      chevvaiDosham: "இல்லை / No",
      education: "M.Sc., Bank Officer",
      degree: "M.Sc. Mathematics & Banking",
      occupation: "Assistant Manager - Banking",
      company: "State Bank of India",
      annualIncome: "₹9,00,000 PA",
      location: "Trichy (திருச்சி), Tamil Nadu",
      about: "Warm, organized and culturally rooted girl working in the banking sector. Loves spending time with family, cooking traditional delicacies and classical literature.",
      fatherName: "P. Periyasamy (Businessman)",
      motherName: "P. Valli (Homemaker)",
      siblings: "1 Elder Brother (Married, Architect)",
      familyLocation: "Trichy",
      familyDetails: "Traditional agricultural and business background from Trichy district.",
      preferredAge: "27 - 31 Yrs",
      preferredLocation: "Trichy, Thanjavur, Chennai, Coimbatore",
      preferredEducation: "PG / Engineer / MBA",
      preferredOccupation: "Banking / Govt / Software",
      poruthamScore: "10/10",
      poruthamLabel: "10/10 உத்தம பொருத்தம்",
      harmonyPercentage: "99%",
      kootuPorutham: "10/10 கூத்து பொருத்தம்",
      specialBadge: "புதிய வரன்",
      imageAsset: "assets/images/bride_sneha.jpg",
      hobbies: ["Traditional Cooking", "Temple Visits", "Veena"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98430 44004",
      whatsapp: "+91 98430 44004",
      email: "sneha.p@pandarathar.com",
      avatarSeed: "Sneha",
      avatarColorHex: "D9A441",
    ),

    // Candidate 4: Priya M.
    ProfileModel(
      id: "PM-1004",
      name: "Priya M.",
      nameTamil: "பிரியா M.",
      gender: "Bride",
      age: 24,
      height: "5' 3\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "மிருகசீரிடம் (Mrigashira)",
      rasi: "மிதுனம் (Mithunam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "18 Jun 2000",
      chevvaiDosham: "இல்லை / No",
      education: "B.E. Electronics & Communication",
      degree: "B.E. ECE",
      occupation: "Embedded Systems Engineer",
      company: "Bosch Global Technologies",
      annualIncome: "₹11,00,000 PA",
      location: "Chennai (சென்னை), Tamil Nadu",
      about: "Cheerful, family-loving and progressive girl. Passionate about innovation and Indian arts.",
      fatherName: "M. Manickam (Executive Engineer, TNEB)",
      motherName: "M. Banumathi (Teacher)",
      siblings: "1 Younger Brother",
      familyLocation: "Chennai",
      familyDetails: "Well-settled nuclear family in Chennai with native roots in Thanjavur.",
      preferredAge: "26 - 30 Yrs",
      preferredLocation: "Chennai, Coimbatore, Bangalore",
      preferredEducation: "B.E / B.Tech / M.S",
      preferredOccupation: "Software / Engineering",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 உத்தம பொருத்தம்",
      harmonyPercentage: "95%",
      kootuPorutham: "9/10 கூத்து பொருத்தம்",
      specialBadge: "Verified Lineage",
      imageAsset: "assets/images/bride_sneha.jpg",
      hobbies: ["Painting", "Carnatic Vocals", "Travel"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'sent',
      isContactUnlocked: false,
      phone: "+91 94441 55005",
      whatsapp: "+91 94441 55005",
      email: "priya.m@pandarathar.com",
      avatarSeed: "Priya",
      avatarColorHex: "6B1E2E",
      doshamType: "none",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1004.pdf",
    ),

    // Candidate 5: Ananya S. (Bride with Chevvai Dosham)
    ProfileModel(
      id: "PM-1005",
      name: "Ananya S.",
      nameTamil: "அனன்யா S.",
      gender: "Bride",
      age: 26,
      height: "5' 3\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "அனுஷம் (Anusham)",
      rasi: "விருச்சிகம் (Viruchigam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "12 Aug 1999",
      chevvaiDosham: "உண்டு / Yes (செவ்வாய் 7-ம் இடம்)",
      doshamType: "chevvai",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1005.pdf",
      education: "M.Com, Chartered Accountant (Inter)",
      degree: "M.Com, CA Inter",
      occupation: "Senior Financial Analyst",
      company: "Deloitte India",
      annualIncome: "₹10,50,000 PA",
      location: "Madurai, Tamil Nadu",
      about: "Traditional, family-centered girl with strong devotion. Looking for a Chevvai Dosham groom from our Pandarathar community.",
      fatherName: "S. Shanmugam (Auditor)",
      motherName: "S. Gowri (Homemaker)",
      siblings: "None",
      familyLocation: "Madurai",
      familyDetails: "Reputed family residing in Madurai city with roots in Erode.",
      preferredAge: "27 - 31 Yrs",
      preferredLocation: "Madurai, Coimbatore, Chennai",
      preferredEducation: "CA / MBA / BE / Govt",
      preferredOccupation: "Finance / Software / Govt",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 செவ்வாய் பொருத்தம்",
      harmonyPercentage: "96%",
      specialBadge: "செவ்வாய் தோஷம்",
      imageAsset: "assets/images/doctor_kavitha.jpg",
      hobbies: ["Carnatic Singing", "Temple Tours", "Cooking"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98421 77007",
      whatsapp: "+91 98421 77007",
      email: "ananya.s@pandarathar.com",
      avatarSeed: "Ananya",
      avatarColorHex: "9C27B0",
    ),

    // Candidate 6: Vignesh S. (Groom - Shudha Jathagam / No Dosham)
    ProfileModel(
      id: "PM-1006",
      name: "Vignesh S.",
      nameTamil: "விக்னேஷ் S.",
      gender: "Groom",
      age: 29,
      height: "5' 11\" (180 cm)",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "ரோகிணி (Rohini)",
      rasi: "ரிஷபம் (Rishabham)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "24 Nov 1996",
      chevvaiDosham: "இல்லை / No (சுத்த ஜாதகம்)",
      doshamType: "none",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1006.pdf",
      education: "B.Tech Computer Science, Anna University",
      degree: "B.Tech CSE",
      occupation: "Cloud Solutions Architect",
      company: "Amazon AWS",
      annualIncome: "₹24,00,000 PA",
      location: "Coimbatore / Bangalore",
      about: "Energetic, grounded and culturally minded Pandarathar youth. Enjoys badminton, reading, and temple festivals.",
      fatherName: "S. Sivasubramaniam (Business)",
      motherName: "S. Revathi (Teacher)",
      siblings: "1 Elder Sister (Married)",
      familyLocation: "Coimbatore",
      familyDetails: "Upper middle class business family from Coimbatore.",
      preferredAge: "24 - 28 Yrs",
      preferredLocation: "Coimbatore, Erode, Tirupur, Chennai",
      preferredEducation: "BE / B.Tech / PG / Doctor",
      preferredOccupation: "IT / Professional / Banking",
      poruthamScore: "9.5 / 10",
      poruthamLabel: "உத்தம பொருத்தம்",
      harmonyPercentage: "97%",
      specialBadge: "Aadhaar Verified",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Badminton", "Reading", "Travel"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 99441 88008",
      whatsapp: "+91 99441 88008",
      email: "vignesh.s@pandarathar.com",
      avatarSeed: "Vignesh",
      avatarColorHex: "1B5E20",
    ),

    // Candidate 7: Saravanan M. (Groom with Chevvai Dosham)
    ProfileModel(
      id: "PM-1007",
      name: "Saravanan M.",
      nameTamil: "சரவணன் M.",
      gender: "Groom",
      age: 30,
      height: "5' 9\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "அஸ்தம் (Hastham)",
      rasi: "கன்னி (Kanni)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "05 Mar 1995",
      chevvaiDosham: "உண்டு / Yes (செவ்வாய் 8-ம் இடம்)",
      doshamType: "chevvai",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1007.pdf",
      education: "B.E. Civil, Assistant Engineer (Govt)",
      degree: "B.E. Civil",
      occupation: "Assistant Engineer (Govt PWD)",
      company: "Tamil Nadu PWD",
      annualIncome: "₹11,00,000 PA",
      location: "Thanjavur, Tamil Nadu",
      about: "Government engineer with disciplined, traditional values. Seeking an understanding Pandarathar girl with Chevvai Dosham.",
      fatherName: "M. Muthusamy (Retired Agriculture Officer)",
      motherName: "M. Saraswathi",
      siblings: "1 Younger Brother (Engineer in Chennai)",
      familyLocation: "Thanjavur",
      familyDetails: "Agricultural landholding and respected lineage in Thanjavur district.",
      preferredAge: "24 - 28 Yrs",
      preferredLocation: "Thanjavur, Trichy, Kumbakonam, Erode",
      preferredEducation: "Degree / PG / B.Ed",
      preferredOccupation: "Teaching / Govt / Professional",
      poruthamScore: "9/10",
      poruthamLabel: "செவ்வாய் பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: "Govt Employee",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Farming", "Temple Music", "Cricket"],
      isOnline: false,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'received',
      isContactUnlocked: false,
      phone: "+91 97500 11001",
      whatsapp: "+91 97500 11001",
      email: "saravanan.pwd@pandarathar.com",
      avatarSeed: "Saravanan",
      avatarColorHex: "E65100",
    ),

    // Candidate 8: Rajesh K. (Groom with Rahu-Ketu Dosham)
    ProfileModel(
      id: "PM-1008",
      name: "Dr. Rajesh K.",
      nameTamil: "டாக்டர் ராஜேஷ் K.",
      gender: "Groom",
      age: 28,
      height: "5' 10\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "சுவாதி (Swathi)",
      rasi: "துலாம் (Thulam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "19 Oct 1997",
      chevvaiDosham: "இல்லை / No",
      doshamType: "rahu_ketu",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1008.pdf",
      education: "MBBS, MD General Medicine",
      degree: "MD Gen Med",
      occupation: "Consultant Physician",
      company: "Apollo Speciality Hospitals",
      annualIncome: "₹18,00,000 PA",
      location: "Chennai, Tamil Nadu",
      about: "Compassionate medical professional. Raised in a loving joint family. Values traditions and community bonding.",
      fatherName: "Dr. K. Krishnan (Paediatrician)",
      motherName: "K. Mythili",
      siblings: "1 Elder Brother (Doctor)",
      familyLocation: "Chennai",
      familyDetails: "Prestigious doctor family residing in Chennai.",
      preferredAge: "24 - 27 Yrs",
      preferredLocation: "Chennai, Coimbatore, Erode",
      preferredEducation: "MBBS / BDS / Professional",
      preferredOccupation: "Doctor / Healthcare / Professional",
      poruthamScore: "9/10",
      poruthamLabel: "ராகு-கேது பொருத்தம்",
      harmonyPercentage: "94%",
      specialBadge: "Doctor",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Medical Research", "Carnatic Flute", "Reading"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 94432 99009",
      whatsapp: "+91 94432 99009",
      email: "dr.rajesh@pandarathar.com",
      avatarSeed: "Rajesh",
      avatarColorHex: "00695C",
    ),

    // Candidate 9: Meenakshi R. (Bride with Rahu-Ketu Dosham)
    ProfileModel(
      id: "PM-1009",
      name: "Meenakshi R.",
      nameTamil: "மீனாட்சி R.",
      gender: "Bride",
      age: 25,
      height: "5' 4\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "சுவாதி (Swathi)",
      rasi: "துலாம் (Thulam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "14 Jul 2000",
      chevvaiDosham: "இல்லை / No (ராகு-கேது தோஷம்)",
      doshamType: "rahu_ketu",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1009.pdf",
      education: "M.Sc Data Science, Anna University",
      degree: "M.Sc Data Science",
      occupation: "Senior Data Scientist",
      company: "Cognizant Technology Solutions",
      annualIncome: "₹13,50,000 PA",
      location: "Chennai / Thanjavur",
      about: "Smart, culturally rooted girl with deep respect for family traditions. Looking for a Rahu-Ketu compatible groom from Pandarathar community.",
      fatherName: "R. Ramanathan (State Govt Officer)",
      motherName: "R. Meera (Teacher)",
      siblings: "1 Younger Brother",
      familyLocation: "Thanjavur",
      familyDetails: "Cultured, well-regarded Pandarathar family in Thanjavur.",
      preferredAge: "26 - 30 Yrs",
      preferredLocation: "Chennai, Coimbatore, Trichy",
      preferredEducation: "BE / B.Tech / MBA / Masters",
      preferredOccupation: "IT / Tech / Govt / Banking",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 ராகு-கேது பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: "ராகு-கேது தோஷம்",
      imageAsset: "assets/images/bride_sneha.jpg",
      hobbies: ["Carnatic Music", "Oil Painting", "Yoga"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 94441 55221",
      whatsapp: "+91 94441 55221",
      email: "meenakshi.r@pandarathar.com",
      avatarSeed: "Meenakshi",
      avatarColorHex: "6A1B9A",
    ),

    // Candidate 10: Swathi N. (Bride with Both Chevvai & Rahu-Ketu - Double Dosham)
    ProfileModel(
      id: "PM-1010",
      name: "Swathi N.",
      nameTamil: "சுவாதி N.",
      gender: "Bride",
      age: 26,
      height: "5' 5\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "சித்திரை (Chithirai)",
      rasi: "கன்னி (Kanni)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "08 Oct 1999",
      chevvaiDosham: "உண்டு / Yes (செவ்வாய் 7 & ராகு 8)",
      doshamType: "chevvai_rahu_ketu",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1010.pdf",
      education: "B.Tech Information Technology, PSG Tech",
      degree: "B.Tech IT",
      occupation: "Lead Cloud Architect",
      company: "Zoho Corporation",
      annualIncome: "₹15,00,000 PA",
      location: "Coimbatore, Tamil Nadu",
      about: "Warm, ambitious and cheerful girl with traditional values. Seeking an understanding groom with Double Dosham from Pandarathar community.",
      fatherName: "N. Natarajan (Textile Mill Director)",
      motherName: "N. Bhuvaneswari",
      siblings: "1 Elder Sister (Married)",
      familyLocation: "Coimbatore",
      familyDetails: "Established textile and industrial family rooted in Coimbatore.",
      preferredAge: "27 - 31 Yrs",
      preferredLocation: "Coimbatore, Erode, Chennai",
      preferredEducation: "B.Tech / MBA / MS / Professional",
      preferredOccupation: "Software / Industrial / Business",
      poruthamScore: "9.5/10",
      poruthamLabel: "9.5/10 இரட்டை தோஷ பொருத்தம்",
      harmonyPercentage: "96%",
      specialBadge: "இரட்டை தோஷம்",
      imageAsset: "assets/images/wedding_couple.jpg",
      hobbies: ["Classical Dance", "Badminton", "Reading"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98422 66334",
      whatsapp: "+91 98422 66334",
      email: "swathi.n@pandarathar.com",
      avatarSeed: "Swathi",
      avatarColorHex: "AD1457",
    ),

    // Candidate 11: Dharani K. (Bride with Kalathira / Mangalya Dosham)
    ProfileModel(
      id: "PM-1011",
      name: "Dharani K.",
      nameTamil: "தாரணி K.",
      gender: "Bride",
      age: 25,
      height: "5' 3\"",
      maritalStatus: "மறுமணம் / Divorced",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "பூசம் (Poosam)",
      rasi: "கடகம் (Kadagam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "22 May 2000",
      chevvaiDosham: "இல்லை / No (மறுமணம் ஜாதகம்)",
      doshamType: "marumanam",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1011.pdf",
      education: "B.Arch (Architecture), School of Architecture",
      degree: "B.Arch",
      occupation: "Senior Landscape Architect",
      company: "Urban Heritage Designs",
      annualIncome: "₹10,00,000 PA",
      location: "Madurai / Trichy",
      about: "Creative, warm-hearted and family-loving Pandarathar girl. மறுமணம் ஜாதகம் (Remarriage Jathagam).",
      fatherName: "K. Kalyanasundaram (Civil Engineer)",
      motherName: "K. Jayanthi (Bank Officer)",
      siblings: "1 Younger Sister",
      familyLocation: "Madurai",
      familyDetails: "Reputed engineering and banking family in Madurai.",
      preferredAge: "26 - 30 Yrs",
      preferredLocation: "Madurai, Trichy, Coimbatore, Chennai",
      preferredEducation: "Architect / BE / MBA / Professional",
      preferredOccupation: "Design / Construction / IT / Govt",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 களத்திர பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: "களத்திர தோஷம்",
      imageAsset: "assets/images/bride_sneha.jpg",
      hobbies: ["Painting", "Gardening", "Violin"],
      isOnline: false,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 97910 88229",
      whatsapp: "+91 97910 88229",
      email: "dharani.k@pandarathar.com",
      avatarSeed: "Dharani",
      avatarColorHex: "880E4F",
    ),

    // Candidate 12: Karthikeyan N. (Groom with Double Dosham - Chevvai & Rahu-Ketu)
    ProfileModel(
      id: "PM-1012",
      name: "Karthikeyan N.",
      nameTamil: "கார்த்திகேயன் N.",
      gender: "Groom",
      age: 29,
      height: "5' 10\"",
      maritalStatus: "Never Married",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "விசாகம் (Visakam)",
      rasi: "விருச்சிகம் (Viruchigam)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "18 Nov 1996",
      chevvaiDosham: "உண்டு / Yes (செவ்வாய் & ராகு தோஷம்)",
      doshamType: "chevvai_rahu_ketu",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1012.pdf",
      education: "B.E Mechanical, MBA Operations",
      degree: "B.E, MBA",
      occupation: "Senior Operations Manager",
      company: "Larsen & Toubro (L&T)",
      annualIncome: "₹17,00,000 PA",
      location: "Coimbatore / Chennai",
      about: "Dynamic and principled professional with strong attachment to family. Seeking a Pandarathar bride with Double Dosham.",
      fatherName: "N. Neelakantan (Retired District Registrar)",
      motherName: "N. Padmavathi",
      siblings: "1 Elder Brother (Chartered Accountant)",
      familyLocation: "Coimbatore",
      familyDetails: "High-integrity family from Coimbatore with ancestral lands in Erode.",
      preferredAge: "24 - 28 Yrs",
      preferredLocation: "Coimbatore, Erode, Salem, Chennai",
      preferredEducation: "Degree / PG / B.Tech / CA",
      preferredOccupation: "Corporate / Banking / Teaching",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 இரட்டை தோஷ பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: "இரட்டை தோஷம்",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Tennis", "Numismatics", "Temple Tours"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 94890 33441",
      whatsapp: "+91 94890 33441",
      email: "karthik.lt@pandarathar.com",
      avatarSeed: "Karthikeyan",
      avatarColorHex: "BF360C",
    ),

    // Candidate 13: Dr. Senthil Kumar (Groom with Kalathira Dosham)
    ProfileModel(
      id: "PM-1013",
      name: "Dr. Senthil Kumar M.",
      nameTamil: "டாக்டர் செந்தில் குமார் M.",
      gender: "Groom",
      age: 31,
      height: "5' 9\"",
      maritalStatus: "மறுமணம் / Divorced",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "அஸ்வினி (Aswini)",
      rasi: "மேஷம் (Mesham)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "10 Apr 1994",
      chevvaiDosham: "இல்லை / No (களத்திர தோஷம்)",
      doshamType: "kalathra",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1013.pdf",
      education: "BDS, MDS Orthodontics",
      degree: "MDS Orthodontist",
      occupation: "Chief Dental Surgeon & Clinic Director",
      company: "Senthil Multispeciality Dental Hospital",
      annualIncome: "₹22,00,000 PA",
      location: "Salem, Tamil Nadu",
      about: "Warm, accomplished specialist doctor with deep cultural roots. Seeking an educated, caring Pandarathar bride with Kalathira Dosham compatibility.",
      fatherName: "M. Manickam (Industrialist)",
      motherName: "M. Vijayalakshmi",
      siblings: "1 Younger Sister (Doctor, Married)",
      familyLocation: "Salem",
      familyDetails: "Prominent medical and business family in Salem district.",
      preferredAge: "24 - 29 Yrs",
      preferredLocation: "Salem, Erode, Coimbatore, Namakkal",
      preferredEducation: "Doctor / BDS / BE / PG / Lecturer",
      preferredOccupation: "Healthcare / Teaching / Professional",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 களத்திர பொருத்தம்",
      harmonyPercentage: "96%",
      specialBadge: "களத்திர தோஷம்",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Photography", "Marathon", "Spiritual Reading"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98940 77119",
      whatsapp: "+91 98940 77119",
      email: "dr.senthil@pandarathar.com",
      avatarSeed: "Senthil",
      avatarColorHex: "004D40",
    ),

    // Candidate 14: Gokulnath R. (Groom with Marumanam Jathagam)
    ProfileModel(
      id: "PM-1014",
      name: "Gokulnath R.",
      nameTamil: "கோகுல்நாத் R.",
      gender: "Groom",
      age: 32,
      height: "5' 10\"",
      maritalStatus: "மறுமணம் / Divorced",
      motherTongue: "Tamil",
      motherTongueTamil: "தமிழ்",
      religion: "Hindu",
      community: AppConstants.communityName,
      subSect: "பண்டாரத்தார் (Pandarathar)",
      caste: "Pandarathar (பண்டாரத்தார்)",
      star: "அஸ்தம் (Hastham)",
      rasi: "கன்னி (Kanni)",
      gothram: "சிவகோத்திரம் (Siva Gothram)",
      dob: "12 Aug 1993",
      chevvaiDosham: "இல்லை / No (மறுமணம் ஜாதகம்)",
      doshamType: "marumanam",
      r2CertificateUrl: "https://pub-r2.pandarathar-matrimony.com/certificates/PM-1014.pdf",
      education: "B.Tech IT, MBA",
      degree: "B.Tech, MBA",
      occupation: "Senior Product Manager",
      company: "Infosys Technologies",
      annualIncome: "₹18,00,000 PA",
      location: "Coimbatore, Tamil Nadu",
      about: "Warm, respectful Pandarathar professional seeking understanding partner. மறுமணம் ஜாதகம் (Remarriage Jathagam).",
      fatherName: "R. Ramasamy (Agriculturist)",
      motherName: "R. Parvathi",
      siblings: "1 Elder Brother (Married)",
      familyLocation: "Coimbatore",
      familyDetails: "Traditional agricultural family.",
      preferredAge: "26 - 31 Yrs",
      preferredLocation: "Coimbatore, Erode, Tiruppur",
      preferredEducation: "Degree / PG / IT",
      preferredOccupation: "Working / Professional",
      poruthamScore: "9/10",
      poruthamLabel: "9/10 மறுமணம் பொருத்தம்",
      harmonyPercentage: "95%",
      specialBadge: "மறுமணம்",
      imageAsset: "assets/images/user_karthik.jpg",
      hobbies: ["Reading", "Travel"],
      isOnline: true,
      isVerified: true,
      isShortlisted: false,
      interestStatus: 'none',
      isContactUnlocked: false,
      phone: "+91 98422 11990",
      whatsapp: "+91 98422 11990",
      email: "gokul.r@pandarathar.com",
      avatarSeed: "Gokulnath",
      avatarColorHex: "283593",
    ),
  ];

  // Mock Notifications
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: "n1",
      title: "New Profile View",
      message: "Soundarya R. (PM-1001) viewed your profile.",
      timeAgo: "10 mins ago",
      type: NotificationType.view,
    ),
    NotificationModel(
      id: "n2",
      title: "Interest Received",
      message: "Kavitha M. (PM-1002) expressed interest in your profile.",
      timeAgo: "2 hours ago",
      type: NotificationType.interest,
    ),
    NotificationModel(
      id: "n3",
      title: "18 New Matches Available",
      message: "18 new auspicious matches aligned with your star and Pandarathar community.",
      timeAgo: "Today, 8:00 AM",
      type: NotificationType.interest,
    ),
    NotificationModel(
      id: "n4",
      title: "Community Verified ✓",
      message: "Your profile has been authenticated by Pandarathar Mana Maalai elders committee.",
      timeAgo: "2 days ago",
      type: NotificationType.verification,
      isRead: true,
    ),
  ];

  // Mock Success Stories
  final List<SuccessStoryModel> _successStories = [
    SuccessStoryModel(
      id: "s1",
      coupleName: "Kartik & Soundarya",
      marriageDate: "12th November 2024",
      location: "Thanjavur",
      story: "We connected through Pandarathar Mana Maalai. From our first conversation, our families felt the strong alignment of sacred traditions and values.",
      groomSeed: "Kartik",
      brideSeed: "Soundarya",
    ),
    SuccessStoryModel(
      id: "s2",
      coupleName: "Aravind & Divya",
      marriageDate: "5th August 2024",
      location: "Coimbatore",
      story: "Finding a life partner within our Pandarathar community who shared similar aspirations was made smooth and genuine here.",
      groomSeed: "Aravind",
      brideSeed: "Divya",
    ),
  ];

  // Getters
  List<ProfileModel> get allProfiles => List.unmodifiable(_profiles);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<SuccessStoryModel> get successStories => List.unmodifiable(_successStories);

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  List<ProfileModel> get recommendedMatches =>
      _profiles.where((p) => p.isVerified).toList();

  List<ProfileModel> get newMatches =>
      _profiles.reversed.toList();

  List<ProfileModel> get recentlyActive =>
      _profiles.where((p) => p.isOnline).toList();

  List<ProfileModel> get verifiedProfiles =>
      _profiles.where((p) => p.isVerified).toList();

  List<ProfileModel> get shortlistedProfiles =>
      _profiles.where((p) => p.isShortlisted).toList();

  List<ProfileModel> get receivedInterests =>
      _profiles.where((p) => p.interestStatus == 'received').toList();

  List<ProfileModel> get sentInterests =>
      _profiles.where((p) => p.interestStatus == 'sent' || p.interestStatus == 'accepted').toList();

  List<ProfileModel> get unlockedProfiles {
    final approvedProfileIds = approvedPaymentProfileIds;
    return _profiles
        .where((p) => approvedProfileIds.contains(p.id))
        .toList();
  }

  /// Calculate real matching count:
  /// For a new user who has not set their horoscope star yet, 0 matches are shown.
  /// When horoscope (star/rasi/dosham) is set, calculates real compatible opposite-gender candidates.
  int getRealMatchingCount(ProfileModel user) {
    if (user.star == null || user.star!.trim().isEmpty) {
      return 0;
    }

    final userGenderLower = user.gender.toLowerCase().trim();
    final bool isSeekingBride = userGenderLower == 'groom' || userGenderLower.contains('searching for bride');
    final String targetGender = isSeekingBride ? 'Bride' : 'Groom';

    return _profiles.where((p) {
      if (p.gender.toLowerCase() != targetGender.toLowerCase()) return false;
      if (p.id == user.id || p.phone == user.phone) return false;

      // Dosham compatibility check
      if (user.doshamType != null && user.doshamType!.isNotEmpty) {
        if (user.doshamType == 'none') {
          if (p.doshamType != 'none') return false;
        } else if (user.doshamType == 'chevvai') {
          if (p.doshamType != 'chevvai') return false;
        } else if (user.doshamType == 'rahu_ketu') {
          if (p.doshamType != 'rahu_ketu') return false;
        } else if (user.doshamType == 'chevvai_rahu_ketu') {
          if (p.doshamType != 'chevvai_rahu_ketu') return false;
        } else if (user.doshamType == 'marumanam' || user.doshamType == 'kalathra') {
          if (p.doshamType != 'marumanam' && p.doshamType != 'kalathra') return false;
        }
      }

      return true;
    }).length;
  }

  // Find profile by ID
  ProfileModel? getProfileById(String id) {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return _profiles.isNotEmpty ? _profiles.first : null;
    }
  }

  // State actions
  void toggleShortlist(String id) {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _profiles[index].isShortlisted = !_profiles[index].isShortlisted;
      final isNowLiked = _profiles[index].isShortlisted;

      // Persist to MongoDB database
      MongoDBService().updateUserProfile({
        'id': _profiles[index].id,
        'name': _profiles[index].name,
        'isShortlisted': isNowLiked,
      });

      // Also persist user's complete shortlist collection in MongoDB
      MongoDBService().saveShortlist(
        userId: currentUser.id,
        userPhone: currentUser.phone,
        profileIds: _profiles.where((p) => p.isShortlisted).map((p) => p.id).toList(),
      );

      if (isNowLiked) {
        _notifications.insert(
          0,
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: "வரன் விருப்பப்பட்டது / Profile Liked",
            message: "${_profiles[index].name} (${_profiles[index].id}) உங்கள் விருப்பப்பட்டியலில் சேர்க்கப்பட்டது.",
            timeAgo: "Just now",
            type: NotificationType.interest,
          ),
        );
      }
      notifyListeners();
    }
  }

  void sendInterest(String id) {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _profiles[index].interestStatus = 'sent';
      notifyListeners();
    }
  }

  void unlockContact(String id) {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _profiles[index].isContactUnlocked = true;
      _notifications.insert(
        0,
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "Contact Unlocked ✓",
          message: "You unlocked contact details for ${_profiles[index].name} (${_profiles[index].id}).",
          timeAgo: "Just now",
          type: NotificationType.unlock,
        ),
      );
      notifyListeners();
    }
  }

  void unlockHoroscope(String id) {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _profiles[index].isHoroscopeUnlocked = true;
      _notifications.insert(
        0,
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "Horoscope Unlocked ✓",
          message: "You unlocked the complete astrological chart & horoscope for ${_profiles[index].name} (${_profiles[index].id}).",
          timeAgo: "Just now",
          type: NotificationType.unlock,
        ),
      );
      notifyListeners();
    }
  }

  void unlockAll(String id) {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _profiles[index].isContactUnlocked = true;
      _profiles[index].isHoroscopeUnlocked = true;
      _notifications.insert(
        0,
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "Full Profile & Horoscope Unlocked ✓",
          message: "You unlocked full contact details & horoscope for ${_profiles[index].name} (${_profiles[index].id}).",
          timeAgo: "Just now",
          type: NotificationType.unlock,
        ),
      );
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void updateUserProfile(ProfileModel updated) {
    currentUser = updated;
    final index = _profiles.indexWhere((p) =>
        p.id == updated.id ||
        (p.phone.isNotEmpty &&
            p.phone.replaceAll(RegExp(r'\D'), '') ==
                updated.phone.replaceAll(RegExp(r'\D'), '')));
    if (index != -1) {
      _profiles[index] = updated;
    }

    // Persist to MongoDB database
    MongoDBService().updateUserProfile(updated.toMap());

    notifyListeners();
  }


  // ==========================================
  // CART FOR CONTACT UNLOCK (₹25 EACH)
  // ==========================================
  final Set<String> _cartProfileIds = {};

  List<ProfileModel> get cartProfiles =>
      _profiles.where((p) => _cartProfileIds.contains(p.id)).toList();

  int get cartCount => _cartProfileIds.length;

  double get cartTotalAmount => _cartProfileIds.length * 25.0;

  bool isInCart(String id) => _cartProfileIds.contains(id);

  void toggleCart(String id) {
    if (_cartProfileIds.contains(id)) {
      _cartProfileIds.remove(id);
    } else {
      _cartProfileIds.add(id);
    }
    notifyListeners();
  }

  void addToCart(String id) {
    _cartProfileIds.add(id);
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cartProfileIds.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _cartProfileIds.clear();
    notifyListeners();
  }

  // ==========================================
  // QR PAYMENT REQUESTS & ADMIN APPROVAL
  // ==========================================
  final List<PaymentRequestModel> _paymentRequests = [
    PaymentRequestModel(
      id: "REQ-928104",
      userId: "PM-1000",
      userName: "Karthik Sundaram",
      userPhone: "9876543210",
      profileIds: ["PM-1001"],
      profileNames: ["Soundarya R. (PM-1001)"],
      totalAmount: 25.0,
      utrNumber: "UPI839102847192",
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'approved',
    ),
  ];

  List<PaymentRequestModel> get paymentRequests =>
      List.unmodifiable(_paymentRequests);

  List<PaymentRequestModel> get pendingPaymentRequests =>
      _paymentRequests.where((r) => r.status == 'pending').toList();

  /// Profile IDs currently pending in an unapproved payment request for the current user
  Set<String> get pendingPaymentProfileIds {
    final cleanCurrentPhone = currentUser.phone.replaceAll(RegExp(r'\D'), '');
    return _paymentRequests
        .where((r) {
          if (r.status != 'pending') return false;
          if (r.userId == currentUser.id) return true;
          final rPhone = r.userPhone.replaceAll(RegExp(r'\D'), '');
          return cleanCurrentPhone.isNotEmpty && rPhone.isNotEmpty && rPhone == cleanCurrentPhone;
        })
        .expand((r) => r.profileIds)
        .where((id) => !isProfileUnlocked(id))
        .toSet();
  }

  /// Profile IDs approved through payment requests for the current user
  Set<String> get approvedPaymentProfileIds {
    final cleanCurrentPhone = currentUser.phone.replaceAll(RegExp(r'\D'), '');
    return _paymentRequests
        .where((r) {
          if (r.status != 'approved') return false;
          if (r.userId == currentUser.id) return true;
          final rPhone = r.userPhone.replaceAll(RegExp(r'\D'), '');
          return cleanCurrentPhone.isNotEmpty && rPhone.isNotEmpty && rPhone == cleanCurrentPhone;
        })
        .expand((r) => r.profileIds)
        .toSet();
  }

  /// Check whether a profile has been unlocked for the current user
  bool isProfileUnlocked(String id) {
    final p = getProfileById(id);
    if (p == null) return false;
    if (p.isContactUnlocked || p.isHoroscopeUnlocked) return true;
    return approvedPaymentProfileIds.contains(id);
  }

  /// Check whether a profile has a payment pending admin approval
  bool isProfilePendingApproval(String id) {
    return pendingPaymentProfileIds.contains(id) && !isProfileUnlocked(id);
  }

  /// Shortlisted profiles that are still locked and not pending approval
  List<ProfileModel> get shortlistedToUnlock {
    return shortlistedProfiles
        .where((p) => !isProfileUnlocked(p.id) && !isProfilePendingApproval(p.id))
        .toList();
  }

  /// Total amount required to unlock all currently locked shortlisted profiles (₹25 each)
  double get shortlistedToUnlockTotal => shortlistedToUnlock.length * 25.0;

  void submitPaymentRequest({required String utrNumber}) {
    if (_cartProfileIds.isEmpty) return;
    final cartList = cartProfiles;
    final newRequest = PaymentRequestModel(
      id: "REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      userId: currentUser.id,
      userName: currentUser.name,
      userPhone: currentUser.phone,
      profileIds: cartList.map((p) => p.id).toList(),
      profileNames: cartList.map((p) => p.name).toList(),
      totalAmount: cartList.length * 25.0,
      utrNumber: utrNumber,
      timestamp: DateTime.now(),
      status: 'pending',
    );
    _paymentRequests.insert(0, newRequest);
    _cartProfileIds.clear();

    // Persist payment to MongoDB database
    MongoDBService().savePaymentRequest(newRequest.toMap());

    _notifications.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "கட்டணம் சமர்ப்பிக்கப்பட்டது / Payment Submitted",
        message: "₹${newRequest.totalAmount.toInt()} கட்டணம் நிர்வாகி ஒப்புதலுக்கு அனுப்பப்பட்டுள்ளது (UTR: $utrNumber). சரிபார்க்கப்பட்டவுடன் தொடர்பு எண்கள் திறக்கப்படும்.",
        timeAgo: "Just now",
        type: NotificationType.unlock,
      ),
    );
    notifyListeners();
  }

  /// Submit payment request with custom details (User Name, Amount, UTR, Profile IDs)
  void submitPaymentRequestWithDetails({
    required String userName,
    required double amount,
    required String utrNumber,
    required List<String> profileIds,
    required List<String> profileNames,
  }) {
    final newRequest = PaymentRequestModel(
      id: "REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      userId: currentUser.id,
      userName: userName.trim().isNotEmpty ? userName.trim() : currentUser.name,
      userPhone: currentUser.phone,
      profileIds: profileIds,
      profileNames: profileNames,
      totalAmount: amount,
      utrNumber: utrNumber.trim(),
      timestamp: DateTime.now(),
      status: 'pending',
    );
    _paymentRequests.insert(0, newRequest);

    // Persist payment to MongoDB database
    MongoDBService().savePaymentRequest(newRequest.toMap());

    // Also persist user's complete shortlist collection in MongoDB
    MongoDBService().saveShortlist(
      userId: currentUser.id,
      profileIds: shortlistedProfiles.map((p) => p.id).toList(),
    );

    _notifications.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "கட்டணம் சமர்ப்பிக்கப்பட்டது / Payment Submitted",
        message: "₹${amount.toInt()} கட்டணம் நிர்வாகி ஒப்புதலுக்கு அனுப்பப்பட்டுள்ளது (UTR: $utrNumber). சரிபார்க்கப்பட்டவுடன் தொடர்பு எண்கள் திறக்கப்படும்.",
        timeAgo: "Just now",
        type: NotificationType.unlock,
      ),
    );
    notifyListeners();
  }

  void recordDirectPayment({
    required String utrNumber,
    required double amount,
    required List<String> profileIds,
    required List<String> profileNames,
  }) {
    final newRequest = PaymentRequestModel(
      id: "REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      userId: currentUser.id,
      userName: currentUser.name,
      userPhone: currentUser.phone,
      profileIds: profileIds,
      profileNames: profileNames,
      totalAmount: amount,
      utrNumber: utrNumber,
      timestamp: DateTime.now(),
      status: 'pending',
    );
    _paymentRequests.insert(0, newRequest);
    MongoDBService().savePaymentRequest(newRequest.toMap());

    _notifications.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "கட்டணம் பதிவு செய்யப்பட்டது / Payment Recorded",
        message: "₹${amount.toInt()} கட்டணம் (UTR: $utrNumber) தரவுத்தளத்தில் பதிவு செய்யப்பட்டு நிர்வாகி ஒப்புதலுக்கு அனுப்பப்பட்டது.",
        timeAgo: "Just now",
        type: NotificationType.unlock,
      ),
    );
    notifyListeners();
  }

  void approvePaymentRequest(String requestId) {
    final index = _paymentRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _paymentRequests[index].status = 'approved';
      final req = _paymentRequests[index];
      for (final pid in req.profileIds) {
        final pIdx = _profiles.indexWhere((p) => p.id == pid);
        if (pIdx != -1) {
          _profiles[pIdx].isContactUnlocked = true;
          _profiles[pIdx].isHoroscopeUnlocked = true;
          // Persist unlocked profile status to MongoDB database
          MongoDBService().updateUserProfile(_profiles[pIdx].toMap());
        }
      }
      // Persist status update to MongoDB database
      MongoDBService().savePaymentRequest(req.toMap());

      _notifications.insert(
        0,
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "தொடர்பு விவரங்கள் திறக்கப்பட்டது! / Contacts Unlocked",
          message: "நிர்வாகி உங்கள் ₹${req.totalAmount.toInt()} கட்டணத்தை அங்கீகரித்துள்ளார். ${req.profileNames.join(', ')} வரன்களின் தொலைபேசி மற்றும் முகவரி விவரங்கள் திறக்கப்பட்டன.",
          timeAgo: "Just now",
          type: NotificationType.unlock,
        ),
      );
      notifyListeners();
    }
  }

  void rejectPaymentRequest(String requestId) {
    final index = _paymentRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _paymentRequests[index].status = 'rejected';
      MongoDBService().savePaymentRequest(_paymentRequests[index].toMap());
      notifyListeners();
    }
  }

  // ==========================================
  // ADMIN PROFILE MANAGEMENT (ADD & DELETE)
  // ==========================================
  void addProfile(ProfileModel newProfile) {
    _profiles.insert(0, newProfile);
    _notifications.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "புதிய வரன் சேர்க்கப்பட்டது / New Profile Added",
        message: "${newProfile.name} (${newProfile.gender == 'Bride' ? 'மணமகள்' : 'மணமகன்'}) வரன் பட்டியலில் வெற்றிகரமாக சேர்க்கப்பட்டது.",
        timeAgo: "Just now",
        type: NotificationType.interest,
      ),
    );
    // Persist newly added profile to MongoDB Atlas database
    MongoDBService().updateUserProfile(newProfile.toMap());
    notifyListeners();
  }

  Future<bool> deleteProfile(String profileId) async {
    ProfileModel? target;
    for (final p in _profiles) {
      if (p.id == profileId) {
        target = p;
        break;
      }
    }
    _profiles.removeWhere((p) => p.id == profileId);
    _cartProfileIds.remove(profileId);
    notifyListeners();
    // Persist deletion to MongoDB Atlas database!
    return await MongoDBService().deleteProfile(profileId, phone: target?.phone);
  }

  void updateProfile(ProfileModel updatedProfile) {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index != -1) {
      _profiles[index] = updatedProfile;
      MongoDBService().updateUserProfile(updatedProfile.toMap());
      notifyListeners();
    }
  }

  /// Asynchronously loads profiles from MongoDB Atlas database
  Future<void> _loadProfilesFromAtlasAsync() async {
    try {
      final atlasDocs = await MongoDBService().getProfiles();
      if (atlasDocs.isNotEmpty) {
        bool changed = false;
        for (final doc in atlasDocs) {
          final id = doc['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final existingIdx = _profiles.indexWhere((p) => p.id == id);
          final p = ProfileModel.fromMap(doc);
          if (existingIdx != -1) {
            // Keep unlocked contact state if unlocked in memory or Atlas
            final wasUnlocked = _profiles[existingIdx].isContactUnlocked;
            final wasHoroscopeUnlocked = _profiles[existingIdx].isHoroscopeUnlocked;
            _profiles[existingIdx] = p.copyWith(
              isContactUnlocked: wasUnlocked || p.isContactUnlocked,
              isHoroscopeUnlocked: wasHoroscopeUnlocked || p.isHoroscopeUnlocked,
            );
          } else {
            _profiles.insert(0, p);
          }
          changed = true;
        }
        if (changed) {
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // ==========================================
  // SMART HOROSCOPE & CASTE MATCH FILTER
  // ==========================================
  List<ProfileModel> filterSmartMatches({
    String lookingForGender = 'All', // 'Bride' or 'Groom' or 'All'
    String? caste, // e.g. "Pandarathar (பண்டாரத்தார்)" or 'All'
    String? myDosham, // 'none', 'chevvai', 'rahu_ketu', 'chevvai_rahu_ketu', 'kalathra', 'all'
    List<String>? doshams, // multi-select doshams
    String? star,
    List<String>? stars, // multi-select stars
    String? rasi,
    List<String>? rasis, // multi-select rasis
    int? fixedAge,
    bool exactAgeMatch = false,
    RangeValues? ageRange,
    String? education,
    List<String>? educations, // multi-select educations
    String? location,
    List<String>? locations, // multi-select locations
    String? searchQuery,
  }) {
    return _profiles.where((p) {
      // 1. Gender check (Looking for Bride, Groom, or All)
      if (lookingForGender.isNotEmpty && lookingForGender != 'All') {
        if (p.gender.toLowerCase() != lookingForGender.toLowerCase()) return false;
      }

      // 2. Direct Search Query (Matches Name, Tamil Name, Profile ID, City, Job, Degree)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final nameEn = p.name.toLowerCase();
        final nameTa = (p.nameTamil ?? '').toLowerCase();
        final id = p.id.toLowerCase();
        final loc = p.location.toLowerCase();
        final occ = p.occupation.toLowerCase();
        final edu = p.education.toLowerCase();
        final deg = (p.degree ?? '').toLowerCase();
        final starName = (p.star ?? '').toLowerCase();
        final rasiName = (p.rasi ?? '').toLowerCase();

        final matchesQuery = nameEn.contains(query) ||
            nameTa.contains(query) ||
            id.contains(query) ||
            loc.contains(query) ||
            occ.contains(query) ||
            edu.contains(query) ||
            deg.contains(query) ||
            starName.contains(query) ||
            rasiName.contains(query);

        if (!matchesQuery) return false;
      }

      // 3. Particular Caste Alone
      if (caste != null && caste.isNotEmpty && caste != 'All' && caste != 'All Castes' && !caste.toLowerCase().contains('all')) {
        final pCaste = (p.caste ?? p.community).toLowerCase();
        final pSub = (p.subSect ?? '').toLowerCase();
        final filterLower = caste.toLowerCase();

        final isPandaratharFilter = filterLower.contains('pandarathar') || filterLower.contains('பண்டாரத்தார்');
        if (isPandaratharFilter) {
          final isCandidatePandarathar = pCaste.contains('pandarathar') ||
              pCaste.contains('பண்டாரத்தார்') ||
              pSub.contains('pandarathar') ||
              pSub.contains('பண்டாரத்தார்');
          if (!isCandidatePandarathar) return false;
        } else {
          final clean = filterLower.trim();
          if (!pCaste.contains(clean) && !pSub.contains(clean)) return false;
        }
      }

      // 4. Astrological Dosham Compatibility Matcher (Multi or Single)
      final doshamCheckList = (doshams != null && doshams.isNotEmpty)
          ? doshams
          : (myDosham != null && myDosham.isNotEmpty && myDosham != 'all' ? [myDosham] : null);

      if (doshamCheckList != null && doshamCheckList.isNotEmpty) {
        bool matchesAnyDosham = false;
        for (final d in doshamCheckList) {
          if (d == 'chevvai') {
            final candidateHasChevvai = (p.chevvaiDosham?.toLowerCase().contains('yes') == true ||
                p.chevvaiDosham?.contains('உண்டு') == true ||
                p.doshamType == 'chevvai' ||
                p.doshamType == 'chevvai_rahu_ketu');
            if (candidateHasChevvai) {
              matchesAnyDosham = true;
              break;
            }
          } else if (d == 'none') {
            final candidateHasDosham = (p.chevvaiDosham?.toLowerCase().contains('yes') == true ||
                p.chevvaiDosham?.contains('உண்டு') == true ||
                p.doshamType == 'chevvai' ||
                p.doshamType == 'rahu_ketu' ||
                p.doshamType == 'chevvai_rahu_ketu' ||
                p.doshamType == 'kalathra');
            if (!candidateHasDosham) {
              matchesAnyDosham = true;
              break;
            }
          } else if (d == 'rahu_ketu') {
            final candidateHasRahuKetu = (p.doshamType == 'rahu_ketu' || p.doshamType == 'chevvai_rahu_ketu');
            if (candidateHasRahuKetu) {
              matchesAnyDosham = true;
              break;
            }
          } else if (d == 'chevvai_rahu_ketu') {
            final candidateHasDoubleDosham = (p.doshamType == 'chevvai_rahu_ketu');
            if (candidateHasDoubleDosham) {
              matchesAnyDosham = true;
              break;
            }
          } else if (d == 'marumanam') {
            final isMarumanam = (p.doshamType == 'marumanam' ||
                p.maritalStatus.toLowerCase() != 'never married' ||
                p.maritalStatus.contains('மறுமணம்') ||
                p.about.contains('மறுமணம்'));
            if (isMarumanam) {
              matchesAnyDosham = true;
              break;
            }
          } else if (d == 'kalathra') {
            if (p.doshamType == 'kalathra') {
              matchesAnyDosham = true;
              break;
            }
          }
        }
        if (!matchesAnyDosham) return false;
      }

      // 5. Age Filtering (Fixed Age or Range)
      if (fixedAge != null) {
        if (exactAgeMatch) {
          if (p.age != fixedAge) return false;
        } else {
          if ((p.age - fixedAge).abs() > 1) return false;
        }
      } else if (ageRange != null) {
        if (p.age < ageRange.start || p.age > ageRange.end) return false;
      }

      // 6. Star (Nakshatra) - Multi or Single
      final starCheckList = (stars != null && stars.isNotEmpty)
          ? stars
          : (star != null && star.isNotEmpty && star != 'All' && star != 'All Stars' ? [star] : null);

      if (starCheckList != null && starCheckList.isNotEmpty) {
        if (p.star == null) return false;
        final pStarLower = p.star!.toLowerCase();
        bool matchesAnyStar = false;
        for (final st in starCheckList) {
          final starLower = st.toLowerCase();
          if (pStarLower.contains(starLower) || starLower.contains(pStarLower)) {
            matchesAnyStar = true;
            break;
          }
          if (st.contains('(')) {
            final parts = st.split('(');
            final tamilPart = parts[0].trim().toLowerCase();
            final englishPart = parts[1].replaceAll(')', '').trim().toLowerCase();
            if (pStarLower.contains(tamilPart) || pStarLower.contains(englishPart)) {
              matchesAnyStar = true;
              break;
            }
          }
        }
        if (!matchesAnyStar) return false;
      }

      // 7. Rasi (Moon Sign) - Multi or Single
      final rasiCheckList = (rasis != null && rasis.isNotEmpty)
          ? rasis
          : (rasi != null && rasi.isNotEmpty && rasi != 'All' && rasi != 'All Rasis' ? [rasi] : null);

      if (rasiCheckList != null && rasiCheckList.isNotEmpty) {
        if (p.rasi == null) return false;
        final pRasiLower = p.rasi!.toLowerCase();
        bool matchesAnyRasi = false;
        for (final rs in rasiCheckList) {
          final rasiLower = rs.toLowerCase();
          if (pRasiLower.contains(rasiLower) || rasiLower.contains(pRasiLower)) {
            matchesAnyRasi = true;
            break;
          }
          if (rs.contains('(')) {
            final parts = rs.split('(');
            final tamilPart = parts[0].trim().toLowerCase();
            final englishPart = parts[1].replaceAll(')', '').trim().toLowerCase();
            if (pRasiLower.contains(tamilPart) || pRasiLower.contains(englishPart)) {
              matchesAnyRasi = true;
              break;
            }
          }
        }
        if (!matchesAnyRasi) return false;
      }

      // 8. Education Filtering - Multi or Single
      final eduCheckList = (educations != null && educations.isNotEmpty)
          ? educations
          : (education != null && education.isNotEmpty && education != 'All' && education != 'All Degrees' ? [education] : null);

      if (eduCheckList != null && eduCheckList.isNotEmpty) {
        final pEdu = '${p.education} ${p.degree ?? ''} ${p.occupation}'.toLowerCase();
        bool matchesAnyEdu = false;
        for (final ed in eduCheckList) {
          final eduLower = ed.toLowerCase();
          if (eduLower.contains('doctor') || eduLower.contains('mbbs')) {
            if (pEdu.contains('doctor') || pEdu.contains('mbbs') || pEdu.contains('md') || pEdu.contains('bds')) {
              matchesAnyEdu = true;
              break;
            }
          } else if (eduLower.contains('b.tech') || eduLower.contains('b.e')) {
            if (pEdu.contains('b.tech') || pEdu.contains('b.e') || pEdu.contains('engineer') || pEdu.contains('technology')) {
              matchesAnyEdu = true;
              break;
            }
          } else if (eduLower.contains('m.sc') || eduLower.contains('m.tech')) {
            if (pEdu.contains('m.sc') || pEdu.contains('m.tech') || pEdu.contains('master') || pEdu.contains('pg')) {
              matchesAnyEdu = true;
              break;
            }
          } else if (eduLower.contains('mba') || eduLower.contains('finance')) {
            if (pEdu.contains('mba') || pEdu.contains('finance') || pEdu.contains('m.com') || pEdu.contains('ca') || pEdu.contains('analyst')) {
              matchesAnyEdu = true;
              break;
            }
          } else if (eduLower.contains('govt') || eduLower.contains('degree')) {
            if (pEdu.contains('govt') || pEdu.contains('b.sc') || pEdu.contains('b.com') || pEdu.contains('b.a') || pEdu.contains('pwd') || pEdu.contains('officer')) {
              matchesAnyEdu = true;
              break;
            }
          } else {
            if (pEdu.contains(eduLower)) {
              matchesAnyEdu = true;
              break;
            }
          }
        }
        if (!matchesAnyEdu) return false;
      }

      // 9. Location Filtering - Multi or Single
      final locCheckList = (locations != null && locations.isNotEmpty)
          ? locations
          : (location != null && location.isNotEmpty && location != 'All' && location != 'All Locations' ? [location] : null);

      if (locCheckList != null && locCheckList.isNotEmpty) {
        final pLoc = p.location.toLowerCase();
        final pFamLoc = p.familyLocation.toLowerCase();
        bool matchesAnyLoc = false;
        for (final loc in locCheckList) {
          final filterLoc = loc.toLowerCase();
          if (pLoc.contains(filterLoc) || pFamLoc.contains(filterLoc)) {
            matchesAnyLoc = true;
            break;
          }
          if (loc.contains('(')) {
            final parts = loc.split('(');
            final p1 = parts[0].trim().toLowerCase();
            final p2 = parts[1].replaceAll(')', '').trim().toLowerCase();
            if (pLoc.contains(p1) || pLoc.contains(p2) || pFamLoc.contains(p1) || pFamLoc.contains(p2)) {
              matchesAnyLoc = true;
              break;
            }
          }
        }
        if (!matchesAnyLoc) return false;
      }

      return true;
    }).toList();
  }

  // Filter profiles
  List<ProfileModel> filterProfiles({
    String? gender,
    RangeValues? ageRange,
    String? maritalStatus,
    String? location,
    String? education,
    String? star,
    String? rasi,
  }) {
    return _profiles.where((p) {
      if (gender != null && gender.isNotEmpty && gender != 'All') {
        if (p.gender.toLowerCase() != gender.toLowerCase()) return false;
      }
      if (ageRange != null) {
        if (p.age < ageRange.start || p.age > ageRange.end) return false;
      }
      if (maritalStatus != null && maritalStatus.isNotEmpty && maritalStatus != 'All') {
        if (!p.maritalStatus.toLowerCase().contains(maritalStatus.toLowerCase())) return false;
      }
      if (location != null && location.isNotEmpty && location != 'All') {
        if (!p.location.toLowerCase().contains(location.toLowerCase())) return false;
      }
      if (education != null && education.isNotEmpty && education != 'All') {
        if (!p.education.toLowerCase().contains(education.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }
}
