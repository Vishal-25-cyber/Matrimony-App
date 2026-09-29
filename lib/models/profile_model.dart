import 'dart:typed_data';
import 'horoscope_chart_model.dart';

class ProfileModel {
  final String id;
  final String name;
  final String? nameTamil;
  final String gender; // 'Bride' or 'Groom'
  final int age;
  final String height;
  final String maritalStatus;
  final String motherTongue;
  final String? motherTongueTamil;
  final String religion;
  final String community;
  final String? subSect;
  final String? star; // e.g. "ரோகிணி (Rohini)"
  final String? rasi; // e.g. "ரிஷபம் (Rishabham)"
  final String? gothram; // e.g. "சிவகோத்திரம் (Siva Gothram)"
  final String? dob; // e.g. "14 May 1999"
  final String? chevvaiDosham; // "இல்லை / No"
  final String? poruthamScore; // e.g. "8.5 / 10" or "9/10"
  final String? poruthamLabel; // e.g. "உத்தம பொருத்தம் (High Match)"
  final String? harmonyPercentage; // e.g. "98%"
  final String? kootuPorutham; // e.g. "10/10 கூத்து பொருத்தம்"
  final String? specialBadge; // e.g. "Doctor", "புதிய வரன்", "New Today"
  final String? imageAsset;
  final Uint8List? imageBytes; // Path to local asset image
  final List<String>? hobbies; // e.g. ["Classical Music", "Spiritual / Bhakti"]
  final String education;
  final String? degree;
  final String occupation;
  final String company;
  final String annualIncome;
  final String location;
  final String about;
  final String fatherName;
  final String motherName;
  final String siblings;
  final String familyLocation;
  final String familyDetails;
  final String preferredAge;
  final String preferredLocation;
  final String preferredEducation;
  final String preferredOccupation;
  final bool isOnline;
  final bool isVerified;
  bool isShortlisted;
  String interestStatus; // 'none', 'sent', 'received', 'accepted'
  bool isContactUnlocked;
  bool isHoroscopeUnlocked;
  final String? caste; // e.g. "Pandarathar (பண்டாரத்தார்)"
  final String? doshamType; // 'none', 'chevvai', 'rahu_ketu', 'chevvai_rahu_ketu', 'kalathra'
  final String? r2CertificateUrl; // Cloudflare R2 certificate URL
  final String? profileImageUrl; // Cloudflare R2 profile image URL
  bool inCart;
  final String phone;
  final String whatsapp;
  final String email;
  final String avatarSeed;
  final String avatarColorHex;
  final Map<String, String>? rasiChart;
  final Map<String, String>? navamsamChart;

  ProfileModel({
    required this.id,
    required this.name,
    this.nameTamil,
    required this.gender,
    required this.age,
    required this.height,
    required this.maritalStatus,
    required this.motherTongue,
    this.motherTongueTamil,
    required this.religion,
    required this.community,
    this.subSect,
    this.star,
    this.rasi,
    this.gothram,
    this.dob,
    this.chevvaiDosham,
    this.poruthamScore,
    this.poruthamLabel,
    this.harmonyPercentage,
    this.kootuPorutham,
    this.specialBadge,
    this.imageAsset,
    this.imageBytes,
    this.hobbies,
    required this.education,
    this.degree,
    required this.occupation,
    required this.company,
    required this.annualIncome,
    required this.location,
    required this.about,
    required this.fatherName,
    required this.motherName,
    required this.siblings,
    required this.familyLocation,
    required this.familyDetails,
    required this.preferredAge,
    required this.preferredLocation,
    required this.preferredEducation,
    required this.preferredOccupation,
    this.isOnline = false,
    this.isVerified = true,
    this.isShortlisted = false,
    this.interestStatus = 'none',
    this.isContactUnlocked = false,
    this.isHoroscopeUnlocked = false,
    this.caste = "Pandarathar (பண்டாரத்தார்)",
    this.doshamType = 'none',
    this.r2CertificateUrl,
    this.profileImageUrl,
    this.inCart = false,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.avatarSeed,
    this.avatarColorHex = '6B1E2E',
    this.rasiChart,
    this.navamsamChart,
  });

