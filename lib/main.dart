import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/services/geocoding_service.dart';
import 'data/services/routing_service.dart';
import 'data/services/storage_service.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/state/map_state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Services
  final storageService = await StorageService.initialize();
  final geocodingService = GeocodingService();
  final routingService = RoutingService();

  // Initialize Global State
  final stateManager = MapStateManager(
    geocodingService: geocodingService,
    routingService: routingService,
    storageService: storageService,
  );

  runApp(OmniMapApp(stateManager: stateManager));
}

class OmniMapApp extends StatelessWidget {
  final MapStateManager stateManager;

  const OmniMapApp({super.key, required this.stateManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stateManager,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: stateManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MapScreen(state: stateManager),
        );
      },
    );
  }
}
