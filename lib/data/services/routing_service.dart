import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';
import '../models/route_model.dart';

/// Service responsible for fetching real-world routes and turn-by-turn navigation data
class RoutingService {
  final http.Client _client;

  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  /// Calculate route between start and destination
  Future<RouteModel> getRoute({
    required LatLng start,
    required LatLng destination,
    required TravelMode mode,
  }) async {
    final String profile = mode.osrmProfile;
    final String coordinates = '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}';
    final String url = '${AppConstants.osrmRouteUrl}/$profile/$coordinates?overview=full&geometries=geojson&steps=true';

    try {
      final response = await _client
          .get(Uri.parse(url), headers: {'User-Agent': AppConstants.userAgentPackage})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final String code = data['code']?.toString() ?? '';
        if (code == 'Ok') {
          return RouteModel.fromOsrm(
            json: data,
            travelMode: mode,
            startPoint: start,
            endPoint: destination,
          );
        }
      }
    } catch (_) {
      // Fallback on network failure
    }

    // Graceful offline fallback route with realistic road curvature & turn instructions
    return RouteModel.createFallback(
      startPoint: start,
      endPoint: destination,
      travelMode: mode,
    );
  }
}
