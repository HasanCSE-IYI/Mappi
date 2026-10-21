// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/map_styles.dart';
import '../../core/utils/geo_utils.dart';
import '../../data/models/place_model.dart';
import '../../data/models/route_model.dart';
import '../../data/models/saved_place_model.dart';
import '../../data/services/geocoding_service.dart';
import '../../data/services/routing_service.dart';
import '../../data/services/storage_service.dart';

/// Central reactive state controller for OmniMap
class MapStateManager extends ChangeNotifier {
  final GeocodingService _geocodingService;
  final RoutingService _routingService;
  final StorageService _storageService;

  late final MapController mapController;

  // Location & Map Position
  LatLng _userLocation = AppConstants.defaultLocation;
  double _userHeading = 0.0;
  double _currentZoom = AppConstants.defaultZoom;
  bool _isFollowMode = false;
  MapStyleType _selectedStyle = MapStyleType.streets;
  bool _isDarkMode = false;

  // Search & POI
  String _searchQuery = '';
  bool _isSearching = false;
  List<PlaceModel> _searchResults = [];
  List<String> _searchHistory = [];
  PlaceCategory? _selectedCategory;
  PlaceModel? _selectedPlace;

  // Routing & Travel Mode
  TravelMode _selectedTravelMode = TravelMode.driving;
  RouteModel? _activeRoute;
  bool _isLoadingRoute = false;

  // Turn-by-Turn Navigation & Simulation
  bool _isNavigating = false;
  int _currentNavStepIndex = 0;
  double _navProgress = 0.0; // 0.0 to 1.0
  double _currentSpeedKmh = 42.0;
  Timer? _simulationTimer;

  // Saved Bookmarks
  List<SavedPlaceModel> _savedPlaces = [];

  MapStateManager({
    required GeocodingService geocodingService,
    required RoutingService routingService,
    required StorageService storageService,
  })  : _geocodingService = geocodingService,
        _routingService = routingService,
        _storageService = storageService {
    mapController = MapController();
    _loadInitialState();
  }

  // --- Getters ---
  LatLng get userLocation => _userLocation;
  double get userHeading => _userHeading;
  double get currentZoom => _currentZoom;
  bool get isFollowMode => _isFollowMode;
  MapStyleType get selectedStyle => _selectedStyle;
  MapStyleDefinition get activeStyleDefinition => MapStyles.getStyle(_selectedStyle);
  bool get isDarkMode => _isDarkMode;

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<PlaceModel> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  PlaceCategory? get selectedCategory => _selectedCategory;
  PlaceModel? get selectedPlace => _selectedPlace;

  TravelMode get selectedTravelMode => _selectedTravelMode;
  RouteModel? get activeRoute => _activeRoute;
  bool get isLoadingRoute => _isLoadingRoute;

  bool get isNavigating => _isNavigating;
  int get currentNavStepIndex => _currentNavStepIndex;
  double get navProgress => _navProgress;
  double get currentSpeedKmh => _currentSpeedKmh;
  RouteStep? get currentNavStep {
    if (_activeRoute == null || _activeRoute!.steps.isEmpty) return null;
    if (_currentNavStepIndex >= _activeRoute!.steps.length) {
      return _activeRoute!.steps.last;
    }
    return _activeRoute!.steps[_currentNavStepIndex];
  }

  List<SavedPlaceModel> get savedPlaces => _savedPlaces;

  // --- Initialization ---
  void _loadInitialState() {
    _selectedStyle = _storageService.getSelectedStyle();
    _isDarkMode = _storageService.isDarkMode();
    _savedPlaces = _storageService.getSavedPlaces();
    _searchHistory = _storageService.getSearchHistory();
    notifyListeners();
  }

  // --- Map Camera Controls ---
  void setZoom(double zoom) {
    _currentZoom = zoom.clamp(AppConstants.minZoom, AppConstants.maxZoom);
    try {
      mapController.move(mapController.camera.center, _currentZoom);
    } catch (_) {}
    notifyListeners();
  }

  void zoomIn() {
    setZoom(_currentZoom + 1.0);
  }

