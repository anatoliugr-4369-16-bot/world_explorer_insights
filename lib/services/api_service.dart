import 'package:dio/dio.dart';
import '../models/country.dart';

class ApiService {
  static const String baseUrl = 'https://restcountries.com/v3.1';
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Country>> fetchAllCountries() async {
    try {
      final response = await _dio.get('$baseUrl/all');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries');
      }
    } on DioException catch (e) {
      // Changed from DioError
      throw Exception('Network error: ${e.message}');
    }
  }
}
