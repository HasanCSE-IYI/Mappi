import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/map_styles.dart';
import '../models/saved_place_model.dart';

/// Service responsible for local persistence using SharedPreferences
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Saved Bookmarks ---
  List<SavedPlaceModel> getSavedPlaces() {
    final String? raw = _prefs.getString(AppConstants.keySavedPlaces);
    if (raw == null || raw.isEmpty) {
      return _defaultPresets();
    }
    try {
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      return list.map((item) => SavedPlaceModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultPresets();
    }
  }

  Future<bool> savePlace(SavedPlaceModel place) async {
    final current = getSavedPlaces();
    current.removeWhere((p) => p.id == place.id);
    current.insert(0, place);
    final String encoded = json.encode(current.map((p) => p.toMap()).toList());
    return _prefs.setString(AppConstants.keySavedPlaces, encoded);
  }

  Future<bool> deletePlace(String id) async {
    final current = getSavedPlaces();
    current.removeWhere((p) => p.id == id);
    final String encoded = json.encode(current.map((p) => p.toMap()).toList());
    return _prefs.setString(AppConstants.keySavedPlaces, encoded);
  }

  bool isPlaceSaved(String id) {
    final list = getSavedPlaces();
    return list.any((p) => p.id == id);
  }

  // --- Search History ---
  List<String> getSearchHistory() {
    return _prefs.getStringList(AppConstants.keySearchHistory) ?? [
      'Gulshan Circle 2',
      'Dhanmondi Lake',
      'Hazrat Shahjalal International Airport',
      'Bashundhara City',
    ];
  }

  Future<bool> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;
    final history = getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    history.insert(0, trimmed);
    if (history.length > 15) {
      history.removeRange(15, history.length);
    }
    return _prefs.setStringList(AppConstants.keySearchHistory, history);
  }

  Future<bool> clearSearchHistory() async {
    return _prefs.remove(AppConstants.keySearchHistory);
  }

  // --- Map Style & Theme Preferences ---
  MapStyleType getSelectedStyle() {
    final int? index = _prefs.getInt(AppConstants.keyMapStyle);
    if (index == null || index < 0 || index >= MapStyleType.values.length) {
      return MapStyleType.streets;
    }
    return MapStyleType.values[index];
  }

  Future<bool> setSelectedStyle(MapStyleType style) async {
    return _prefs.setInt(AppConstants.keyMapStyle, style.index);
  }

  bool isDarkMode() {
    return _prefs.getBool(AppConstants.keyDarkMode) ?? false;
  }

  Future<bool> setDarkMode(bool isDark) async {
    return _prefs.setBool(AppConstants.keyDarkMode, isDark);
  }

  List<SavedPlaceModel> _defaultPresets() {
    return [
      SavedPlaceModel(
        id: 'default_home',
        title: 'Home',
        customLabel: 'Primary Residence',
        address: 'House 14, Road 7, Banani, Dhaka',
        location: AppConstants.defaultLocation,
        type: BookmarkType.home,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SavedPlaceModel(
        id: 'default_work',
        title: 'Tech Campus / Office',
        customLabel: 'Headquarters',
        address: 'Tower 4, Gulshan Avenue, Dhaka',
        location: const LatLng(23.7806, 90.4193),
        type: BookmarkType.work,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
