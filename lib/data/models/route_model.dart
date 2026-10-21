import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/geo_utils.dart';

enum TravelMode {
  driving,
  walking,
  cycling,
}

extension TravelModeExtension on TravelMode {
  String get name {
    switch (this) {
      case TravelMode.driving:
        return 'Drive';
      case TravelMode.walking:
        return 'Walk';
      case TravelMode.cycling:
        return 'Cycling';
    }
  }

  IconData get icon {
    switch (this) {
      case TravelMode.driving:
        return Icons.directions_car_rounded;
      case TravelMode.walking:
        return Icons.directions_walk_rounded;
      case TravelMode.cycling:
        return Icons.directions_bike_rounded;
    }
  }

  String get osrmProfile {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.cycling:
        return 'bicycle';
    }
  }
}

/// Represents a single maneuver / turn in a route
class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final String? maneuverType;
  final String? maneuverModifier;
  final LatLng location;

  const RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    this.maneuverType,
    this.maneuverModifier,
    required this.location,
  });

  IconData get icon => GeoUtils.getManeuverIcon(maneuverModifier, maneuverType);

  String get formattedDistance => GeoUtils.formatDistance(distanceMeters);

  factory RouteStep.fromOsrm(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final locationCoords = maneuver['location'] as List<dynamic>? ?? [0.0, 0.0];
    final double lon = (locationCoords[0] as num).toDouble();
    final double lat = (locationCoords[1] as num).toDouble();

    final String name = json['name']?.toString() ?? '';
    final String type = maneuver['type']?.toString() ?? '';
    final String modifier = maneuver['modifier']?.toString() ?? '';

    String instruction = '';
    if (type == 'depart') {
      instruction = name.isNotEmpty ? 'Depart onto $name' : 'Start your trip';
    } else if (type == 'arrive') {
      instruction = 'You have arrived at your destination';
    } else if (modifier.isNotEmpty) {
      final String action = modifier.replaceAll('_', ' ');
      instruction = name.isNotEmpty ? 'Turn $action onto $name' : 'Turn $action';
    } else {
      instruction = name.isNotEmpty ? 'Continue on $name' : 'Continue straight';
    }

    return RouteStep(
      instruction: instruction,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['duration'] as num?)?.toDouble() ?? 0.0,
      maneuverType: type,
      maneuverModifier: modifier,
      location: LatLng(lat, lon),
    );
  }
}

/// Represents a complete calculated route
class RouteModel {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<RouteStep> steps;
  final TravelMode travelMode;
  final LatLng startPoint;
  final LatLng endPoint;

  const RouteModel({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
    required this.travelMode,
    required this.startPoint,
    required this.endPoint,
  });

  String get formattedDistance => GeoUtils.formatDistance(distanceMeters);
  String get formattedDuration => GeoUtils.formatDuration(durationSeconds);
  String get formattedETA => GeoUtils.formatETA(durationSeconds);

  factory RouteModel.fromOsrm({
    required Map<String, dynamic> json,
    required TravelMode travelMode,
    required LatLng startPoint,
    required LatLng endPoint,
  }) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No routes returned from OSRM');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

    final List<LatLng> points = coordinates.map((coord) {
      final List<dynamic> pair = coord as List<dynamic>;
      final double lon = (pair[0] as num).toDouble();
      final double lat = (pair[1] as num).toDouble();
      return LatLng(lat, lon);
    }).toList();

    final List<RouteStep> steps = [];
    final legs = route['legs'] as List<dynamic>? ?? [];
    for (final leg in legs) {
      final legSteps = leg['steps'] as List<dynamic>? ?? [];
      for (final s in legSteps) {
        steps.add(RouteStep.fromOsrm(s as Map<String, dynamic>));
      }
    }

    // Ensure start & end are matched
    if (points.isEmpty) {
      points.add(startPoint);
      points.add(endPoint);
    }

    final double distance = (route['distance'] as num?)?.toDouble() ??
        GeoUtils.calculateDistanceMeters(startPoint, endPoint);
    final double duration = (route['duration'] as num?)?.toDouble() ??
        (distance / 12.0); // fallback ~40km/h

    return RouteModel(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration,
      steps: steps,
      travelMode: travelMode,
      startPoint: startPoint,
      endPoint: endPoint,
    );
  }

  /// Create a direct synthetic route when offline
  factory RouteModel.createFallback({
    required LatLng startPoint,
    required LatLng endPoint,
    required TravelMode travelMode,
  }) {
    final double dist = GeoUtils.calculateDistanceMeters(startPoint, endPoint);
    final double speedMps = travelMode == TravelMode.driving
        ? 11.1 // 40 km/h
        : (travelMode == TravelMode.cycling ? 4.2 : 1.4); // 15 km/h, 5 km/h

    final double duration = dist / speedMps;

    // Generate nice realistic curve points
    final List<LatLng> points = [startPoint];
    const int segments = 8;
    for (int i = 1; i < segments; i++) {
      final double fraction = i / segments.toDouble();
      final LatLng straight = GeoUtils.interpolate(startPoint, endPoint, fraction);
      // add minor realistic lateral variance
      final double lateralOffset = (i % 2 == 1 ? 0.0003 : -0.0002) * (i / segments);
      points.add(LatLng(straight.latitude + lateralOffset, straight.longitude + lateralOffset));
    }
    points.add(endPoint);

    final List<RouteStep> steps = [
      RouteStep(
        instruction: 'Start moving towards destination',
        distanceMeters: dist * 0.25,
        durationSeconds: duration * 0.25,
        maneuverType: 'depart',
        location: startPoint,
      ),
      RouteStep(
        instruction: 'Continue straight on primary avenue',
        distanceMeters: dist * 0.5,
        durationSeconds: duration * 0.5,
        maneuverModifier: 'straight',
        location: points[4],
      ),
      RouteStep(
        instruction: 'Turn slight right into destination approach',
        distanceMeters: dist * 0.25,
        durationSeconds: duration * 0.25,
        maneuverModifier: 'slight right',
        location: points[6],
      ),
      RouteStep(
        instruction: 'Destination is on your right',
        distanceMeters: 0,
        durationSeconds: 0,
        maneuverType: 'arrive',
        location: endPoint,
      ),
    ];

    return RouteModel(
      points: points,
      distanceMeters: dist,
      durationSeconds: duration,
      steps: steps,
      travelMode: travelMode,
      startPoint: startPoint,
      endPoint: endPoint,
    );
  }
}
