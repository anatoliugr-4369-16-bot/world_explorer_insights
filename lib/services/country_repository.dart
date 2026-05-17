import 'package:world_explorer_insights/models/country.dart';
import 'api_service.dart';

class CountryRepository {
  final ApiService _apiService = ApiService();

  Future<List<Country>> getCountries() => _apiService.fetchAllCountries();
}
