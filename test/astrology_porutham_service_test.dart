import 'package:flutter_test/flutter_test.dart';
import 'package:matrimony_app/services/astrology_porutham_service.dart';

void main() {
  group('AstrologyPoruthamService Tests', () {
    test('Correctly identifies all 27 Nakshatras and 12 Rasis', () {
      expect(AstrologyPoruthamService.nakshatras.length, 27);
      expect(AstrologyPoruthamService.rasis.length, 12);
    });

    test('Fuzzy star matching handles Tamil and English formats', () {
      final rohini = AstrologyPoruthamService.findStar("ரோகிணி (Rohini)");
      expect(rohini.index, 4);
      expect(rohini.tamilName, "ரோகிணி");

      final uthiram = AstrologyPoruthamService.findStar("உத்திரம்");
      expect(uthiram.index, 12);

      final aswini = AstrologyPoruthamService.findStar("Aswini");
      expect(aswini.index, 1);
    });

    test('Fuzzy rasi matching handles Tamil and English formats', () {
      final rishabam = AstrologyPoruthamService.findRasi("ரிஷபம் (Rishabham)");
      expect(rishabam.index, 2);

      final simham = AstrologyPoruthamService.findRasi("சிம்மம் (Simmam)");
      expect(simham.index, 5);
    });

    test('Calculates 10 Poruthams with different Rajju successfully', () {
      final brideStar = AstrologyPoruthamService.nakshatras[3]; // Rohini (Kanda Rajju)
      final groomStar = AstrologyPoruthamService.nakshatras[11]; // Uthiram (Udhara Rajju)
      final brideRasi = AstrologyPoruthamService.rasis[1]; // Rishabam
      final groomRasi = AstrologyPoruthamService.rasis[4]; // Simham

      final result = AstrologyPoruthamService.calculate10Poruthams(
        brideStar: brideStar,
        groomStar: groomStar,
        brideRasi: brideRasi,
        groomRasi: groomRasi,
      );

      expect(result.items.length, 10);
      expect(result.rajjuOk, isTrue);
      expect(result.totalScore, greaterThanOrEqualTo(5.0));

      final rajjuItem = result.items.firstWhere((i) => i.id == 'rajju');
      expect(rajjuItem.isMatched, isTrue);
      expect(rajjuItem.status, 'உத்தமம்');
    });

    test('Detects same Rajju (Rajju Dosham) correctly', () {
      // Mrigasheersham (5) and Chithirai (14) are both Sirasu Rajju
      final brideStar = AstrologyPoruthamService.nakshatras[4]; // Mrigasheersham
      final groomStar = AstrologyPoruthamService.nakshatras[13]; // Chithirai
      final brideRasi = AstrologyPoruthamService.rasis[2]; // Mithunam
      final groomRasi = AstrologyPoruthamService.rasis[5]; // Kanni

      final result = AstrologyPoruthamService.calculate10Poruthams(
        brideStar: brideStar,
        groomStar: groomStar,
        brideRasi: brideRasi,
        groomRasi: groomRasi,
      );

      expect(result.rajjuOk, isFalse);
      expect(result.verdictTitle, contains('ரஜ்ஜு'));
      final rajjuItem = result.items.firstWhere((i) => i.id == 'rajju');
      expect(rajjuItem.isMatched, isFalse);
      expect(rajjuItem.status, 'பொருந்தாது');
    });

    test('Detects Vedhai pair correctly', () {
      // Aswini (1) and Kettai (18) are Vedhai
      final brideStar = AstrologyPoruthamService.nakshatras[0]; // Aswini
      final groomStar = AstrologyPoruthamService.nakshatras[17]; // Kettai
      final brideRasi = AstrologyPoruthamService.rasis[0];
      final groomRasi = AstrologyPoruthamService.rasis[7];

      final result = AstrologyPoruthamService.calculate10Poruthams(
        brideStar: brideStar,
        groomStar: groomStar,
        brideRasi: brideRasi,
        groomRasi: groomRasi,
      );

      final vedhaiItem = result.items.firstWhere((i) => i.id == 'vedhai');
      expect(vedhaiItem.isMatched, isFalse);
      expect(vedhaiItem.status, 'பொருந்தாது');
    });
  });
}
