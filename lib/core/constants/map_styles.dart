import 'package:flutter/material.dart';

/// Available Map Tile Layer Styles
enum MapStyleType {
  streets,
  darkMatter,
  satellite,
  topographic,
  voyager,
}

class MapStyleDefinition {
  final MapStyleType type;
  final String title;
  final String subtitle;
  final String urlTemplate;
  final List<String> subdomains;
  final IconData icon;
  final Color accentColor;
  final int maxZoom;
  final bool isDark;

  const MapStyleDefinition({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c', 'd'],
    required this.icon,
    required this.accentColor,
    this.maxZoom = 19,
    this.isDark = false,
  });
}

class MapStyles {
  MapStyles._();

  static const MapStyleDefinition streets = MapStyleDefinition(
    type: MapStyleType.streets,
    title: 'Standard Streets',
    subtitle: 'Classic OpenStreetMap detailed street layout',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
    icon: Icons.map_outlined,
    accentColor: Color(0xFF1E88E5),
    maxZoom: 19,
    isDark: false,
  );

  static const MapStyleDefinition darkMatter = MapStyleDefinition(
    type: MapStyleType.darkMatter,
    title: 'Dark Matter',
    subtitle: 'High contrast dark theme ideal for nighttime',
    urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
    icon: Icons.dark_mode_outlined,
    accentColor: Color(0xFF673AB7),
    maxZoom: 20,
    isDark: true,
  );

  static const MapStyleDefinition satellite = MapStyleDefinition(
    type: MapStyleType.satellite,
    title: 'Satellite Imagery',
    subtitle: 'Photorealistic high-res Earth imagery',
    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    subdomains: [],
    icon: Icons.satellite_alt_outlined,
    accentColor: Color(0xFF43A047),
    maxZoom: 18,
    isDark: true,
  );

  static const MapStyleDefinition topographic = MapStyleDefinition(
    type: MapStyleType.topographic,
    title: 'Topographic',
    subtitle: 'Contours, elevation, nature & outdoor trails',
    urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
    icon: Icons.terrain_outlined,
    accentColor: Color(0xFFFB8C00),
    maxZoom: 17,
    isDark: false,
  );

  static const MapStyleDefinition voyager = MapStyleDefinition(
    type: MapStyleType.voyager,
    title: 'Voyager Urban',
    subtitle: 'Modern pastel city aesthetics with clear POIs',
    urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
    icon: Icons.explore_outlined,
    accentColor: Color(0xFF00ACC1),
    maxZoom: 20,
    isDark: false,
  );

  static final List<MapStyleDefinition> allStyles = [
    streets,
    darkMatter,
    satellite,
    voyager,
    topographic,
  ];

  static MapStyleDefinition getStyle(MapStyleType type) {
    return allStyles.firstWhere(
      (s) => s.type == type,
      orElse: () => streets,
    );
  }
}
