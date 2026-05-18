class Country {
  final String name;
  final String nativeName;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final double area;
  final double populationDensity;
  final String flagUrl;
  final List<String> languages;
  final List<String> currencies;
  final List<String> borders;
  final List<String> timezones;
  final List<double> latlng;
  final String mapsUrl;

  int? populationRank;
  int? areaRank;
  int? densityRank;
  int? regionalPopulationRank;
  int? regionalAreaRank;

  Country({
    required this.name,
    required this.nativeName,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.populationDensity,
    required this.flagUrl,
    required this.languages,
    required this.currencies,
    required this.borders,
    required this.timezones,
    required this.latlng,
    required this.mapsUrl,
    this.populationRank,
    this.areaRank,
    this.densityRank,
    this.regionalPopulationRank,
    this.regionalAreaRank,
  });

  // Factory for v3.1 API (used in your api_service.dart)
  factory Country.fromJson(Map<String, dynamic> json) {
    // Parse languages
    List<String> langs = [];
    if (json['languages'] != null) {
      langs = (json['languages'] as Map<String, dynamic>)
          .values
          .map((v) => v.toString())
          .toList();
    }
    // Parse currencies
    List<String> curr = [];
    if (json['currencies'] != null) {
      curr = (json['currencies'] as Map<String, dynamic>)
          .values
          .map((v) => (v as Map<String, dynamic>)['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    }
    // Borders
    List<String> bordersList =
        (json['borders'] as List?)?.map((b) => b.toString()).toList() ?? [];
    // Timezones
    List<String> timezonesList =
        (json['timezones'] as List?)?.map((t) => t.toString()).toList() ?? [];
    // Latlng
    List<double> latlngList = [];
    if (json['latlng'] != null &&
        json['latlng'] is List &&
        (json['latlng'] as List).length >= 2) {
      latlngList = [
        (json['latlng'][0] as num).toDouble(),
        (json['latlng'][1] as num).toDouble()
      ];
    }
    // Maps URL
    String maps = json['maps']?['googleMaps'] ?? '';
    // Native name
    String native = 'Unknown';
    if (json['name']?['nativeName'] != null) {
      final nativeObj = json['name']['nativeName'] as Map<String, dynamic>;
      if (nativeObj.isNotEmpty) {
        native = nativeObj.values.first['common'] ?? 'Unknown';
      }
    }

    double density =
        json['population'] != null && json['area'] != null && json['area'] > 0
            ? (json['population'] / json['area'])
            : 0.0;

    return Country(
      name: json['name']['common'] ?? 'Unknown',
      nativeName: native,
      capital: (json['capital'] as List?)?.isNotEmpty == true
          ? json['capital'][0]
          : 'No capital',
      region: json['region'] ?? 'Unknown',
      subregion: json['subregion'] ?? 'Unknown',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      populationDensity: density,
      flagUrl: json['flags']?['png'] ?? '',
      languages: langs,
      currencies: curr,
      borders: bordersList,
      timezones: timezonesList,
      latlng: latlngList,
      mapsUrl: maps,
    );
  }

  // Factory for v2 API (fallback)
  factory Country.fromJsonV2(Map<String, dynamic> json) {
    // Parse languages
    List<String> langs = [];
    if (json['languages'] != null) {
      if (json['languages'] is List) {
        langs = (json['languages'] as List).map((l) => l.toString()).toList();
      } else if (json['languages'] is Map) {
        langs = (json['languages'] as Map<String, dynamic>)
            .values
            .map((v) => v.toString())
            .toList();
      }
    }
    // Parse currencies
    List<String> curr = [];
    if (json['currencies'] != null) {
      if (json['currencies'] is List) {
        curr = (json['currencies'] as List).map((c) => c.toString()).toList();
      } else if (json['currencies'] is Map) {
        curr = (json['currencies'] as Map<String, dynamic>)
            .values
            .map((v) => v['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
      }
    }
    // Borders
    List<String> bordersList =
        (json['borders'] as List?)?.map((b) => b.toString()).toList() ?? [];
    // Timezones
    List<String> timezonesList =
        (json['timezones'] as List?)?.map((t) => t.toString()).toList() ?? [];
    // Latlng
    List<double> latlngList = [];
    if (json['latlng'] != null &&
        json['latlng'] is List &&
        (json['latlng'] as List).length >= 2) {
      latlngList = [
        (json['latlng'][0] as num).toDouble(),
        (json['latlng'][1] as num).toDouble()
      ];
    }
    // Native name
    String native = json['nativeName'] ?? json['name'] ?? 'Unknown';
    if (json['nativeName'] is Map) {
      final nativeMap = json['nativeName'] as Map<String, dynamic>;
      if (nativeMap.isNotEmpty) {
        native = nativeMap.values.first['common'] ??
            nativeMap.values.first.toString();
      }
    }
    double density =
        json['population'] != null && json['area'] != null && json['area'] > 0
            ? (json['population'] / json['area'])
            : 0.0;

    return Country(
      name: json['name'] ?? 'Unknown',
      nativeName: native,
      capital: json['capital'] ?? 'No capital',
      region: json['region'] ?? 'Unknown',
      subregion: json['subregion'] ?? 'Unknown',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      populationDensity: density,
      flagUrl: json['flag'] ?? json['flags']?['png'] ?? '',
      languages: langs,
      currencies: curr,
      borders: bordersList,
      timezones: timezonesList,
      latlng: latlngList,
      mapsUrl: json['maps']?['googleMaps'] ?? '',
    );
  }
}
