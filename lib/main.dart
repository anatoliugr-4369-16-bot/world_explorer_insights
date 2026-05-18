import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/countries/countries_bloc.dart';
import 'bloc/pins/pins_bloc.dart';
import 'core/themes/app_theme.dart';
import 'models/country.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/explorer_board_screen.dart';
import 'screens/country_intelligence_page.dart.dart';
import 'services/country_repository.dart';
import 'services/pins_storage_service.dart';

void main() {
  runApp(const WorldExplorerApp());
}

class WorldExplorerApp extends StatelessWidget {
  const WorldExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                CountriesBloc(repository: CountryRepository())),
        BlocProvider(
            create: (context) => PinsBloc(storage: PinsStorageService())),
      ],
      child: MaterialApp(
        title: 'World Explorer Insights',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/explore': (context) => const ExploreScreen(),
          '/explorer_board': (context) => const ExplorerBoardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/country_detail') {
            final args = settings.arguments as Map<String, dynamic>;
            final country = args['country'] as Country;
            final allCountries = args['allCountries'] as List<Country>;
            return MaterialPageRoute(
              builder: (context) => CountryIntelligencePage(
                country: country,
                allCountries: allCountries,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
