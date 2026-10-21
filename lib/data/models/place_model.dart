import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Place category enumeration
enum PlaceCategory {
  cafe,
  restaurant,
  hospital,
  hotel,
  gasStation,
  atm,
  shopping,
  transport,
  general,
}

/// Represents a point of interest or search result
class PlaceModel {
  final String id;
  final String name;
  final String displayName;
  final String? street;
  final String? city;
  final String? country;
  final PlaceCategory category;
  final LatLng location;
  final double? rating;
  final int? reviewsCount;
  final bool isOpenNow;
  final double? distanceMeters;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.street,
    this.city,
    this.country,
    this.category = PlaceCategory.general,
    required this.location,
    this.rating = 4.5,
    this.reviewsCount = 128,
    this.isOpenNow = true,
    this.distanceMeters,
  });

  PlaceModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? street,
    String? city,
    String? country,
    PlaceCategory? category,
    LatLng? location,
    double? rating,
    int? reviewsCount,
    bool? isOpenNow,
    double? distanceMeters,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      category: category ?? this.category,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  /// Create from Photon API feature
  factory PlaceModel.fromPhoton(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    final double lon = (coordinates[0] as num).toDouble();
    final double lat = (coordinates[1] as num).toDouble();

    final String name = properties['name']?.toString() ??
        properties['street']?.toString() ??
        properties['city']?.toString() ??
        'Location';

    final String street = properties['street']?.toString() ?? '';
    final String city = properties['city']?.toString() ?? '';
    final String state = properties['state']?.toString() ?? '';
    final String country = properties['country']?.toString() ?? '';

    final List<String> addressParts = [
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];
    final String displayName = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : '$lat, $lon';

    final String osmValue = properties['osm_value']?.toString() ?? '';
    final PlaceCategory category = _parseCategory(osmValue);

    return PlaceModel(
      id: '${lat}_${lon}_${name.hashCode}',
      name: name,
      displayName: displayName,
      street: street.isNotEmpty ? street : null,
      city: city.isNotEmpty ? city : null,
      country: country.isNotEmpty ? country : null,
      category: category,
      location: LatLng(lat, lon),
      rating: 4.2 + (name.hashCode % 8) / 10.0,
      reviewsCount: 30 + (name.hashCode % 400).abs(),
      isOpenNow: (name.hashCode % 2) == 0,
    );
  }

  /// Create from Nominatim API reverse/search result
  factory PlaceModel.fromNominatim(Map<String, dynamic> json) {
    final double lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final double lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;
    final address = json['address'] as Map<String, dynamic>? ?? {};

    final String name = json['name']?.toString() ??
        address['road']?.toString() ??
        address['suburb']?.toString() ??
        address['city']?.toString() ??
        'Selected Location';

    final String displayName = json['display_name']?.toString() ?? '$lat, $lon';
    final String type = json['type']?.toString() ?? '';

    return PlaceModel(
      id: '${lat}_${lon}_${json['place_id'] ?? name.hashCode}',
      name: name,
      displayName: displayName,
      street: address['road']?.toString(),
      city: address['city']?.toString() ?? address['town']?.toString(),
      country: address['country']?.toString(),
      category: _parseCategory(type),
      location: LatLng(lat, lon),
      rating: 4.5,
      reviewsCount: 156,
      isOpenNow: true,
    );
  }

  static PlaceCategory _parseCategory(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('cafe') || t.contains('coffee')) return PlaceCategory.cafe;
    if (t.contains('restaurant') || t.contains('food') || t.contains('fast_food')) {
      return PlaceCategory.restaurant;
    }
    if (t.contains('hospital') || t.contains('clinic') || t.contains('pharmacy') || t.contains('doctor')) {
      return PlaceCategory.hospital;
    }
    if (t.contains('hotel') || t.contains('motel') || t.contains('hostel') || t.contains('lodging')) {
      return PlaceCategory.hotel;
    }
    if (t.contains('fuel') || t.contains('gas') || t.contains('charging')) {
      return PlaceCategory.gasStation;
    }
    if (t.contains('atm') || t.contains('bank')) return PlaceCategory.atm;
    if (t.contains('supermarket') || t.contains('mall') || t.contains('shop')) {
      return PlaceCategory.shopping;
    }
    if (t.contains('station') || t.contains('bus') || t.contains('subway') || t.contains('airport')) {
      return PlaceCategory.transport;
    }
    return PlaceCategory.general;
  }

  IconData get icon {
    switch (category) {
      case PlaceCategory.cafe:
        return Icons.local_cafe_rounded;
      case PlaceCategory.restaurant:
        return Icons.restaurant_rounded;
      case PlaceCategory.hospital:
        return Icons.local_hospital_rounded;
      case PlaceCategory.hotel:
        return Icons.hotel_rounded;
      case PlaceCategory.gasStation:
        return Icons.local_gas_station_rounded;
      case PlaceCategory.atm:
        return Icons.atm_rounded;
      case PlaceCategory.shopping:
        return Icons.shopping_bag_rounded;
      case PlaceCategory.transport:
        return Icons.directions_transit_rounded;
      case PlaceCategory.general:
        return Icons.place_rounded;
    }
  }

  Color get color {
    switch (category) {
      case PlaceCategory.cafe:
        return const Color(0xFFD97706);
      case PlaceCategory.restaurant:
        return const Color(0xFFEA580C);
      case PlaceCategory.hospital:
        return const Color(0xFFDC2626);
      case PlaceCategory.hotel:
        return const Color(0xFF7C3AED);
      case PlaceCategory.gasStation:
        return const Color(0xFF0284C7);
      case PlaceCategory.atm:
        return const Color(0xFF059669);
      case PlaceCategory.shopping:
        return const Color(0xFFDB2777);
      case PlaceCategory.transport:
        return const Color(0xFF4F46E5);
      case PlaceCategory.general:
        return const Color(0xFF2563EB);
    }
  }

  String get categoryName {
    switch (category) {
      case PlaceCategory.cafe:
        return 'Coffee & Cafe';
      case PlaceCategory.restaurant:
        return 'Restaurant';
      case PlaceCategory.hospital:
        return 'Hospital & Health';
      case PlaceCategory.hotel:
        return 'Hotel & Stay';
      case PlaceCategory.gasStation:
        return 'Fuel Station';
      case PlaceCategory.atm:
        return 'ATM & Banking';
      case PlaceCategory.shopping:
        return 'Supermarket & Shopping';
      case PlaceCategory.transport:
        return 'Public Transit';
      case PlaceCategory.general:
        return 'Place of Interest';
    }
  }
}
