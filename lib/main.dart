import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_explorer_insights/bloc/countries/countries_bloc.dart';
import 'package:world_explorer_insights/core/themes/app_theme.dart';
import 'package:world_explorer_insights/screens/splash_screen.dart';
import 'package:world_explorer_insights/services/country_repository.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const WorldExplorerApp());
}

class WorldExplorerApp extends StatelessWidget {
  const WorldExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Explorer Insights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/dashboard': (context) => BlocProvider(
          create: (context) => CountriesBloc(repository: CountryRepository()),
          child: const DashboardScreen(),
        ),
      },
    );
  }
}