  void zoomOut() {
    setZoom(_currentZoom - 1.0);
  }

  void centerOnUser() {
    _isFollowMode = true;
    try {
      mapController.move(_userLocation, 16.0);
      mapController.rotate(0.0);
    } catch (_) {}
    notifyListeners();
  }

  void resetRotation() {
    try {
      mapController.rotate(0.0);
    } catch (_) {}
    notifyListeners();
  }

  void onMapPositionChanged(MapCamera camera, bool hasGesture) {
    _currentZoom = camera.zoom;
    if (hasGesture && _isFollowMode) {
      _isFollowMode = false;
      notifyListeners();
    }
  }

  void moveTo(LatLng target, {double? zoom}) {
    final double z = zoom ?? _currentZoom;
    _currentZoom = z;
    try {
      mapController.move(target, z);
    } catch (_) {}
    notifyListeners();
  }

  void selectCityPreset(CityPreset preset) {
    _userLocation = preset.location;
    moveTo(preset.location, zoom: 14.0);
    // Reverse geocode to load place details for the city
    onMapTapped(preset.location);
  }

  // --- Styles & Theme ---
  void setMapStyle(MapStyleType style) {
    _selectedStyle = style;
    _storageService.setSelectedStyle(style);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _storageService.setDarkMode(_isDarkMode);
    if (_isDarkMode && _selectedStyle == MapStyleType.streets) {
      _selectedStyle = MapStyleType.darkMatter;
    } else if (!_isDarkMode && _selectedStyle == MapStyleType.darkMatter) {
      _selectedStyle = MapStyleType.streets;
    }
    notifyListeners();
  }

  // --- Search & Autocomplete ---
  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _geocodingService.searchPlaces(query, userLocation: _userLocation);
      _searchResults = results.map((place) {
        final dist = GeoUtils.calculateDistanceMeters(_userLocation, place.location);
        return place.copyWith(distanceMeters: dist);
      }).toList();
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void selectSearchResult(PlaceModel place) {
    _selectedPlace = place;
    _storageService.addSearchQuery(place.name);
    _searchHistory = _storageService.getSearchHistory();
    _searchResults = [];
    _searchQuery = place.name;
    moveTo(place.location, zoom: 16.5);
    notifyListeners();
  }

