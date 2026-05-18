import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/countries/countries_bloc.dart';
import '../bloc/countries/countries_event.dart';
import '../bloc/countries/countries_state.dart';
import '../bloc/pins/pins_bloc.dart';
import '../bloc/pins/pins_event.dart';
import '../core/themes/app_theme.dart';
import '../models/country.dart';
import '../widgets/stat_card.dart';
import '../widgets/ranking_tile.dart';
import '../widgets/region_insight_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final CountriesBloc _countriesBloc;
  late final PinsBloc _pinsBloc;
  Country? _spotlight;

  @override
  void initState() {
    super.initState();
    _countriesBloc = context.read<CountriesBloc>();
    _pinsBloc = context.read<PinsBloc>();
    _countriesBloc.add(FetchCountries());
    _pinsBloc.add(LoadPins());
  }

  void _selectRandomSpotlight(List<Country> countries) {
    if (countries.isNotEmpty && mounted) {
      final random = Random();
      setState(() {
        _spotlight = countries[random.nextInt(countries.length)];
      });
    }
  }

  void _refreshDashboard() {
    _countriesBloc.add(FetchCountries());
  }

  void _navigateToCountry(Country country, List<Country> allCountries) {
    Navigator.pushNamed(
      context,
      '/country_detail',
      arguments: {
        'country': country,
        'allCountries': allCountries,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin),
            onPressed: () => Navigator.pushNamed(context, '/explorer_board'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/explore'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshDashboard();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: BlocBuilder<CountriesBloc, CountriesState>(
          builder: (context, state) {
            if (state is CountriesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CountriesError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is CountriesLoaded) {
              final countries = state.filteredCountries;
              if (countries.isEmpty) {
                return const Center(child: Text('No countries found'));
              }

              // Set spotlight after build is complete
              if (_spotlight == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _selectRandomSpotlight(countries);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return _buildDashboard(countries);
            }
            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(List<Country> countries) {
    final totalCountries = countries.length;
    final largestCountry = countries.reduce((a, b) => a.area > b.area ? a : b);
    final mostPopulated =
        countries.reduce((a, b) => a.population > b.population ? a : b);
    final smallestCountry = countries.reduce((a, b) => a.area < b.area ? a : b);
    final totalRegions = countries.map((c) => c.region).toSet().length;
    final spotlight = _spotlight ?? countries.first;

    // Rankings
    final topPopulation = List<Country>.from(countries)
      ..sort((a, b) => b.population.compareTo(a.population));
    final topArea = List<Country>.from(countries)
      ..sort((a, b) => b.area.compareTo(a.area));
    final smallestArea = List<Country>.from(countries)
      ..sort((a, b) => a.area.compareTo(b.area));
    final densityCountries = List<Country>.from(countries)
      ..sort(
          (a, b) => (b.population / b.area).compareTo(a.population / a.area));

    // Region insights
    final regions = {
      'Africa': countries.where((c) => c.region == 'Africa').toList(),
      'Europe': countries.where((c) => c.region == 'Europe').toList(),
      'Asia': countries.where((c) => c.region == 'Asia').toList(),
      'Americas': countries.where((c) => c.region == 'Americas').toList(),
      'Oceania': countries.where((c) => c.region == 'Oceania').toList(),
    };

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              GestureDetector(
                onTap: () => _navigateToCountry(mostPopulated, countries),
                child: StatCard(
                  title: 'Most Populated',
                  value: mostPopulated.name,
                  icon: Icons.people,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToCountry(largestCountry, countries),
                child: StatCard(
                  title: 'Largest Country',
                  value: largestCountry.name,
                  icon: Icons.landscape,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToCountry(smallestCountry, countries),
                child: StatCard(
                  title: 'Smallest Country',
                  value: smallestCountry.name,
                  icon: Icons.crop_square,
                ),
              ),
              StatCard(
                title: 'Total Regions',
                value: '$totalRegions',
                icon: Icons.map,
              ),
              StatCard(
                title: 'Total Countries',
                value: '$totalCountries',
                icon: Icons.public,
              ),
              GestureDetector(
                onTap: () => _navigateToCountry(spotlight, countries),
                child: StatCard(
                  title: 'Spotlight',
                  value: spotlight.name,
                  icon: Icons.star,
                  backgroundColor: AppTheme.antiqueGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('World Rankings',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          _buildRankingSection(
              'Top Population',
              topPopulation.take(5).toList(),
              (c) => '${(c.population / 1e6).toStringAsFixed(1)}M',
              Icons.emoji_events,
              countries),
          const SizedBox(height: 16),
          _buildRankingSection(
              'Largest Area',
              topArea.take(5).toList(),
              (c) => '${(c.area / 1e6).toStringAsFixed(1)}M km²',
              Icons.landscape,
              countries),
          const SizedBox(height: 16),
          _buildRankingSection(
              'Smallest Area',
              smallestArea.take(5).toList(),
              (c) => '${c.area.toStringAsFixed(0)} km²',
              Icons.crop_square,
              countries),
          const SizedBox(height: 16),
          _buildRankingSection(
              'Highest Density',
              densityCountries.take(5).toList(),
              (c) => '${(c.population / c.area).toStringAsFixed(0)}/km²',
              Icons.people,
              countries),
          const SizedBox(height: 24),
          Text('Regional Insights',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: regions.keys.length,
              itemBuilder: (context, index) {
                final regionName = regions.keys.elementAt(index);
                final countryList = regions[regionName]!;
                if (countryList.isEmpty) return const SizedBox.shrink();
                final largest =
                    countryList.reduce((a, b) => a.area > b.area ? a : b);
                final mostPop = countryList
                    .reduce((a, b) => a.population > b.population ? a : b);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RegionInsightCard(
                    regionName: regionName,
                    countryCount: countryList.length,
                    largestCountry: largest.name,
                    mostPopulatedCountry: mostPop.name,
                    accentColor: AppTheme.antiqueGold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Country Spotlight',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          _buildSpotlightCard(spotlight, countries),
          const SizedBox(height: 24),
          Text('Did You Know?',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 12),
          _buildDidYouKnowCard(),
        ],
      ),
    );
  }

  Widget _buildRankingSection(
      String title,
      List<Country> countries,
      String Function(Country) valueFormatter,
      IconData medalIcon,
      List<Country> allCountries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...List.generate(countries.length, (index) {
          return GestureDetector(
            onTap: () => _navigateToCountry(countries[index], allCountries),
            child: RankingTile(
              rank: index + 1,
              flagUrl: countries[index].flagUrl,
              name: countries[index].name,
              value: valueFormatter(countries[index]),
              medalIcon: medalIcon,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSpotlightCard(Country country, List<Country> allCountries) {
    String insight;
    if (country.populationDensity > 500) {
      insight = 'One of the world\'s most densely populated nations.';
    } else if (country.area > 5e6) {
      insight = 'A massive landmass, among the largest countries on Earth.';
    } else if (country.population > 1e8) {
      insight = 'A demographic giant with over 100 million inhabitants.';
    } else {
      insight = 'A country of remarkable geographic and cultural significance.';
    }

    return GestureDetector(
      onTap: () => _navigateToCountry(country, allCountries),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.deepForest, AppTheme.darkOlive],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(country.flagUrl, width: 80, height: 60),
                      const SizedBox(height: 12),
                      Text(country.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(country.capital,
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                          'Population: ${(country.population / 1e6).toStringAsFixed(1)}M • Area: ${(country.area / 1e6).toStringAsFixed(1)}M km²',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppTheme.antiqueGold,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(insight,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDidYouKnowCard() {
    final facts = [
      'Russia spans 11 time zones.',
      'Ethiopia uses a unique 13-month calendar.',
      'Canada has the longest coastline (202,080 km).',
      'France is the most visited country in the world.',
      'Japan has over 6,800 islands.',
      'Australia is both a country and a continent.',
    ];
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.lightbulb, color: AppTheme.antiqueGold, size: 40),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: Center(
                child: _RotatingFactCard(facts: facts),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingFactCard extends StatefulWidget {
  final List<String> facts;
  const _RotatingFactCard({required this.facts});

  @override
  State<_RotatingFactCard> createState() => _RotatingFactCardState();
}

class _RotatingFactCardState extends State<_RotatingFactCard> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _cycle);
  }

  void _cycle() {
    if (!mounted) return;
    setState(() {
      _index = (_index + 1) % widget.facts.length;
    });
    Future.delayed(const Duration(seconds: 5), _cycle);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Text(
        widget.facts[_index],
        key: ValueKey(_index),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
