import 'package:flutter/material.dart';
import '../../data/models/route_model.dart';
import '../state/map_state_manager.dart';

class RoutePlanningCard extends StatefulWidget {
  final MapStateManager state;
  final RouteModel route;

  const RoutePlanningCard({
    super.key,
    required this.state,
    required this.route,
  });

  @override
  State<RoutePlanningCard> createState() => _RoutePlanningCardState();
}

class _RoutePlanningCardState extends State<RoutePlanningCard> {
  bool _showSteps = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;
    final route = widget.route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 100 : 30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar with Travel Modes & Close
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                // Mode selector pills
                ...TravelMode.values.map((mode) {
                  final isSelected = state.selectedTravelMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => state.setTravelMode(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(6)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              mode.icon,
                              size: 16,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mode.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Cancel Route',
                  onPressed: state.clearRoute,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Route Overview Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          route.formattedDuration,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${route.formattedDistance})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fastest route • Est. arrival: ${route.formattedETA}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Start Navigation Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Vibrant Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text(
                    'Start',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  onPressed: state.startNavigation,
                ),
              ],
            ),
          ),

          // Expandable Steps Toggle
          if (route.steps.isNotEmpty) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _showSteps = !_showSteps;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(4),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showSteps ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showSteps ? 'Hide Turn-by-Turn Steps' : 'View Turn-by-Turn Steps (${route.steps.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_showSteps)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: route.steps.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final step = route.steps[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withAlpha(isDark ? 40 : 20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon, size: 16, color: const Color(0xFF2563EB)),
                      ),
                      title: Text(
                        step.instruction,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      trailing: step.distanceMeters > 0
                          ? Text(
                              step.formattedDistance,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
