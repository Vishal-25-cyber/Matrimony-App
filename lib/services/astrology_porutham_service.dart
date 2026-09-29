import 'package:flutter/material.dart';

/// Represents one of the 27 Nakshatras in Vedic / Tamil astrology.
class NakshatraInfo {
  final int index; // 1 to 27
  final String tamilName;
  final String englishName;
  final String ganam; // 'தேவ', 'மனுஷ', 'ராட்சச'
  final String yoniAnimal; // Animal name in Tamil
  final String yoniGender; // 'ஆண்' or 'பெண்'
  final String rajju; // 'சிரசு', 'கண்டம்', 'உதரம்', 'ஊரு', 'பாதம்'
  final String lord; // Planetary lord in Tamil
  final int defaultRasiIndex; // 1 to 12 typical/main Rasi

  const NakshatraInfo({
    required this.index,
    required this.tamilName,
    required this.englishName,
    required this.ganam,
    required this.yoniAnimal,
    required this.yoniGender,
    required this.rajju,
    required this.lord,
    required this.defaultRasiIndex,
  });

  String get displayName => "$tamilName ($englishName)";
}

/// Represents one of the 12 Rasis.
class RasiInfo {
  final int index; // 1 to 12
  final String tamilName;
  final String englishName;
  final String lord; // 'செவ்வாய்', 'சுக்கிரன்', 'புதன்', 'சந்திரன்', 'சூரியன்', 'குரு', 'சனி'
  final List<String> vasiyaRasis; // Tamil names of Rasis attracted

  const RasiInfo({
    required this.index,
    required this.tamilName,
    required this.englishName,
    required this.lord,
    required this.vasiyaRasis,
  });

  String get displayName => "$tamilName ($englishName)";
}

/// Represents a single Porutham result (one of the 10).
class PoruthamItem {
  final String id;
  final int number; // 1 to 10
  final String tamilName;
  final String englishName;
  final String significance;
  final String status; // 'உத்தமம்', 'மத்திமம்', 'பொருந்தாது', 'உண்டு', 'இல்லை'
  final bool isMatched;
  final double score; // 1.0, 0.5, 0.0
  final String description;
  final String girlDetail;
  final String boyDetail;

  const PoruthamItem({
    required this.id,
    required this.number,
    required this.tamilName,
    required this.englishName,
    required this.significance,
    required this.status,
    required this.isMatched,
    required this.score,
    required this.description,
    required this.girlDetail,
    required this.boyDetail,
  });

  Color get statusColor {
    if (isMatched && (status == 'உத்தமம்' || status == 'உண்டு')) {
      return const Color(0xFF1B6B38); // Forest Emerald Green
    } else if (status == 'மத்திமம்') {
      return const Color(0xFFB45309); // Warm Amber
    } else {
      return const Color(0xFFB91C1C); // Crimson Red
    }
  }

  Color get statusBgColor {
    if (isMatched && (status == 'உத்தமம்' || status == 'உண்டு')) {
      return const Color(0xFFE8F5E9);
    } else if (status == 'மத்திமம்') {
      return const Color(0xFFFEF3C7);
    } else {
      return const Color(0xFFFEE2E2);
    }
  }
}

/// Result of complete 10 Poruthams compatibility calculation.
class PoruthamCalculationResult {
  final NakshatraInfo brideStar;
  final NakshatraInfo groomStar;
  final RasiInfo brideRasi;
  final RasiInfo groomRasi;
  final List<PoruthamItem> items;
  final double totalScore; // e.g. 8.5
  final int matchedCount; // e.g. 8
  final bool rajjuOk;
  final String verdictTitle;
  final String verdictSubtitle;
  final Color verdictColor;
  final String astrologerSummary;

  const PoruthamCalculationResult({
    required this.brideStar,
    required this.groomStar,
    required this.brideRasi,
    required this.groomRasi,
    required this.items,
    required this.totalScore,
    required this.matchedCount,
    required this.rajjuOk,
    required this.verdictTitle,
    required this.verdictSubtitle,
    required this.verdictColor,
    required this.astrologerSummary,
  });
}

