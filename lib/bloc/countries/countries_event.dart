abstract class CountriesEvent {}

class FetchCountries extends CountriesEvent {}

class SearchCountries extends CountriesEvent {
  final String query;
  SearchCountries(this.query);
}

class FilterByRegion extends CountriesEvent {
  final String region;
  FilterByRegion(this.region);
}

class SortCountries extends CountriesEvent {
  final String sortBy; // 'population', 'area', 'name'
  final bool ascending;
  SortCountries(this.sortBy, this.ascending);
}
