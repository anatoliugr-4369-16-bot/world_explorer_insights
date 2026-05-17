import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_explorer_insights/bloc/countries/countries_bloc.dart';
import 'package:world_explorer_insights/bloc/pins/pins_bloc.dart';
import 'package:world_explorer_insights/core/themes/app_theme.dart';
import 'package:world_explorer_insights/screens/splash_screen.dart';
import 'package:world_explorer_insights/services/country_repository.dart';
import 'package:world_explorer_insights/services/pins_storage_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/explorer_board_screen.dart';
import 'screens/country_detail_screen.dart';
import 'models/country.dart';

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
          create: (context) => CountriesBloc(repository: CountryRepository()),
        ),
        BlocProvider(
          create: (context) => PinsBloc(storage: PinsStorageService()),
        ),
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
            final country = settings.arguments as Country;
            return MaterialPageRoute(
              builder: (context) => CountryDetailScreen(country: country),
            );
          }
          return null;
        },
      ),
    );
  }
}
