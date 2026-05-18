import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/country.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'User-Agent': 'WorldExplorerInsights/1.0',
    },
  ));

  Future<List<Country>> fetchAllCountries() async {
    try {
      // Maximum 10 fields allowed by the API
      const fields =
          'name,capital,region,subregion,population,area,flags,languages,latlng';

      final url = 'https://restcountries.com/v3.1/all?fields=$fields';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data is List) {
        final List<Country> countries = [];
        for (var json in response.data) {
          try {
            countries.add(Country.fromJson(json));
          } catch (e) {
            print('Parse error: $e');
          }
        }
        print('Loaded ${countries.length} countries');
        return countries;
      } else {
        throw Exception('API returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
