import '../models/country.dart';
import 'api_service.dart';

class CountryRepository {
  final ApiService _apiService = ApiService();

  Future<List<Country>> getCountries() async {
    return await _apiService.fetchAllCountries();
  }
}
