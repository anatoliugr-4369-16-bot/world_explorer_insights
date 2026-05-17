import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_explorer_insights/models/country.dart'; // ADD THIS IMPORT
import 'package:world_explorer_insights/services/country_repository.dart';
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

  List<Country> _applyFiltersAndSort(
    List<Country> all,
    String? search,
    String? region,
    String? sortBy,
    bool ascending,
  ) {
    List<Country> result = List.from(all);
    // Filter by search (case-insensitive)
    if (search != null && search.isNotEmpty) {
      result = result
          .where(
            (c) =>
                c.name.toLowerCase().contains(search.toLowerCase()) ||
                c.capital.toLowerCase().contains(search.toLowerCase()),
          )
          .toList();
    }
    // Filter by region
    if (region != null && region != 'All') {
      result = result.where((c) => c.region == region).toList();
    }
    // Sort – safe because all fields are non‑null in Country model
    if (sortBy != null) {
      switch (sortBy) {
        case 'population':
          result.sort(
            (a, b) => ascending
                ? a.population.compareTo(b.population)
                : b.population.compareTo(a.population),
          );
          break;
        case 'area':
          result.sort(
            (a, b) =>
                ascending ? a.area.compareTo(b.area) : b.area.compareTo(a.area),
          );
          break;
        case 'name':
          result.sort(
            (a, b) =>
                ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
          );
          break;
      }
    }
    return result;
  }

  void _onFetch(FetchCountries event, Emitter<CountriesState> emit) async {
    emit(CountriesLoading());
    try {
      final countries = await repository.getCountries();
      emit(
        CountriesLoaded(allCountries: countries, filteredCountries: countries),
      );
    } catch (e) {
      emit(CountriesError(e.toString()));
    }
  }

  void _onSearch(SearchCountries event, Emitter<CountriesState> emit) {
    if (state is CountriesLoaded) {
      final loaded = state as CountriesLoaded;
      final newFiltered = _applyFiltersAndSort(
        loaded.allCountries,
        event.query.isEmpty ? null : event.query,
        loaded.activeRegion,
        loaded.sortBy,
        loaded.ascending,
      );
      emit(
        CountriesLoaded(
          allCountries: loaded.allCountries,
          filteredCountries: newFiltered,
          activeSearch: event.query.isEmpty ? null : event.query,
          activeRegion: loaded.activeRegion,
          sortBy: loaded.sortBy,
          ascending: loaded.ascending,
        ),
      );
    }
  }

  void _onFilter(FilterByRegion event, Emitter<CountriesState> emit) {
    if (state is CountriesLoaded) {
      final loaded = state as CountriesLoaded;
      final region = event.region == 'All' ? null : event.region;
      final newFiltered = _applyFiltersAndSort(
        loaded.allCountries,
        loaded.activeSearch,
        region,
        loaded.sortBy,
        loaded.ascending,
      );
      emit(
        CountriesLoaded(
          allCountries: loaded.allCountries,
          filteredCountries: newFiltered,
          activeSearch: loaded.activeSearch,
          activeRegion: region,
          sortBy: loaded.sortBy,
          ascending: loaded.ascending,
        ),
      );
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
        event.ascending,
      );
      emit(
        CountriesLoaded(
          allCountries: loaded.allCountries,
          filteredCountries: newFiltered,
          activeSearch: loaded.activeSearch,
          activeRegion: loaded.activeRegion,
          sortBy: event.sortBy,
          ascending: event.ascending,
        ),
      );
    }
  }
}
