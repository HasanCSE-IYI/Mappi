import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Geographical & Routing Calculation Utilities
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371000.0;

  /// Calculate distance in meters using Haversine formula
  static double calculateDistanceMeters(LatLng point1, LatLng point2) {
    final double lat1Rad = point1.latitude * math.pi / 180.0;
    final double lat2Rad = point2.latitude * math.pi / 180.0;
    final double deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180.0;
    final double deltaLonRad = (point2.longitude - point1.longitude) * math.pi / 180.0;

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLonRad / 2) * math.sin(deltaLonRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Calculate bearing in degrees from point1 to point2 (0 - 360)
  static double calculateBearing(LatLng point1, LatLng point2) {
    final double lat1Rad = point1.latitude * math.pi / 180.0;
    final double lat2Rad = point2.latitude * math.pi / 180.0;
    final double deltaLonRad = (point2.longitude - point1.longitude) * math.pi / 180.0;

    final double y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

    final double radians = math.atan2(y, x);
    final double degrees = (radians * 180.0 / math.pi + 360.0) % 360.0;
    return degrees;
  }

  /// Linear interpolation between two coordinates
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    final double lat = from.latitude + (to.latitude - from.latitude) * fraction;
    final double lng = from.longitude + (to.longitude - from.longitude) * fraction;
    return LatLng(lat, lng);
  }

  /// Human-readable distance string (e.g., '350 m' or '4.8 km')
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final double km = meters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Human-readable duration string (e.g., '8 mins' or '2 hrs 15 mins')
  static String formatDuration(double seconds) {
    if (seconds < 60) {
      return '1 min';
    }
    final int totalMinutes = (seconds / 60).round();
    if (totalMinutes < 60) {
      return '$totalMinutes mins';
    }
    final int hours = totalMinutes ~/ 60;
    final int remainingMinutes = totalMinutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    }
    return '$hours hr${hours > 1 ? 's' : ''} $remainingMinutes min';
  }

  /// Format estimated arrival time
  static String formatETA(double durationSeconds) {
    final DateTime eta = DateTime.now().add(Duration(seconds: durationSeconds.round()));
    return DateFormat('h:mm a').format(eta);
  }

  /// Get appropriate turn maneuver icon for turn-by-turn guidance
  static IconData getManeuverIcon(String? modifier, String? type) {
    final mod = (modifier ?? '').toLowerCase();
    final t = (type ?? '').toLowerCase();

    if (t.contains('arrive')) {
      return Icons.location_on;
    }
    if (t.contains('depart')) {
      return Icons.navigation;
    }
    if (t.contains('roundabout') || t.contains('rotary')) {
      return Icons.change_circle_outlined;
    }

    if (mod.contains('sharp right')) {
      return Icons.turn_sharp_right;
    } else if (mod.contains('sharp left')) {
      return Icons.turn_sharp_left;
    } else if (mod.contains('slight right')) {
      return Icons.turn_slight_right;
    } else if (mod.contains('slight left')) {
      return Icons.turn_slight_left;
    } else if (mod.contains('right')) {
      return Icons.turn_right;
    } else if (mod.contains('left')) {
      return Icons.turn_left;
    } else if (mod.contains('u-turn')) {
      return Icons.u_turn_left;
    } else if (mod.contains('straight')) {
      return Icons.straight;
    }

    return Icons.arrow_upward;
  }
}