/// The AstrologyPoruthamService implements classical South Indian / Tamil Vedic
/// 10 Poruthams (பத்து திருமணப் பொருத்தங்கள்) matching rules.
class AstrologyPoruthamService {
  // 27 Nakshatras list
  static const List<NakshatraInfo> nakshatras = [
    NakshatraInfo(
      index: 1,
      tamilName: "அஸ்வினி",
      englishName: "Aswini",
      ganam: "தேவ",
      yoniAnimal: "குதிரை",
      yoniGender: "ஆண்",
      rajju: "பாதம்",
      lord: "கேது",
      defaultRasiIndex: 1, // மேஷம்
    ),
    NakshatraInfo(
      index: 2,
      tamilName: "பரணி",
      englishName: "Bharani",
      ganam: "மனுஷ",
      yoniAnimal: "யானை",
      yoniGender: "ஆண்",
      rajju: "ஊரு",
      lord: "சுக்கிரன்",
      defaultRasiIndex: 1, // மேஷம்
    ),
    NakshatraInfo(
      index: 3,
      tamilName: "கார்த்திகை",
      englishName: "Krittika",
      ganam: "ராட்சச",
      yoniAnimal: "ஆடு",
      yoniGender: "பெண்",
      rajju: "உதரம்",
      lord: "சூரியன்",
      defaultRasiIndex: 2, // ரிஷபம்
    ),
    NakshatraInfo(
      index: 4,
      tamilName: "ரோகிணி",
      englishName: "Rohini",
      ganam: "மனுஷ",
      yoniAnimal: "பாம்பு",
      yoniGender: "ஆண்",
      rajju: "கண்டம்",
      lord: "சந்திரன்",
      defaultRasiIndex: 2, // ரிஷபம்
    ),
    NakshatraInfo(
      index: 5,
      tamilName: "மிருகசீரிஷம்",
      englishName: "Mrigasheersham",
      ganam: "தேவ",
      yoniAnimal: "மான்",
      yoniGender: "பெண்",
      rajju: "சிரசு",
      lord: "செவ்வாய்",
      defaultRasiIndex: 3, // மிதுனம்
    ),
    NakshatraInfo(
      index: 6,
      tamilName: "திருவாதிரை",
      englishName: "Thiruvathirai",
      ganam: "மனுஷ",
      yoniAnimal: "நாய்",
      yoniGender: "ஆண்",
      rajju: "கண்டம்",
      lord: "ராகு",
      defaultRasiIndex: 3, // மிதுனம்
    ),
    NakshatraInfo(
      index: 7,
      tamilName: "புனர்பூசம்",
      englishName: "Punarpoosam",
      ganam: "தேவ",
      yoniAnimal: "பூனை",
      yoniGender: "பெண்",
      rajju: "உதரம்",
      lord: "குரு",
      defaultRasiIndex: 4, // கடகம்
    ),
    NakshatraInfo(
      index: 8,
      tamilName: "பூசம்",
      englishName: "Poosam",
      ganam: "தேவ",
      yoniAnimal: "ஆடு",
      yoniGender: "ஆண்",
      rajju: "ஊரு",
      lord: "சனி",
      defaultRasiIndex: 4, // கடகம்
    ),
    NakshatraInfo(
      index: 9,
      tamilName: "ஆயில்யம்",
      englishName: "Ayilyam",
      ganam: "ராட்சச",
      yoniAnimal: "பூனை",
      yoniGender: "ஆண்",
      rajju: "பாதம்",
      lord: "புதன்",
      defaultRasiIndex: 4, // கடகம்
    ),
    NakshatraInfo(
      index: 10,
      tamilName: "மகம்",
      englishName: "Magam",
      ganam: "ராட்சச",
      yoniAnimal: "எலி",
      yoniGender: "ஆண்",
      rajju: "பாதம்",
      lord: "கேது",
      defaultRasiIndex: 5, // சிம்மம்
    ),
    NakshatraInfo(
      index: 11,
      tamilName: "பூரம்",
      englishName: "Pooram",
      ganam: "மனுஷ",
      yoniAnimal: "எலி",
      yoniGender: "பெண்",
      rajju: "ஊரு",
      lord: "சுக்கிரன்",
      defaultRasiIndex: 5, // சிம்மம்
    ),
    NakshatraInfo(
      index: 12,
      tamilName: "உத்திரம்",
      englishName: "Uthiram",
      ganam: "மனுஷ",
      yoniAnimal: "பசு",
      yoniGender: "ஆண்",
      rajju: "உதரம்",
      lord: "சூரியன்",
      defaultRasiIndex: 5, // சிம்மம்/கன்னி
    ),
    NakshatraInfo(
      index: 13,
      tamilName: "அஸ்தம்",
      englishName: "Hastham",
      ganam: "தேவ",
      yoniAnimal: "எருமை",
      yoniGender: "பெண்",
      rajju: "கண்டம்",
      lord: "சந்திரன்",
      defaultRasiIndex: 6, // கன்னி
    ),
    NakshatraInfo(
      index: 14,
      tamilName: "சித்திரை",
      englishName: "Chithirai",
      ganam: "ராட்சச",
      yoniAnimal: "புலி",
      yoniGender: "பெண்",
      rajju: "சிரசு",
      lord: "செவ்வாய்",
      defaultRasiIndex: 6, // கன்னி/துலாம்
    ),
    NakshatraInfo(
      index: 15,
      tamilName: "சுவாதி",
      englishName: "Swathi",
      ganam: "தேவ",
      yoniAnimal: "எருமை",
      yoniGender: "ஆண்",
      rajju: "கண்டம்",
      lord: "ராகு",
      defaultRasiIndex: 7, // துலாம்
    ),
    NakshatraInfo(
      index: 16,
      tamilName: "விசாகம்",
      englishName: "Visakam",
      ganam: "ராட்சச",
      yoniAnimal: "புலி",
      yoniGender: "ஆண்",
      rajju: "உதரம்",
      lord: "குரு",
      defaultRasiIndex: 7, // துலாம்/விருச்சிகம்
    ),
    NakshatraInfo(
      index: 17,
      tamilName: "அனுஷம்",
      englishName: "Anusham",
      ganam: "தேவ",
      yoniAnimal: "மான்",
      yoniGender: "பெண்",
      rajju: "ஊரு",
      lord: "சனி",
      defaultRasiIndex: 8, // விருச்சிகம்
    ),
    NakshatraInfo(
      index: 18,
      tamilName: "கேட்டை",
      englishName: "Kettai",
      ganam: "ராட்சச",
      yoniAnimal: "மான்",
      yoniGender: "ஆண்",
      rajju: "பாதம்",
      lord: "புதன்",
      defaultRasiIndex: 8, // விருச்சிகம்
    ),
    NakshatraInfo(
      index: 19,
      tamilName: "மூலம்",
      englishName: "Moolam",
      ganam: "ராட்சச",
      yoniAnimal: "நாய்",
      yoniGender: "பெண்",
      rajju: "பாதம்",
      lord: "கேது",
      defaultRasiIndex: 9, // தனுசு
    ),
    NakshatraInfo(
      index: 20,
      tamilName: "பூராடம்",
      englishName: "Pooradam",
      ganam: "மனுஷ",
      yoniAnimal: "குரங்கு",
      yoniGender: "ஆண்",
      rajju: "ஊரு",
      lord: "சுக்கிரன்",
      defaultRasiIndex: 9, // தனுசு
    ),
    NakshatraInfo(
      index: 21,
      tamilName: "உத்திராடம்",
      englishName: "Uthiradam",
      ganam: "மனுஷ",
      yoniAnimal: "கீரி",
      yoniGender: "பெண்",
      rajju: "உதரம்",
      lord: "சூரியன்",
      defaultRasiIndex: 9, // தனுசு/மகரம்
    ),
    NakshatraInfo(
      index: 22,
      tamilName: "திருவோணம்",
      englishName: "Thiruvonam",
      ganam: "தேவ",
      yoniAnimal: "குரங்கு",
      yoniGender: "பெண்",
      rajju: "கண்டம்",
      lord: "சந்திரன்",
      defaultRasiIndex: 10, // மகரம்
    ),
    NakshatraInfo(
      index: 23,
      tamilName: "அவிட்டம்",
      englishName: "Avittam",
      ganam: "ராட்சச",
      yoniAnimal: "சிங்கம்",
      yoniGender: "பெண்",
      rajju: "சிரசு",
      lord: "செவ்வாய்",
      defaultRasiIndex: 10, // மகரம்/கும்பம்
    ),
    NakshatraInfo(
      index: 24,
      tamilName: "சதயம்",
      englishName: "Sadhayam",
      ganam: "ராட்சச",
      yoniAnimal: "குதிரை",
      yoniGender: "பெண்",
      rajju: "கண்டம்",
      lord: "ராகு",
      defaultRasiIndex: 11, // கும்பம்
    ),
    NakshatraInfo(
      index: 25,
      tamilName: "பூரட்டாதி",
      englishName: "Poorattathi",
      ganam: "மனுஷ",
      yoniAnimal: "சிங்கம்",
      yoniGender: "ஆண்",
      rajju: "உதரம்",
      lord: "குரு",
      defaultRasiIndex: 11, // கும்பம்/மீனம்
    ),
    NakshatraInfo(
      index: 26,
      tamilName: "உத்திரட்டாதி",
      englishName: "Uthirattathi",
      ganam: "மனுஷ",
      yoniAnimal: "பசு",
      yoniGender: "பெண்",
      rajju: "ஊரு",
      lord: "சனி",
      defaultRasiIndex: 12, // மீனம்
    ),
    NakshatraInfo(
      index: 27,
      tamilName: "ரேவதி",
      englishName: "Revathi",
      ganam: "தேவ",
      yoniAnimal: "யானை",
      yoniGender: "பெண்",
      rajju: "பாதம்",
      lord: "புதன்",
      defaultRasiIndex: 12, // மீனம்
    ),
  ];

