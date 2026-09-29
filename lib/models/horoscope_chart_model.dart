class HoroscopeHouseMeta {
  final String key;
  final String tamil;
  final String english;
  final int row;
  final int col;

  const HoroscopeHouseMeta({
    required this.key,
    required this.tamil,
    required this.english,
    required this.row,
    required this.col,
  });
}

class HoroscopeChartModel {
  static const List<HoroscopeHouseMeta> houses = [
    HoroscopeHouseMeta(key: 'mesham', tamil: 'மேஷம்', english: 'Mesham', row: 0, col: 1),
    HoroscopeHouseMeta(key: 'rishabam', tamil: 'ரிஷபம்', english: 'Rishabam', row: 0, col: 2),
    HoroscopeHouseMeta(key: 'mithunam', tamil: 'மிதுனம்', english: 'Mithunam', row: 0, col: 3),
    HoroscopeHouseMeta(key: 'kadagam', tamil: 'கடகம்', english: 'Kadagam', row: 1, col: 3),
    HoroscopeHouseMeta(key: 'simmam', tamil: 'சிம்மம்', english: 'Simmam', row: 2, col: 3),
    HoroscopeHouseMeta(key: 'kanni', tamil: 'கன்னி', english: 'Kanni', row: 3, col: 3),
    HoroscopeHouseMeta(key: 'thulam', tamil: 'துலாம்', english: 'Thulam', row: 3, col: 2),
    HoroscopeHouseMeta(key: 'viruchigam', tamil: 'விருச்சிகம்', english: 'Viruchigam', row: 3, col: 1),
    HoroscopeHouseMeta(key: 'dhanusu', tamil: 'தனுசு', english: 'Dhanusu', row: 3, col: 0),
    HoroscopeHouseMeta(key: 'makaram', tamil: 'மகரம்', english: 'Makaram', row: 2, col: 0),
    HoroscopeHouseMeta(key: 'kumbam', tamil: 'கும்பம்', english: 'Kumbam', row: 1, col: 0),
    HoroscopeHouseMeta(key: 'meenam', tamil: 'மீனம்', english: 'Meenam', row: 0, col: 0),
  ];

  static const List<String> standardPlanets = [
    "லக்னம்",
    "சூரியன்",
    "சந்திரன்",
    "செவ்வாய்",
    "புதன்",
    "குரு",
    "சுக்கிரன்",
    "சனி",
    "ராகு",
    "கேது",
  ];

  static Map<String, String> getShudhaRasiTemplate() {
    return {
      'meenam': 'புதன்',
      'mesham': 'லக்னம்',
      'rishabam': 'சந், சு',
      'mithunam': 'சூரியன்',
      'kadagam': 'குரு',
      'simmam': 'சுக்',
      'kanni': '-',
      'thulam': '-',
      'viruchigam': '-',
      'dhanusu': 'கேது',
      'makaram': 'சனி',
      'kumbam': 'செவ்வாய்',
    };
  }

  static Map<String, String> getChevvaiRasiTemplate() {
    return {
      'meenam': 'புதன்',
      'mesham': 'லக்னம்',
      'rishabam': 'சந்திரன்',
      'mithunam': 'சூரியன்',
      'kadagam': 'குரு',
      'simmam': 'ராகு',
      'kanni': '-',
      'thulam': 'செவ்வாய் (7)',
      'viruchigam': '-',
      'dhanusu': 'கேது',
      'makaram': 'சனி',
      'kumbam': 'சுக்கிரன்',
    };
  }

  static Map<String, String> getRahuKetuRasiTemplate() {
    return {
      'meenam': 'புதன்',
      'mesham': 'லக்னம், ராகு',
      'rishabam': 'குரு',
      'mithunam': 'சூரியன்',
      'kadagam': 'சுக்கிரன்',
      'simmam': '-',
      'kanni': '-',
      'thulam': 'கேது (7)',
      'viruchigam': '-',
      'dhanusu': 'செவ்வாய்',
      'makaram': 'சனி',
      'kumbam': 'சந்திரன்',
    };
  }

  static Map<String, String> getStandardNavamsamTemplate() {
    return {
      'meenam': '-',
      'mesham': 'செவ்வாய்',
      'rishabam': 'குரு',
      'mithunam': 'லக்னம்',
      'kadagam': 'புதன்',
      'simmam': 'சந்திரன்',
      'kanni': 'கேது',
      'thulam': '-',
      'viruchigam': 'ராகு',
      'dhanusu': 'சுக்கிரன்',
      'makaram': 'சனி',
      'kumbam': 'சூரியன்',
    };
  }

  static List<List<String>> buildGridMatrix(Map<String, String> chartData) {
    String val(String key, String tamil) {
      final p = chartData[key]?.trim();
      if (p == null || p.isEmpty || p == '-') {
        return "$tamil\n-";
      }
      return "$tamil\n$p";
    }

    return [
      [val('meenam', 'மீனம்'), val('mesham', 'மேஷம்'), val('rishabam', 'ரிஷபம்'), val('mithunam', 'மிதுனம்')],
      [val('kumbam', 'கும்பம்'), '', '', val('kadagam', 'கடகம்')],
      [val('makaram', 'மகரம்'), '', '', val('simmam', 'சிம்மம்')],
      [val('dhanusu', 'தனுசு'), val('viruchigam', 'விருச்சிகம்'), val('thulam', 'துலாம்'), val('kanni', 'கன்னி')],
    ];
  }
}
