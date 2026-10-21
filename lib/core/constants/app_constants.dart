import 'package:latlong2/latlong.dart';

/// Core application constants and API configuration
class AppConstants {
  AppConstants._();

  static const String appName = 'OmniMap';
  static const String appVersion = '1.0.0';
  static const String userAgentPackage = 'com.example.curious_hopper.omnimap';

  // Default coordinate (Dhaka Central / Gulshan - lively city center)
  static const LatLng defaultLocation = LatLng(23.7925, 90.4078);
  static const double defaultZoom = 14.5;
  static const double minZoom = 3.0;
  static const double maxZoom = 19.0;

  // Preset quick-switch cities for fast exploration & demonstration
  static final List<CityPreset> presetCities = [
    CityPreset(
      name: 'Dhaka',
      country: 'Bangladesh',
      location: const LatLng(23.8103, 90.4125),
      description: 'Capital of Bangladesh',
    ),
    CityPreset(
      name: 'Chittagong',
      country: 'Bangladesh',
      location: const LatLng(22.3569, 91.7832),
      description: 'Port City of Bangladesh',
    ),
    CityPreset(
      name: 'Sylhet',
      country: 'Bangladesh',
      location: const LatLng(24.8949, 91.8687),
      description: 'City of Tea Gardens',
    ),
    CityPreset(
      name: 'Tokyo',
      country: 'Japan',
      location: const LatLng(35.6762, 139.6503),
      description: 'Metropolis of Tokyo',
    ),
    CityPreset(
      name: 'London',
      country: 'United Kingdom',
      location: const LatLng(51.5074, -0.1278),
      description: 'Historic Capital of UK',
    ),
    CityPreset(
      name: 'New York',
      country: 'USA',
      location: const LatLng(40.7128, -74.0060),
      description: 'The Big Apple',
    ),
    CityPreset(
      name: 'Paris',
      country: 'France',
      location: const LatLng(48.8566, 2.3522),
      description: 'City of Light',
    ),
  ];

  // API Endpoints
  static const String photonSearchUrl = 'https://photon.komoot.io/api/';
  static const String nominatimSearchUrl = 'https://nominatim.openstreetmap.org/search';
  static const String nominatimReverseUrl = 'https://nominatim.openstreetmap.org/reverse';
  static const String osrmRouteUrl = 'https://router.project-osrm.org/route/v1';

  // Local storage keys
  static const String keySavedPlaces = 'omnimap_saved_places_v1';
  static const String keySearchHistory = 'omnimap_search_history_v1';
  static const String keyMapStyle = 'omnimap_selected_style_v1';
  static const String keyDarkMode = 'omnimap_dark_mode_v1';
}

class CityPreset {
  final String name;
  final String country;
  final LatLng location;
  final String description;

  const CityPreset({
    required this.name,
    required this.country,
    required this.location,
    required this.description,
  });
}