  // 12 Rasis list
  static const List<RasiInfo> rasis = [
    RasiInfo(
      index: 1,
      tamilName: "மேஷம்",
      englishName: "Mesham / Aries",
      lord: "செவ்வாய்",
      vasiyaRasis: ["சிம்மம்", "விருச்சிகம்"],
    ),
    RasiInfo(
      index: 2,
      tamilName: "ரிஷபம்",
      englishName: "Rishabam / Taurus",
      lord: "சுக்கிரன்",
      vasiyaRasis: ["கடகம்", "துலாம்"],
    ),
    RasiInfo(
      index: 3,
      tamilName: "மிதுனம்",
      englishName: "Mithunam / Gemini",
      lord: "புதன்",
      vasiyaRasis: ["கன்னி"],
    ),
    RasiInfo(
      index: 4,
      tamilName: "கடகம்",
      englishName: "Katakam / Cancer",
      lord: "சந்திரன்",
      vasiyaRasis: ["விருச்சிகம்", "தனுசு"],
    ),
    RasiInfo(
      index: 5,
      tamilName: "சிம்மம்",
      englishName: "Simham / Leo",
      lord: "சூரியன்",
      vasiyaRasis: ["துலாம்", "மகரம்"],
    ),
    RasiInfo(
      index: 6,
      tamilName: "கன்னி",
      englishName: "Kanni / Virgo",
      lord: "புதன்",
      vasiyaRasis: ["மிதுனம்", "மீனம்"],
    ),
    RasiInfo(
      index: 7,
      tamilName: "துலாம்",
      englishName: "Thulam / Libra",
      lord: "சுக்கிரன்",
      vasiyaRasis: ["மகரம்"],
    ),
    RasiInfo(
      index: 8,
      tamilName: "விருச்சிகம்",
      englishName: "Viruchigam / Scorpio",
      lord: "செவ்வாய்",
      vasiyaRasis: ["கடகம்"],
    ),
    RasiInfo(
      index: 9,
      tamilName: "தனுசு",
      englishName: "Dhanusu / Sagittarius",
      lord: "குரு",
      vasiyaRasis: ["மீனம்"],
    ),
    RasiInfo(
      index: 10,
      tamilName: "மகரம்",
      englishName: "Makaram / Capricorn",
      lord: "சனி",
      vasiyaRasis: ["மேஷம்", "கும்பம்"],
    ),
    RasiInfo(
      index: 11,
      tamilName: "கும்பம்",
      englishName: "Kumbam / Aquarius",
      lord: "சனி",
      vasiyaRasis: ["மீனம்"],
    ),
    RasiInfo(
      index: 12,
      tamilName: "மீனம்",
      englishName: "Meenam / Pisces",
      lord: "குரு",
      vasiyaRasis: ["மகரம்"],
    ),
  ];

