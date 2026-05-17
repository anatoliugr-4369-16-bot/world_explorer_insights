import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pinned_country.dart';

class PinsStorageService {
  static const String _pinsKey = 'explorer_pins';

  Future<void> savePins(List<PinnedCountry> pins) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pinsJson = pins
        .map((pin) => jsonEncode(pin.toJson()))
        .toList();
    await prefs.setStringList(_pinsKey, pinsJson);
  }

  Future<List<PinnedCountry>> loadPins() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? pinsJson = prefs.getStringList(_pinsKey);
    if (pinsJson == null) return [];
    return pinsJson
        .map((jsonStr) => PinnedCountry.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
}
