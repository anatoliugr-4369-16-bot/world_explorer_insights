class PinnedCountry {
  final String countryCode;
  final String countryName;
  final String flagUrl;
  final String explorerNote;
  final DateTime pinnedDate;

  PinnedCountry({
    required this.countryCode,
    required this.countryName,
    required this.flagUrl,
    required this.explorerNote,
    required this.pinnedDate,
  });

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'countryName': countryName,
        'flagUrl': flagUrl,
        'explorerNote': explorerNote,
        'pinnedDate': pinnedDate.toIso8601String(),
      };

  factory PinnedCountry.fromJson(Map<String, dynamic> json) => PinnedCountry(
        countryCode: json['countryCode'],
        countryName: json['countryName'],
        flagUrl: json['flagUrl'],
        explorerNote: json['explorerNote'],
        pinnedDate: DateTime.parse(json['pinnedDate']),
      );
}