  /// Find Nakshatra by fuzzy string matching (Tamil or English or substrings)
  static NakshatraInfo findStar(String? query) {
    if (query == null || query.trim().isEmpty) return nakshatras[3]; // default Rohini
    final clean = query.trim().toLowerCase();

    for (final star in nakshatras) {
      if (clean.contains(star.tamilName.toLowerCase()) ||
          clean.contains(star.englishName.toLowerCase())) {
        return star;
      }
    }
    // Specific alias checks
    if (clean.contains("uthiram") || clean.contains("உத்திரம்")) {
      return nakshatras[11];
    }
    if (clean.contains("uthiradam") || clean.contains("உத்திராடம்")) {
      return nakshatras[20];
    }
    if (clean.contains("uthirattathi") || clean.contains("உத்திரட்டாதி")) {
      return nakshatras[25];
    }
    if (clean.contains("mrigas") || clean.contains("மிருக")) {
      return nakshatras[4];
    }
    if (clean.contains("thiruvo") || clean.contains("திருவோ")) {
      return nakshatras[21];
    }
    if (clean.contains("arudra") || clean.contains("ஆருத்ரா")) {
      return nakshatras[5];
    }

    return nakshatras[0]; // fallback Aswini
  }

  /// Find Rasi by fuzzy string matching (Tamil or English)
  static RasiInfo findRasi(String? query, {int? fallbackFromStarIndex}) {
    if (query != null && query.trim().isNotEmpty) {
      final clean = query.trim().toLowerCase();
      for (final rasi in rasis) {
        if (clean.contains(rasi.tamilName.toLowerCase()) ||
            clean.contains(rasi.englishName.toLowerCase())) {
          return rasi;
        }
      }
      if (clean.contains("simmam") || clean.contains("சிம்ம")) return rasis[4];
      if (clean.contains("rishab") || clean.contains("ரிஷப")) return rasis[1];
      if (clean.contains("mesha") || clean.contains("மேஷ")) return rasis[0];
      if (clean.contains("viruchi") || clean.contains("விருச்சி")) return rasis[7];
      if (clean.contains("katak") || clean.contains("கடக")) return rasis[3];
      if (clean.contains("dhanu") || clean.contains("தனு")) return rasis[8];
      if (clean.contains("makar") || clean.contains("மகர")) return rasis[9];
      if (clean.contains("kumba") || clean.contains("கும்ப")) return rasis[10];
      if (clean.contains("meen") || clean.contains("மீன")) return rasis[11];
      if (clean.contains("kanni") || clean.contains("கன்னி")) return rasis[5];
      if (clean.contains("thulam") || clean.contains("துலா")) return rasis[6];
      if (clean.contains("mithun") || clean.contains("மிது")) return rasis[2];
    }

    if (fallbackFromStarIndex != null && fallbackFromStarIndex >= 1 && fallbackFromStarIndex <= 27) {
      final defaultRasiIdx = nakshatras[fallbackFromStarIndex - 1].defaultRasiIndex;
      return rasis[defaultRasiIdx - 1];
    }
    return rasis[1]; // fallback Rishabam
  }

  /// Calculates the 10 Poruthams accurately according to classical Tamil astrology.
  static PoruthamCalculationResult calculate10Poruthams({
    required NakshatraInfo brideStar,
    required NakshatraInfo groomStar,
    required RasiInfo brideRasi,
    required RasiInfo groomRasi,
  }) {
    // 1. Calculate star distance (Girl to Boy, 1 to 27 inclusive)
    int starCount = groomStar.index - brideStar.index + 1;
    if (starCount <= 0) {
      starCount += 27;
    }

    // 2. Calculate Rasi distance (Girl to Boy, 1 to 12 inclusive)
    int rasiCount = groomRasi.index - brideRasi.index + 1;
    if (rasiCount <= 0) {
      rasiCount += 12;
    }

    final List<PoruthamItem> items = [];
    double totalPoints = 0.0;

    // -------------------------------------------------------------
    // 1. தினம் (Dinam Porutham) - ஆயுள், ஆரோக்கியம்
    // -------------------------------------------------------------
    {
      final navataraRem = (starCount - 1) % 9 + 1;
      bool dinamMatched = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (starCount == 1) {
        // Same star: allowed for specific stars
        const allowedSameStars = [4, 6, 10, 13, 16, 22, 26, 27];
        if (allowedSameStars.contains(brideStar.index)) {
          dinamMatched = true;
          pt = 1.0;
          status = 'உத்தமம்';
          desc = 'ஏக நட்சத்திரம் அனுமதிக்கப்பட்ட நட்சத்திரங்களில் ஒன்று - உத்தமம்.';
        } else {
          dinamMatched = false;
          pt = 0.0;
          status = 'பொருந்தாது';
          desc = 'ஒரே நட்சத்திரத்தில் திருமணம் தவிர்க்கப்பட வேண்டும் (ஜென்ம தாரை).';
        }
      } else if (navataraRem == 2) {
        dinamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '2-ம் தாரை (சம்பத்து தாரை) - தன தான்ய சம்பத்து மற்றும் ஆயுள் விருத்தி தரும்.';
      } else if (navataraRem == 4) {
        dinamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '4-ம் தாரை (சேம தாரை) - க்ஷேமம், உடல் ஆரோக்கியம் மற்றும் மங்கள வாழ்வு.';
      } else if (navataraRem == 6) {
        dinamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '6-ம் தாரை (சாதக தாரை) - அனைத்து காரியங்களிலும் வெற்றி தரும் சாதகப் பொருத்தம்.';
      } else if (navataraRem == 8) {
        dinamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '8-ம் தாரை (மைத்ர தாரை) - தம்பதியர் இடையே ஆழமான நட்பு மற்றும் பரஸ்பர அன்பு.';
      } else if (navataraRem == 9 || starCount == 27) {
        dinamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '9-ம் தாரை (பரம மைத்ர தாரை) - மிகச் சிறந்த பாசம் மற்றும் குடும்ப ஒற்றுமை.';
      } else if (navataraRem == 3) {
        dinamMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = '3-ம் தாரை (விபத்து தாரை) - எதிர்பாராத தடைகள் மற்றும் சிரமங்கள்.';
      } else if (navataraRem == 5) {
        dinamMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = '5-ம் தாரை (பிரத்யக்கு தாரை) - கருத்து வேறுபாடுகள் மற்றும் எதிர்ப்பு நிலை.';
      } else if (navataraRem == 7) {
        dinamMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = '7-ம் தாரை (வதைத் தாரை) - ஆரோக்கிய குறைபாடுகள் வரலாம்.';
      } else {
        dinamMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = '1-ம் தாரை (ஜென்ம தாரை) - மன அமைதி குறைய வாய்ப்பு.';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'dinam',
        number: 1,
        tamilName: 'தினம் (Dinam)',
        englishName: 'Health & Longevity',
        significance: 'ஆயுள் மற்றும் உடல் நலம்',
        status: status,
        isMatched: dinamMatched,
        score: pt,
        description: desc,
        girlDetail: '${brideStar.tamilName} (எண்: ${brideStar.index})',
        boyDetail: '${groomStar.tamilName} (தூரம்: $starCount)',
      ));
    }

