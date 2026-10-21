import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:curious_hopper/core/utils/geo_utils.dart';
import 'package:curious_hopper/data/models/place_model.dart';
import 'package:curious_hopper/data/models/route_model.dart';

void main() {
  group('GeoUtils Tests', () {
    test('calculateDistanceMeters calculates accurate distance between coordinates', () {
      // Dhaka to Banani approx 2 km
      const p1 = LatLng(23.8103, 90.4125);
      const p2 = LatLng(23.7925, 90.4078);
      final distMeters = GeoUtils.calculateDistanceMeters(p1, p2);
      expect(distMeters, greaterThan(1500));
      expect(distMeters, lessThan(3000));
    });

    test('formatDistance formats meters and kilometers cleanly', () {
      expect(GeoUtils.formatDistance(450), '450 m');
      expect(GeoUtils.formatDistance(1250), '1.3 km');
      expect(GeoUtils.formatDistance(15000), '15.0 km');
    });

    test('formatDuration formats minutes and hours cleanly', () {
      expect(GeoUtils.formatDuration(45), '1 min');
      expect(GeoUtils.formatDuration(180), '3 mins');
      expect(GeoUtils.formatDuration(3700), '1 hr 2 min');
    });

    test('calculateBearing calculates directional angles correctly', () {
      const p1 = LatLng(0, 0);
      const pNorth = LatLng(1, 0);
      const pEast = LatLng(0, 1);

      expect(GeoUtils.calculateBearing(p1, pNorth), closeTo(0, 1.0));
      expect(GeoUtils.calculateBearing(p1, pEast), closeTo(90, 1.0));
    });
  });

  group('Data Models Tests', () {
    test('PlaceModel instantiation and defaults', () {
      const place = PlaceModel(
        id: '123',
        name: 'Dhanmondi Lake',
        displayName: 'Dhanmondi Lake, Dhaka',
        category: PlaceCategory.cafe,
        location: LatLng(23.7461, 90.3742),
      );

      expect(place.name, 'Dhanmondi Lake');
      expect(place.category, PlaceCategory.cafe);
      expect(place.location.latitude, 23.7461);
      expect(place.rating, 4.5);
    });

    test('RouteModel fallback generates valid waypoints and steps', () {
      const start = LatLng(23.8103, 90.4125);
      const end = LatLng(23.7925, 90.4078);
      final fallbackRoute = RouteModel.createFallback(
        startPoint: start,
        endPoint: end,
        travelMode: TravelMode.driving,
      );

      expect(fallbackRoute.points.length, greaterThan(2));
      expect(fallbackRoute.steps.isNotEmpty, true);
      expect(fallbackRoute.distanceMeters, greaterThan(0));
      expect(fallbackRoute.travelMode, TravelMode.driving);
    });
  });
}
