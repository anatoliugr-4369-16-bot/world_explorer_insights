import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/country.dart';
import '../../services/country_repository.dart';
import 'countries_event.dart';
import 'countries_state.dart';

class CountriesBloc extends Bloc<CountriesEvent, CountriesState> {
  final CountryRepository repository;

  CountriesBloc({required this.repository}) : super(CountriesInitial()) {
    on<FetchCountries>(_onFetch);
    on<SearchCountries>(_onSearch);
    on<FilterByRegion>(_onFilter);
    on<SortCountries>(_onSort);
  }

  List<Country> _applyFiltersAndSort(List<Country> all, String? search,
      String? region, String? sortBy, bool ascending) {
    List<Country> result = List.from(all);
    if (search != null && search.isNotEmpty) {
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(search.toLowerCase()) ||
              c.capital.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    if (region != null && region != 'All') {
      result = result.where((c) => c.region == region).toList();
    }
    if (sortBy != null) {
      switch (sortBy) {
        case 'population':
          result.sort((a, b) => ascending
              ? a.population.compareTo(b.population)
              : b.population.compareTo(a.population));
          break;
        case 'area':
          result.sort((a, b) =>
              ascending ? a.area.compareTo(b.area) : b.area.compareTo(a.area));
          break;
        case 'name':
          result.sort((a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
          break;
      }
    }
    return result;
  }

  void _onFetch(FetchCountries event, Emitter<CountriesState> emit) async {
    emit(CountriesLoading());
    try {
      final countries = await repository.getCountries();
      final rankedCountries = _computeRanks(countries);
      emit(CountriesLoaded(
        allCountries: rankedCountries,
        filteredCountries: rankedCountries,
      ));
    } catch (e) {
      emit(CountriesError(e.toString()));
    }
  }

  List<Country> _computeRanks(List<Country> countries) {
    // World ranks
    final sortedByPopulation = List<Country>.from(countries)
      ..sort((a, b) => b.population.compareTo(a.population));
    final sortedByArea = List<Country>.from(countries)
      ..sort((a, b) => b.area.compareTo(a.area));
    final sortedByDensity = List<Country>.from(countries)
      ..sort((a, b) => b.populationDensity.compareTo(a.populationDensity));

    // Map country name to rank
    Map<String, int> popRank = {};
    Map<String, int> areaRank = {};
    Map<String, int> densityRank = {};
    for (int i = 0; i < sortedByPopulation.length; i++) {
      popRank[sortedByPopulation[i].name] = i + 1;
    }
    for (int i = 0; i < sortedByArea.length; i++) {
      areaRank[sortedByArea[i].name] = i + 1;
    }
    for (int i = 0; i < sortedByDensity.length; i++) {
      densityRank[sortedByDensity[i].name] = i + 1;
    }

    // Regional ranks
    final regions = countries.map((c) => c.region).toSet();
    Map<String, Map<String, int>> regionalPopRank = {};
    Map<String, Map<String, int>> regionalAreaRank = {};

    for (String region in regions) {
      final regionCountries =
          countries.where((c) => c.region == region).toList();
      final regSortedByPop = List<Country>.from(regionCountries)
        ..sort((a, b) => b.population.compareTo(a.population));
      final regSortedByArea = List<Country>.from(regionCountries)
        ..sort((a, b) => b.area.compareTo(a.area));
      Map<String, int> regPop = {};
      Map<String, int> regArea = {};
      for (int i = 0; i < regSortedByPop.length; i++) {
        regPop[regSortedByPop[i].name] = i + 1;
      }
      for (int i = 0; i < regSortedByArea.length; i++) {
        regArea[regSortedByArea[i].name] = i + 1;
      }
      regionalPopRank[region] = regPop;
      regionalAreaRank[region] = regArea;
    }

    // Assign ranks to each country
    for (var country in countries) {
      country.populationRank = popRank[country.name];
      country.areaRank = areaRank[country.name];
      country.densityRank = densityRank[country.name];
      country.regionalPopulationRank =
          regionalPopRank[country.region]?[country.name];
      country.regionalAreaRank =
          regionalAreaRank[country.region]?[country.name];
    }
    return countries;
  }

  void _onSearch(SearchCountries event, Emitter<CountriesState> emit) {
    if (state is CountriesLoaded) {
      final loaded = state as CountriesLoaded;
      final newFiltered = _applyFiltersAndSort(
          loaded.allCountries,
          event.query.isEmpty ? null : event.query,
          loaded.activeRegion,
          loaded.sortBy,
          loaded.ascending);
      emit(CountriesLoaded(
        allCountries: loaded.allCountries,
        filteredCountries: newFiltered,
        activeSearch: event.query.isEmpty ? null : event.query,
        activeRegion: loaded.activeRegion,
        sortBy: loaded.sortBy,
        ascending: loaded.ascending,
      ));
    }
  }

  void _onFilter(FilterByRegion event, Emitter<CountriesState> emit) {
    if (state is CountriesLoaded) {
      final loaded = state as CountriesLoaded;
      final region = event.region == 'All' ? null : event.region;
      final newFiltered = _applyFiltersAndSort(loaded.allCountries,
          loaded.activeSearch, region, loaded.sortBy, loaded.ascending);
      emit(CountriesLoaded(
        allCountries: loaded.allCountries,
        filteredCountries: newFiltered,
        activeSearch: loaded.activeSearch,
        activeRegion: region,
        sortBy: loaded.sortBy,
        ascending: loaded.ascending,
      ));
    }
  }

  void _onSort(SortCountries event, Emitter<CountriesState> emit) {
    if (state is CountriesLoaded) {
      final loaded = state as CountriesLoaded;
      final newFiltered = _applyFiltersAndSort(
          loaded.allCountries,
          loaded.activeSearch,
          loaded.activeRegion,
          event.sortBy,
          event.ascending);
      emit(CountriesLoaded(
        allCountries: loaded.allCountries,
        filteredCountries: newFiltered,
        activeSearch: loaded.activeSearch,
        activeRegion: loaded.activeRegion,
        sortBy: event.sortBy,
        ascending: event.ascending,
      ));
    }
  }
}