    // -------------------------------------------------------------
    // 2. கணம் (Ganam Porutham) - குணப் பொருத்தம்
    // -------------------------------------------------------------
    {
      final bG = brideStar.ganam;
      final gG = groomStar.ganam;
      bool ganamMatched = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (bG == gG) {
        ganamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'இருவரும் ஒரே கணம் ($bG கணம்) - சிந்தனைகளிலும் குணத்திலும் சிறந்த ஒற்றுமை.';
      } else if ((bG == 'தேவ' && gG == 'மனுஷ') || (bG == 'மனுஷ' && gG == 'தேவ')) {
        ganamMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'தேவ - மனுஷ கண சேர்க்கை மிக நன்று - குடும்பத்தில் அமைதியும் அன்பும் நிலவும்.';
      } else if (bG != 'ராட்சச' && gG == 'ராட்சச') {
        ganamMatched = true;
        pt = 0.5;
        status = 'மத்திமம்';
        desc = 'ஆண் ராட்சச கணம், பெண் $bG கணம் - சாதாரணம் / மத்திம பலன்.';
      } else {
        // Girl is Rakshasa, Boy is Deva or Manusha
        if (starCount > 14) {
          ganamMatched = true;
          pt = 0.5;
          status = 'மத்திமம்';
          desc = 'பெண் ராட்சச கணம் ஆயினும், நட்சத்திர தூரம் 14-க்கு மேல் உள்ளதால் தோஷ நிவர்த்தி.';
        } else {
          ganamMatched = false;
          pt = 0.0;
          status = 'பொருந்தாது';
          desc = 'பெண் ராட்சச கணம், ஆண் $gG கணம் - குணவேறுபாடுகள் அதிகம் வரக்கூடும்.';
        }
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'ganam',
        number: 2,
        tamilName: 'கணம் (Ganam)',
        englishName: 'Temperament Compatibility',
        significance: 'குண ஒற்றுமை மற்றும் குடும்ப சுமுக நிலை',
        status: status,
        isMatched: ganamMatched,
        score: pt,
        description: desc,
        girlDetail: '$bG கணம்',
        boyDetail: '$gG கணம்',
      ));
    }

    // -------------------------------------------------------------
    // 3. மாஹேந்திரம் (Mahendram Porutham) - வம்ச விருத்தி
    // -------------------------------------------------------------
    {
      const mahendramCounts = [4, 7, 10, 13, 16, 19, 22, 25];
      final bool hasMahendram = mahendramCounts.contains(starCount);
      double pt = hasMahendram ? 1.0 : 0.0;
      String status = hasMahendram ? 'உண்டு' : 'இல்லை';
      String desc = hasMahendram
          ? 'மாஹேந்திர பொருத்தம் உண்டு (தூரம்: $starCount) - வம்ச விருத்தி, சற்புத்திர பாக்கியம்.'
          : 'மாஹேந்திரம் அமையவில்லை - மற்ற பொருத்தங்கள் மூலம் நிவர்த்தி பெறலாம்.';

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'mahendram',
        number: 3,
        tamilName: 'மாஹேந்திரம் (Mahendram)',
        englishName: 'Lineage & Progeny',
        significance: 'வம்ச விருத்தி மற்றும் புத்திர பாக்கியம்',
        status: status,
        isMatched: hasMahendram,
        score: pt,
        description: desc,
        girlDetail: brideStar.tamilName,
        boyDetail: 'நட்சத்திர தூரம்: $starCount',
      ));
    }

    // -------------------------------------------------------------
    // 4. ஸ்திரீ தீர்க்கம் (Sthree Dheergam Porutham) - மாங்கல்ய பலம்
    // -------------------------------------------------------------
    {
      bool sthreeOk = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (starCount > 13) {
        sthreeOk = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'தூரம் 13-க்கு மேல் ($starCount) - மிகச் சிறந்த மாங்கல்ய பலம், செல்வச் செழிப்பு.';
      } else if (starCount >= 7) {
        sthreeOk = true;
        pt = 0.5;
        status = 'மத்திமம்';
        desc = 'தூரம் 7 முதல் 13-க்குள் ($starCount) - மத்திம சுப பலன்.';
      } else {
        sthreeOk = false;
        pt = 0.0;
        status = 'இல்லை';
        desc = 'நட்சத்திர தூரம் 7-க்கு குறைவாக உள்ளது ($starCount).';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'sthree_dheergam',
        number: 4,
        tamilName: 'ஸ்திரீ தீர்க்கம் (Sthree Dheergam)',
        englishName: "Wife's Prosperity & Long Life",
        significance: 'குடும்ப சுபிட்சம் மற்றும் தீர்க்க சுமங்கலி பாக்கியம்',
        status: status,
        isMatched: sthreeOk,
        score: pt,
        description: desc,
        girlDetail: brideStar.tamilName,
        boyDetail: 'தூரம்: $starCount நட்சத்திரங்கள்',
      ));
    }

    // -------------------------------------------------------------
    // 5. யோனி (Yoni Porutham) - தாம்பத்திய சுகம்
    // -------------------------------------------------------------
    {
      final bA = brideStar.yoniAnimal;
      final gA = groomStar.yoniAnimal;
      bool yoniMatched = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      // Check Inimical animal pairs
      final bool isEnemy = _isYoniEnemy(bA, gA);

      if (isEnemy) {
        yoniMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = 'இயற்கை பகை மிருகங்கள் ($bA மற்றும் $gA) - தாம்பத்தியத்தில் இணக்கமின்மை.';
      } else if (bA == gA) {
        yoniMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'இருவரும் ஒரே யோனி ($bA) - மிக உயர்ந்த உடல் இணக்கம் மற்றும் பிரியமான தாம்பத்தியம்.';
      } else {
        yoniMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'நட்பான யோனி விலங்குகள் ($bA - $gA) - மனமகிழ்ச்சியான இல்லற வாழ்க்கை.';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'yoni',
        number: 5,
        tamilName: 'யோனி (Yoni)',
        englishName: 'Physical & Marital Harmony',
        significance: 'தாம்பத்திய சுகம் மற்றும் பரஸ்பர ஈர்ப்பு',
        status: status,
        isMatched: yoniMatched,
        score: pt,
        description: desc,
        girlDetail: '${brideStar.yoniGender} $bA',
        boyDetail: '${groomStar.yoniGender} $gA',
      ));
    }

    // -------------------------------------------------------------
    // 6. ராசி (Rasi Porutham) - குடும்ப ஒற்றுமை
    // -------------------------------------------------------------
    {
      bool rasiMatched = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (rasiCount == 7) {
        rasiMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'சம சப்தமம் (7-ம் ராசி) - மிகச் சிறந்த ஈர்ப்பு, பரஸ்பர ஆதரவு மற்றும் ஒற்றுமை.';
      } else if (rasiCount == 1) {
        if (groomStar.index >= brideStar.index) {
          rasiMatched = true;
          pt = 1.0;
          status = 'உத்தமம்';
          desc = 'ஏக ராசி, ஆண் நட்சத்திரம் பின்வருவது - உத்தம பொருத்தம்.';
        } else {
          rasiMatched = true;
          pt = 0.5;
          status = 'மத்திமம்';
          desc = 'ஏக ராசி - சுமாரான பலன்.';
        }
      } else if (rasiCount == 3 || rasiCount == 4 || rasiCount == 10 || rasiCount == 11) {
        rasiMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = '$rasiCount-ம் ராசி அமைவு - சிறந்த வளர்ச்சி, நலம் மற்றும் சுப காரிய அனுகூலம்.';
      } else if (rasiCount == 5 || rasiCount == 9) {
        rasiMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'திரிகோண ராசி ($rasiCount-ம் இடம்) - பூர்வ புண்ணிய பலன் மற்றும் நல்ல நட்பு.';
      } else if (rasiCount == 6 || rasiCount == 8) {
        // Sashtashtakam: check if lords are friends or same
        final sameLord = brideRasi.lord == groomRasi.lord;
        if (sameLord) {
          rasiMatched = true;
          pt = 0.5;
          status = 'மத்திமம்';
          desc = 'சஷ்டாஷ்டகம் (6-8) ஆயினும், ஒரே ராசி அதிபதி (${brideRasi.lord}) என்பதால் தோஷ நிவர்த்தி.';
        } else {
          rasiMatched = false;
          pt = 0.0;
          status = 'பொருந்தாது';
          desc = 'சஷ்டாஷ்டக தோஷம் (6-8 அமைவு) - வாக்குவாதங்கள், கருத்து மோதல் ஏற்படலாம்.';
        }
      } else if (rasiCount == 2 || rasiCount == 12) {
        rasiMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = 'த்வித்வாதசம் (2-12 அமைவு) - வரவை விட செலவுகள் மற்றும் விரயம் கூடும்.';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'rasi',
        number: 6,
        tamilName: 'ராசி (Rasi)',
        englishName: 'Family Unity & Growth',
        significance: 'குடும்ப வளர்ச்சி மற்றும் பரஸ்பர புரிந்துணர்வு',
        status: status,
        isMatched: rasiMatched,
        score: pt,
        description: desc,
        girlDetail: '${brideRasi.tamilName} (1)',
        boyDetail: '${groomRasi.tamilName} ($rasiCount-ம் இடம்)',
      ));
    }

    // -------------------------------------------------------------
    // 7. ராசியதிபதி (Rasiyathipathi Porutham) - மன ஒற்றுமை
    // -------------------------------------------------------------
    {
      final bL = brideRasi.lord;
      final gL = groomRasi.lord;
      bool lordMatched = false;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (bL == gL) {
        lordMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'இருவருக்கும் ஒரே ராசி அதிபதி ($bL) - ஒருமித்த மனம் மற்றும் ஆழமான அன்பு.';
      } else if (_arePlanetsFriends(bL, gL)) {
        lordMatched = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'ராசி அதிபதிகள் நட்பு கிரகங்கள் ($bL மற்றும் $gL) - குடும்பத்தில் பாசமும் மேன்மையும் கூடும்.';
      } else if (_arePlanetsNeutral(bL, gL)) {
        lordMatched = true;
        pt = 0.5;
        status = 'மத்திமம்';
        desc = 'ராசி அதிபதிகள் சம கிரகங்கள் ($bL - $gL) - சாதாரண பலன்.';
      } else {
        lordMatched = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = 'ராசி அதிபதிகள் பகை கிரகங்கள் ($bL மற்றும் $gL) - கருத்து முரண்பாடுகள் வரலாம்.';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'rasiyathipathi',
        number: 7,
        tamilName: 'ராசியதிபதி (Rasiyathipathi)',
        englishName: 'Planetary Lord Friendship',
        significance: 'மன ஒற்றுமை மற்றும் நட்பு பாராட்டுதல்',
        status: status,
        isMatched: lordMatched,
        score: pt,
        description: desc,
        girlDetail: '${brideRasi.tamilName} அதிபதி: $bL',
        boyDetail: '${groomRasi.tamilName} அதிபதி: $gL',
      ));
    }

    // -------------------------------------------------------------
    // 8. வசியம் (Vasiyam Porutham) - ஈர்ப்பு, அன்பு
    // -------------------------------------------------------------
    {
      final bool hasVasiyam = brideRasi.vasiyaRasis.contains(groomRasi.tamilName);
      double pt = hasVasiyam ? 1.0 : 0.0;
      String status = hasVasiyam ? 'உண்டு' : 'இல்லை';
      String desc = hasVasiyam
          ? '${brideRasi.tamilName} ராசிக்கு ${groomRasi.tamilName} வசிய ராசி - அன்யோன்ய அன்பு மற்றும் ஈர்ப்பு உண்டு.'
          : 'வசியப் பொருத்தம் அமையவில்லை (இயற்கை ஈர்ப்பு மற்ற பொருத்தங்களை சார்ந்தது).';

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'vasiyam',
        number: 8,
        tamilName: 'வசியம் (Vasiyam)',
        englishName: 'Mutual Attraction & Love',
        significance: 'தம்பதியர் இடையே மாறாத அன்பு மற்றும் ஈர்ப்பு',
        status: status,
        isMatched: hasVasiyam,
        score: pt,
        description: desc,
        girlDetail: '${brideRasi.tamilName} (வசியம்: ${brideRasi.vasiyaRasis.join(", ")})',
        boyDetail: groomRasi.tamilName,
      ));
    }

    // -------------------------------------------------------------
    // 9. ரஜ்ஜு (Rajju Porutham) - மாங்கல்ய பலம் (CRITICAL!)
    // -------------------------------------------------------------
    bool rajjuOk = false;
    {
      final bR = brideStar.rajju;
      final gR = groomStar.rajju;
      double pt = 0.0;
      String status = 'பொருந்தாது';
      String desc = '';

      if (bR != gR) {
        rajjuOk = true;
        pt = 1.0;
        status = 'உத்தமம்';
        desc = 'இருவருக்கும் வெவ்வேறு ரஜ்ஜு (பெண்: $bR, ஆண்: $gR) - மிகச் சிறந்த மாங்கல்ய பலம், தீர்க்க சுமங்கலி பாக்கியம்.';
      } else {
        rajjuOk = false;
        pt = 0.0;
        status = 'பொருந்தாது';
        desc = 'இருவருக்கும் ஒரே ரஜ்ஜு ($bR ரஜ்ஜு) - ரஜ்ஜு தட்டுகிறது! ஏக ரஜ்ஜு தோஷம்.';
      }

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'rajju',
        number: 9,
        tamilName: 'ரஜ்ஜு (Rajju) ★ முக்கியம்',
        englishName: 'Mangalya Strength & Life of Marriage',
        significance: 'தீர்க்க சுமங்கலி யோகம் மற்றும் தம்பதியர் நீண்ட ஆயுள் (அவசிய பொருத்தம்)',
        status: status,
        isMatched: rajjuOk,
        score: pt,
        description: desc,
        girlDetail: '$bR ரஜ்ஜு',
        boyDetail: '$gR ரஜ்ஜு',
      ));
    }

    // -------------------------------------------------------------
    // 10. வேதை (Vedhai Porutham) - துன்பமின்மை
    // -------------------------------------------------------------
    {
      final bool isVedhai = _isVedhaiPair(brideStar.index, groomStar.index);
      bool vedhaiOk = !isVedhai;
      double pt = vedhaiOk ? 1.0 : 0.0;
      String status = vedhaiOk ? 'உத்தமம்' : 'பொருந்தாது';
      String desc = vedhaiOk
          ? 'வேதை தோஷம் இல்லை - குடும்பத்தில் தடையற்ற மகிழ்ச்சி மற்றும் அமைதி.'
          : 'வேதை நக்ஷத்திர சேர்க்கை - சில மனக்கசப்புகள் அல்லது விரயங்கள் வரலாம்.';

      totalPoints += pt;
      items.add(PoruthamItem(
        id: 'vedhai',
        number: 10,
        tamilName: 'வேதை (Vedhai)',
        englishName: 'Affliction-Free Union',
        significance: 'துன்பங்கள் மற்றும் எதிர்ப்புகள் இல்லாத நல்வாழ்வு',
        status: status,
        isMatched: vedhaiOk,
        score: pt,
        description: desc,
        girlDetail: brideStar.tamilName,
        boyDetail: groomStar.tamilName,
      ));
    }

    // Count matched
    final int matchedCount = items.where((i) => i.isMatched).length;

    // Determine final verdict
    String vTitle;
    String vSub;
    Color vCol;
    String summary;

    if (!rajjuOk) {
      vTitle = 'ரஜ்ஜு தட்டுகிறது (தோஷம்)';
      vSub = 'ஏக ரஜ்ஜு உள்ளதால் ஜோதிட ஆலோசனை அவசியம்';
      vCol = const Color(0xFFB91C1C);
      summary =
          'இருவருக்கும் ஒரே ரஜ்ஜு (${brideStar.rajju}) அமைந்துள்ளதால் ரஜ்ஜு பொருத்தம் அமையவில்லை. 10 பொருத்தங்களில் $matchedCount பொருத்தங்கள் கூடி வந்தாலும், ரஜ்ஜு தோஷத்தை அனுபவமிக்க ஜோதிடரிடம் காட்டி ஆலோசனை பெறவும்.';
    } else if (totalPoints >= 7.0) {
      vTitle = 'உத்தம பொருத்தம் (Highly Recommended)';
      vSub = '10-க்கு ${totalPoints.toStringAsFixed(totalPoints % 1 == 0 ? 0 : 1)} பொருத்தங்கள் கூடி வந்துள்ளன';
      vCol = const Color(0xFF1B6B38);
      summary =
          'ரஜ்ஜு பொருத்தம் மற்றும் முக்கிய பஞ்ச மகா பொருத்தங்கள் மிகச் சிறப்பாக பொருந்துகின்றன. தம்பதியர் இடையே மன ஒற்றுமை, வம்ச விருத்தி, ஆயுள் மற்றும் லட்சுமி கடாட்சம் சிறந்து விளங்கும். மனதார மணம் முடிக்கலாம்!';
    } else if (totalPoints >= 5.0) {
      vTitle = 'மத்திம பொருத்தம் (Moderate / Good Match)';
      vSub = '10-க்கு ${totalPoints.toStringAsFixed(totalPoints % 1 == 0 ? 0 : 1)} பொருத்தங்கள் கூடி வந்துள்ளன';
      vCol = const Color(0xFFB45309);
      summary =
          'ரஜ்ஜு பொருத்தம் உள்ளதால் திருமணம் செய்யலாம். சில சாதாரன பொருத்தங்களில் மத்திம பலன் உள்ளதால், இரு குடும்ப பெரியோர்களின் ஆசியுடன் ஜாதக கட்டங்களையும் ஒப்பிட்டு திருமணம் நடத்தலாம்.';
    } else {
      vTitle = 'பொருத்தம் குறைவு (Low Match)';
      vSub = '10-க்கு ${totalPoints.toStringAsFixed(totalPoints % 1 == 0 ? 0 : 1)} மட்டுமே பொருந்துகின்றன';
      vCol = const Color(0xFFC2410C);
      summary =
          '10 பொருத்தங்களில் தேவையான குறைந்தபட்ச பொருத்தங்கள் அமையவில்லை. குடும்ப ஜோதிடரிடம் ஜாதக கட்டங்கள் மற்றும் திசா புக்தி அமைப்பை முழுமையாக ஆராய்ந்து முடிவு செய்வது நலம்.';
    }

    return PoruthamCalculationResult(
      brideStar: brideStar,
      groomStar: groomStar,
      brideRasi: brideRasi,
      groomRasi: groomRasi,
      items: items,
      totalScore: totalPoints,
      matchedCount: matchedCount,
      rajjuOk: rajjuOk,
      verdictTitle: vTitle,
      verdictSubtitle: vSub,
      verdictColor: vCol,
      astrologerSummary: summary,
    );
  }

  // --- Helpers ---

  static bool _isYoniEnemy(String a1, String a2) {
    const enemyPairs = [
      {'குதிரை', 'எருமை'},
      {'யானை', 'சிங்கம்'},
      {'பசு', 'புலி'},
      {'பாம்பு', 'கீரி'},
      {'குரங்கு', 'ஆடு'},
      {'பூனை', 'எலி'},
      {'நாய்', 'மான்'},
    ];
    for (final pair in enemyPairs) {
      if (pair.contains(a1) && pair.contains(a2)) {
        return true;
      }
    }
    return false;
  }

  static bool _arePlanetsFriends(String p1, String p2) {
    const friendGroups = [
      {'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'குரு'},
      {'சுக்கிரன்', 'சனி', 'புதன்'},
    ];
    for (final group in friendGroups) {
      if (group.contains(p1) && group.contains(p2)) return true;
    }
    if ((p1 == 'சந்திரன்' && p2 == 'புதன்') || (p1 == 'புதன்' && p2 == 'சந்திரன்')) {
      return true;
    }
    return false;
  }

  static bool _arePlanetsNeutral(String p1, String p2) {
    if (_arePlanetsFriends(p1, p2)) return false;
    const enemyPairs = [
      {'சூரியன்', 'சனி'},
      {'சூரியன்', 'சுக்கிரன்'},
      {'செவ்வாய்', 'புதன்'},
      {'குரு', 'சுக்கிரன்'},
      {'குரு', 'புதன்'},
      {'சந்திரன்', 'ராகு'},
    ];
    for (final pair in enemyPairs) {
      if (pair.contains(p1) && pair.contains(p2)) return false;
    }
    return true; // Neither friend nor enemy = neutral
  }

  static bool _isVedhaiPair(int i1, int i2) {
    // 12 pairs of Vedhai:
    const pairs = [
      [1, 18], // Aswini - Kettai
      [2, 17], // Bharani - Anusham
      [3, 16], // Krittika - Visakam
      [4, 15], // Rohini - Swathi
      [6, 22], // Thiruvathirai - Thiruvonam
      [7, 21], // Punarpoosam - Uthiradam
      [8, 20], // Poosam - Pooradam
      [9, 19], // Ayilyam - Moolam
      [10, 27], // Magam - Revathi
      [11, 26], // Pooram - Uthirattathi
      [12, 25], // Uthiram - Poorattathi
      [13, 24], // Hastham - Sadhayam
    ];

    for (final pair in pairs) {
      if ((pair[0] == i1 && pair[1] == i2) || (pair[0] == i2 && pair[1] == i1)) {
        return true;
      }
    }

    // Mars stars (Mrigasheersham 5, Chithirai 14, Avittam 23) are mutually Vedhai
    const marsStars = [5, 14, 23];
    if (marsStars.contains(i1) && marsStars.contains(i2) && i1 != i2) {
      return true;
    }

    return false;
  }
}
