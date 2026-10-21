import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/constants/app_constants.dart';
import '../state/map_state_manager.dart';
import '../widgets/category_chips_widget.dart';
import '../widgets/layer_selector_sheet.dart';
import '../widgets/map_controls_widget.dart';
import '../widgets/navigation_hud_widget.dart';
import '../widgets/place_details_sheet.dart';
import '../widgets/route_planning_card.dart';
import '../widgets/saved_places_drawer.dart';
import '../widgets/search_bar_widget.dart';

class MapScreen extends StatefulWidget {
  final MapStateManager state;

  const MapScreen({super.key, required this.state});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final state = widget.state;
        final style = state.activeStyleDefinition;

        return Scaffold(
          key: _scaffoldKey,
          drawer: SavedPlacesDrawer(state: state),
          body: Stack(
            children: [
              // 1. The Interactive Flutter Map Canvas
              FlutterMap(
                mapController: state.mapController,
                options: MapOptions(
                  initialCenter: state.userLocation,
                  initialZoom: state.currentZoom,
                  minZoom: AppConstants.minZoom,
                  maxZoom: style.maxZoom.toDouble(),
                  onTap: (tapPosition, point) {
                    state.onMapTapped(point);
                  },
                  onPositionChanged: (camera, hasGesture) {
                    state.onMapPositionChanged(camera, hasGesture);
                  },
                ),
                children: [
                  // Vector / Raster Tile Layer
                  TileLayer(
                    urlTemplate: style.urlTemplate,
                    subdomains: style.subdomains,
                    userAgentPackageName: AppConstants.userAgentPackage,
                    maxZoom: style.maxZoom.toDouble(),
                  ),

                  // Route Polyline Layer
                  if (state.activeRoute != null && state.activeRoute!.points.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        // Casing / Shadow line
                        Polyline(
                          points: state.activeRoute!.points,
                          strokeWidth: 8.0,
                          color: Colors.blue.shade900.withAlpha(160),
                        ),
                        // Primary Vibrant Polyline
                        Polyline(
                          points: state.activeRoute!.points,
                          strokeWidth: 5.5,
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),

                  // Markers Layer
                  MarkerLayer(
                    markers: [
                      // User Current Location Pulsing Marker
                      Marker(
                        point: state.userLocation,
                        width: 50,
                        height: 50,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Pulsing Glow
                                  Container(
                                    width: 44 * _pulseAnimation.value,
                                    height: 44 * _pulseAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2563EB).withAlpha((70 / _pulseAnimation.value).round()),
                                    ),
                                  ),
                                  // Heading pointer arrow
                                  Transform.rotate(
                                    angle: state.userHeading * (3.14159265359 / 180.0),
                                    child: const Icon(
                                      Icons.navigation_rounded,
                                      size: 32,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                  // Inner Dot
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF1D4ED8), width: 3),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Selected Place Pin Marker
                      if (state.selectedPlace != null)
                        Marker(
                          point: state.selectedPlace!.location,
                          width: 46,
                          height: 46,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: state.selectedPlace!.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: state.selectedPlace!.color.withAlpha(120),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                                child: Icon(
                                  state.selectedPlace!.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Search Results Markers (if active)
                      ...state.searchResults.map((place) {
                        return Marker(
                          point: place.location,
                          width: 38,
                          height: 38,
                          child: GestureDetector(
                            onTap: () => state.selectSearchResult(place),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: place.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: Icon(place.icon, color: Colors.white, size: 16),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // 2. Navigation HUD (Active during turn-by-turn simulation)
              if (state.isNavigating)
                NavigationHudWidget(state: state)
              else ...[
                // Top Search Bar & Category Chips
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchBarWidget(
                        state: state,
                        onOpenDrawer: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(height: 10),
                      CategoryChipsWidget(state: state),
                    ],
                  ),
                ),

                // Right Floating Action Controls
                Positioned(
                  right: 16,
                  bottom: state.activeRoute != null
                      ? 220
                      : (state.selectedPlace != null ? 240 : 36),
                  child: MapControlsWidget(
                    state: state,
                    onOpenLayerSelector: () {
                      LayerSelectorSheet.show(context, state);
                    },
                  ),
                ),

                // Bottom Route Planning Card
                if (state.activeRoute != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RoutePlanningCard(
                      state: state,
                      route: state.activeRoute!,
                    ),
                  )
                // Bottom Place Details Bottom Sheet
                else if (state.selectedPlace != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PlaceDetailsSheet(
                      state: state,
                      place: state.selectedPlace!,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