  Future<void> selectCategoryFilter(PlaceCategory category) async {
    if (_selectedCategory == category) {
      _selectedCategory = null;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _selectedCategory = category;
    _isSearching = true;
    notifyListeners();

    try {
      final results = await _geocodingService.searchNearbyCategory(category, _userLocation);
      _searchResults = results.map((place) {
        final dist = GeoUtils.calculateDistanceMeters(_userLocation, place.location);
        return place.copyWith(distanceMeters: dist);
      }).toList();
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _selectedCategory = null;
    notifyListeners();
  }

  // --- Map Interaction (Tap & Pin) ---
  Future<void> onMapTapped(LatLng position) async {
    if (_isNavigating) return;

    // Place a temporary pin and reverse geocode
    _selectedPlace = PlaceModel(
      id: '${position.latitude}_${position.longitude}',
      name: 'Selected Pin',
      displayName: 'Locating address...',
      location: position,
      distanceMeters: GeoUtils.calculateDistanceMeters(_userLocation, position),
    );
    notifyListeners();

    try {
      final place = await _geocodingService.reverseGeocode(position);
      final dist = GeoUtils.calculateDistanceMeters(_userLocation, position);
      _selectedPlace = place.copyWith(distanceMeters: dist);
    } catch (_) {}
    notifyListeners();
  }

  void dismissPlaceDetails() {
    _selectedPlace = null;
    notifyListeners();
  }

  // --- Routing & Navigation ---
  void setTravelMode(TravelMode mode) {
    if (_selectedTravelMode == mode) return;
    _selectedTravelMode = mode;
    notifyListeners();
    if (_selectedPlace != null && _activeRoute != null) {
      calculateRouteTo(_selectedPlace!);
    }
  }

  Future<void> calculateRouteTo(PlaceModel destination) async {
    _isLoadingRoute = true;
    _selectedPlace = destination;
    notifyListeners();

    try {
      final route = await _routingService.getRoute(
        start: _userLocation,
        destination: destination.location,
        mode: _selectedTravelMode,
      );
      _activeRoute = route;

      // Fit map camera bounds to cover entire route
      if (route.points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(route.points);
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(top: 100, bottom: 260, left: 50, right: 50),
          ),
        );
      }
    } catch (e) {
      _activeRoute = RouteModel.createFallback(
        startPoint: _userLocation,
        endPoint: destination.location,
        travelMode: _selectedTravelMode,
      );
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    _activeRoute = null;
    _isLoadingRoute = false;
    stopNavigation();
    notifyListeners();
  }

  // --- Turn-by-Turn Navigation Simulation ---
  void startNavigation() {
    if (_activeRoute == null || _activeRoute!.points.isEmpty) return;
    _isNavigating = true;
    _currentNavStepIndex = 0;
    _navProgress = 0.0;
    _isFollowMode = true;

    // Move camera to start
    mapController.move(_userLocation, 17.5);
    notifyListeners();

    // Start simulation loop (moving user along route polyline)
    _simulationTimer?.cancel();
    const tickInterval = Duration(milliseconds: 300);
    final List<LatLng> polyline = _activeRoute!.points;
    int currentIndex = 0;

    _simulationTimer = Timer.periodic(tickInterval, (timer) {
      if (currentIndex >= polyline.length - 1) {
        // Arrived at destination
        timer.cancel();
        _isNavigating = false;
        _navProgress = 1.0;
        _userLocation = polyline.last;
        notifyListeners();
        return;
      }

      currentIndex++;
      final LatLng nextPoint = polyline[currentIndex];
      final double bearing = GeoUtils.calculateBearing(_userLocation, nextPoint);

      _userLocation = nextPoint;
      _userHeading = bearing;
      _navProgress = currentIndex / (polyline.length - 1).toDouble();

      // Update current turn step index
      if (_activeRoute!.steps.isNotEmpty) {
        final double distToDest = GeoUtils.calculateDistanceMeters(nextPoint, _activeRoute!.endPoint);
        final int estimatedStep = ((1.0 - (distToDest / _activeRoute!.distanceMeters)) *
                _activeRoute!.steps.length)
            .clamp(0, _activeRoute!.steps.length - 1)
            .toInt();
        _currentNavStepIndex = estimatedStep;
      }

      // Dynamic speed simulation
      _currentSpeedKmh = _selectedTravelMode == TravelMode.driving
          ? 38.0 + (currentIndex % 15)
          : (_selectedTravelMode == TravelMode.cycling ? 16.0 : 4.8);

      // Smooth camera follow
      if (_isFollowMode) {
        try {
          mapController.move(_userLocation, 17.5);
          mapController.rotate(-bearing); // 3D driving view rotation
        } catch (_) {}
      }

      notifyListeners();
    });
  }

  void stopNavigation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isNavigating = false;
    _currentNavStepIndex = 0;
    _navProgress = 0.0;
    try {
      mapController.rotate(0.0);
    } catch (_) {}
    notifyListeners();
  }

  // --- Saved Places / Bookmarks ---
  Future<void> toggleSavePlace(PlaceModel place) async {
    final isSaved = _storageService.isPlaceSaved(place.id);
    if (isSaved) {
      await _storageService.deletePlace(place.id);
    } else {
      final saved = SavedPlaceModel(
        id: place.id,
        title: place.name,
        address: place.displayName,
        location: place.location,
        type: BookmarkType.favorite,
        createdAt: DateTime.now(),
      );
      await _storageService.savePlace(saved);
    }
    _savedPlaces = _storageService.getSavedPlaces();
    notifyListeners();
  }

  bool isPlaceBookmarked(String id) {
    return _storageService.isPlaceSaved(id);
  }

  Future<void> removeSavedPlace(String id) async {
    await _storageService.deletePlace(id);
    _savedPlaces = _storageService.getSavedPlaces();
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    mapController.dispose();
    super.dispose();
  }
}
