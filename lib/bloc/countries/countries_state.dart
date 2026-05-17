import '../../models/country.dart';

abstract class CountriesState {}

class CountriesInitial extends CountriesState {}

class CountriesLoading extends CountriesState {}

class CountriesLoaded extends CountriesState {
  final List<Country> allCountries;
  final List<Country> filteredCountries;
  final String? activeSearch;
  final String? activeRegion;
  final String? sortBy;
  final bool ascending;

  CountriesLoaded({
    required this.allCountries,
    required this.filteredCountries,
    this.activeSearch,
    this.activeRegion,
    this.sortBy,
    this.ascending = true,
  });
}

class CountriesError extends CountriesState {
  final String message;
  CountriesError(this.message);
}
