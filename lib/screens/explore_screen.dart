import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/countries/countries_bloc.dart';
import '../bloc/countries/countries_event.dart';
import '../bloc/countries/countries_state.dart';
import '../core/themes/app_theme.dart';
import '../models/country.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All';
  String _selectedSort = 'name';
  bool _isAscending = true;

  final List<String> _regions = [
    'All',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania'
  ];
  final List<String> _sortOptions = ['name', 'population', 'area'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CountriesBloc>().add(SearchCountries(_searchController.text));
  }

  void _onRegionChanged(String? region) {
    if (region != null) {
      setState(() => _selectedRegion = region);
      context.read<CountriesBloc>().add(FilterByRegion(region));
    }
  }

  void _onSortChanged(String? sortBy) {
    if (sortBy != null) {
      setState(() {
        if (_selectedSort == sortBy) {
          _isAscending = !_isAscending;
        } else {
          _selectedSort = sortBy;
          _isAscending = true;
        }
      });
      context
          .read<CountriesBloc>()
          .add(SortCountries(_selectedSort, _isAscending));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Countries'),
        backgroundColor: AppTheme.deepForest,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search country or capital...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRegion,
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                          value: region, child: Text(region));
                    }).toList(),
                    onChanged: _onRegionChanged,
                    decoration: InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSort,
                    items: _sortOptions.map((sort) {
                      String label = sort[0].toUpperCase() + sort.substring(1);
                      return DropdownMenuItem(value: sort, child: Text(label));
                    }).toList(),
                    onChanged: _onSortChanged,
                    decoration: InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => _onSortChanged(_selectedSort),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<CountriesBloc, CountriesState>(
              builder: (context, state) {
                if (state is CountriesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CountriesError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is CountriesLoaded) {
                  final countries = state.filteredCountries;
                  if (countries.isEmpty) {
                    return const Center(child: Text('No countries match'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      return _buildCountryCard(country);
                    },
                  );
                }
                return const Center(child: Text('Pull to refresh'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCard(Country country) {
    return GestureDetector(
      onTap: () {
        final state = context.read<CountriesBloc>().state;
        if (state is CountriesLoaded) {
          Navigator.pushNamed(
            context,
            '/country_detail',
            arguments: {
              'country': country,
              'allCountries': state.allCountries,
            },
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  color: AppTheme.mutedBeige,
                  child: Image.network(
                    country.flagUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flag, size: 50),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      country.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.capital,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${(country.population / 1e6).toStringAsFixed(1)}M',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.map, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          country.region,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