  Map<String, String> getEffectiveRasiChart() {
    if (rasiChart != null && rasiChart!.isNotEmpty) {
      return rasiChart!;
    }
    if (doshamType == 'chevvai' || doshamType == 'chevvai_rahu_ketu') {
      return HoroscopeChartModel.getChevvaiRasiTemplate();
    } else if (doshamType == 'rahu_ketu') {
      return HoroscopeChartModel.getRahuKetuRasiTemplate();
    }
    return HoroscopeChartModel.getShudhaRasiTemplate();
  }

  Map<String, String> getEffectiveNavamsamChart() {
    if (navamsamChart != null && navamsamChart!.isNotEmpty) {
      return navamsamChart!;
    }
    return HoroscopeChartModel.getStandardNavamsamTemplate();
  }

  String get doshamDisplayName {
    switch (doshamType) {
      case 'chevvai':
        return "செவ்வாய் தோஷம் (Chevvai Dosham)";
      case 'rahu_ketu':
        return "ராகு - கேது தோஷம் (Rahu-Ketu Dosham)";
      case 'chevvai_rahu_ketu':
        return "இரட்டை தோஷம் (Both Chevvai & Rahu-Ketu)";
      case 'kalathra':
        return "களத்திர / மாங்கல்ய தோஷம் (Kalathira Dosham)";
      case 'none':
      default:
        return "சுத்த ஜாதகம் (Shudha Jathagam / No Dosham)";
    }
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? nameTamil,
    String? gender,
    int? age,
    String? height,
    String? maritalStatus,
    String? motherTongue,
    String? motherTongueTamil,
    String? religion,
    String? community,
    String? subSect,
    String? star,
    String? rasi,
    String? gothram,
    String? dob,
    String? chevvaiDosham,
    String? poruthamScore,
    String? poruthamLabel,
    String? harmonyPercentage,
    String? kootuPorutham,
    String? specialBadge,
    String? imageAsset,
    Uint8List? imageBytes,
    List<String>? hobbies,
    String? education,
    String? degree,
    String? occupation,
    String? company,
    String? annualIncome,
    String? location,
    String? about,
    String? fatherName,
    String? motherName,
    String? siblings,
    String? familyLocation,
    String? familyDetails,
    String? preferredAge,
    String? preferredLocation,
    String? preferredEducation,
    String? preferredOccupation,
    bool? isOnline,
    bool? isVerified,
    bool? isShortlisted,
    String? interestStatus,
    bool? isContactUnlocked,
    bool? isHoroscopeUnlocked,
    String? caste,
    String? doshamType,
    String? r2CertificateUrl,
    String? profileImageUrl,
    bool? inCart,
    String? phone,
    String? whatsapp,
    String? email,
    String? avatarSeed,
    String? avatarColorHex,
    Map<String, String>? rasiChart,
    Map<String, String>? navamsamChart,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameTamil: nameTamil ?? this.nameTamil,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      motherTongue: motherTongue ?? this.motherTongue,
      motherTongueTamil: motherTongueTamil ?? this.motherTongueTamil,
      religion: religion ?? this.religion,
      community: community ?? this.community,
      subSect: subSect ?? this.subSect,
      star: star ?? this.star,
      rasi: rasi ?? this.rasi,
      gothram: gothram ?? this.gothram,
      dob: dob ?? this.dob,
      chevvaiDosham: chevvaiDosham ?? this.chevvaiDosham,
      poruthamScore: poruthamScore ?? this.poruthamScore,
      poruthamLabel: poruthamLabel ?? this.poruthamLabel,
      harmonyPercentage: harmonyPercentage ?? this.harmonyPercentage,
      kootuPorutham: kootuPorutham ?? this.kootuPorutham,
      specialBadge: specialBadge ?? this.specialBadge,
      imageAsset: imageAsset ?? this.imageAsset,
      imageBytes: imageBytes ?? this.imageBytes,
      hobbies: hobbies ?? this.hobbies,
      education: education ?? this.education,
      degree: degree ?? this.degree,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      annualIncome: annualIncome ?? this.annualIncome,
      location: location ?? this.location,
      about: about ?? this.about,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      siblings: siblings ?? this.siblings,
      familyLocation: familyLocation ?? this.familyLocation,
      familyDetails: familyDetails ?? this.familyDetails,
      preferredAge: preferredAge ?? this.preferredAge,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredEducation: preferredEducation ?? this.preferredEducation,
      preferredOccupation: preferredOccupation ?? this.preferredOccupation,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      isShortlisted: isShortlisted ?? this.isShortlisted,
      interestStatus: interestStatus ?? this.interestStatus,
      isContactUnlocked: isContactUnlocked ?? this.isContactUnlocked,
      isHoroscopeUnlocked: isHoroscopeUnlocked ?? this.isHoroscopeUnlocked,
      caste: caste ?? this.caste,
      doshamType: doshamType ?? this.doshamType,
      r2CertificateUrl: r2CertificateUrl ?? this.r2CertificateUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      inCart: inCart ?? this.inCart,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      rasiChart: rasiChart ?? this.rasiChart,
      navamsamChart: navamsamChart ?? this.navamsamChart,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameTamil': nameTamil,
      'gender': gender,
      'age': age,
      'height': height,
      'maritalStatus': maritalStatus,
      'motherTongue': motherTongue,
      'motherTongueTamil': motherTongueTamil,
      'religion': religion,
      'community': community,
      'subSect': subSect,
      'caste': caste,
      'star': star,
      'rasi': rasi,
      'gothram': gothram,
      'dob': dob,
      'chevvaiDosham': chevvaiDosham,
      'doshamType': doshamType,
      'poruthamScore': poruthamScore,
      'poruthamLabel': poruthamLabel,
      'harmonyPercentage': harmonyPercentage,
      'kootuPorutham': kootuPorutham,
      'specialBadge': specialBadge,
      'education': education,
      'degree': degree,
      'occupation': occupation,
      'company': company,
      'annualIncome': annualIncome,
      'location': location,
      'about': about,
      'fatherName': fatherName,
      'motherName': motherName,
      'siblings': siblings,
      'familyLocation': familyLocation,
      'familyDetails': familyDetails,
      'preferredAge': preferredAge,
      'preferredLocation': preferredLocation,
      'preferredEducation': preferredEducation,
      'preferredOccupation': preferredOccupation,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'avatarSeed': avatarSeed,
      'avatarColorHex': avatarColorHex,
      'imageAsset': imageAsset ?? defaultCatalogAsset(id, name),
      'profileImageUrl': profileImageUrl,
      'r2ProfileImageUrl': profileImageUrl,
      'hasCustomImage': imageBytes != null || (profileImageUrl != null && profileImageUrl!.isNotEmpty),
      'imageBytesCount': imageBytes?.length ?? 0,
      'isOnline': isOnline,
      'isVerified': isVerified,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Default asset photo for predefined catalog profiles
  static String? defaultCatalogAsset(String id, [String? name]) {
    switch (id) {
      case 'PM-1001':
        return 'assets/images/bride_soundarya.jpg';
      case 'PM-1002':
        return 'assets/images/doctor_kavitha.jpg';
      case 'PM-1003':
      case 'PM-1004':
        return 'assets/images/bride_sneha.jpg';
      case 'PM-1005':
        return 'assets/images/doctor_kavitha.jpg';
      case 'PM-1006':
      case 'PM-1007':
      case 'PM-1008':
        return 'assets/images/user_karthik.jpg';
      case 'PM-1009':
        return 'assets/images/bride_sneha.jpg';
      case 'PM-1010':
        return 'assets/images/wedding_couple.jpg';
      case 'PM-1011':
        return 'assets/images/bride_sneha.jpg';
      case 'PM-1012':
      case 'PM-1013':
      case 'PM-1014':
        return 'assets/images/user_karthik.jpg';
      default:
        if (name != null && name.isNotEmpty) {
          final n = name.toLowerCase();
          if (n.contains('soundarya') || n.contains('சௌந்தர்யா')) {
            return 'assets/images/bride_soundarya.jpg';
          }
          if (n.contains('kavitha') || n.contains('கவிதா')) {
            return 'assets/images/doctor_kavitha.jpg';
          }
          if (n.contains('sneha') || n.contains('ஸ்நேகா')) {
            return 'assets/images/bride_sneha.jpg';
          }
          if (n.contains('karthik') || n.contains('கார்த்திக்')) {
            return 'assets/images/user_karthik.jpg';
          }
        }
        return null;
    }
  }

  /// Returns active image asset or catalog fallback
  String? get displayImageAsset {
    if (imageAsset != null && imageAsset!.trim().isNotEmpty) {
      return imageAsset!.trim();
    }
    return defaultCatalogAsset(id, name);
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? 'PM-1000';
    final name = map['name']?.toString() ?? '';
    final rawAsset = map['imageAsset']?.toString();
    final resolvedAsset = (rawAsset != null && rawAsset.trim().isNotEmpty)
        ? rawAsset.trim()
        : defaultCatalogAsset(id, name);

    return ProfileModel(
      id: id,
      name: name,
      nameTamil: map['nameTamil']?.toString() ?? map['name']?.toString(),
      gender: map['gender']?.toString() ?? 'Groom',
      age: int.tryParse(map['age']?.toString() ?? '') ?? 26,
      height: map['height']?.toString() ?? "5'8\"",
      maritalStatus: map['maritalStatus']?.toString() ?? 'Never Married',
      motherTongue: map['motherTongue']?.toString() ?? 'Tamil',
      motherTongueTamil: map['motherTongueTamil']?.toString() ?? 'தமிழ்',
      religion: map['religion']?.toString() ?? 'Hindu',
      community: map['community']?.toString() ?? 'பண்டாரத்தார்',
      subSect: map['subSect']?.toString() ?? 'பண்டாரத்தார் (Pandarathar)',
      caste: map['caste']?.toString() ?? 'Pandarathar (பண்டாரத்தார்)',
      star: map['star']?.toString(),
      rasi: map['rasi']?.toString(),
      gothram: map['gothram']?.toString(),
      dob: map['dob']?.toString(),
      chevvaiDosham: map['chevvaiDosham']?.toString(),
      doshamType: map['doshamType']?.toString() ?? 'none',
      poruthamScore: map['poruthamScore']?.toString(),
      poruthamLabel: map['poruthamLabel']?.toString(),
      harmonyPercentage: map['harmonyPercentage']?.toString(),
      kootuPorutham: map['kootuPorutham']?.toString(),
      specialBadge: map['specialBadge']?.toString(),
      imageAsset: resolvedAsset,
      education: map['education']?.toString() ?? '',
      degree: map['degree']?.toString(),
      occupation: map['occupation']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      annualIncome: map['annualIncome']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      about: map['about']?.toString() ?? '',
      fatherName: map['fatherName']?.toString() ?? '',
      motherName: map['motherName']?.toString() ?? '',
      siblings: map['siblings']?.toString() ?? '',
      familyLocation: map['familyLocation']?.toString() ?? '',
      familyDetails: map['familyDetails']?.toString() ?? '',
      preferredAge: map['preferredAge']?.toString() ?? '',
      preferredLocation: map['preferredLocation']?.toString() ?? '',
      preferredEducation: map['preferredEducation']?.toString() ?? '',
      preferredOccupation: map['preferredOccupation']?.toString() ?? '',
      isOnline: map['isOnline'] == true,
      isVerified: map['isVerified'] ?? true,
      phone: map['phone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      avatarSeed: map['avatarSeed']?.toString() ?? map['name']?.toString() ?? 'User',
      avatarColorHex: map['avatarColorHex']?.toString() ?? '6B1E2E',
      profileImageUrl: map['profileImageUrl']?.toString() ?? map['r2ProfileImageUrl']?.toString(),
    );
  }
}

