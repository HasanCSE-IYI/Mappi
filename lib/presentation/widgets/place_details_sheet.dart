import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/geo_utils.dart';
import '../../data/models/place_model.dart';
import '../state/map_state_manager.dart';

class PlaceDetailsSheet extends StatelessWidget {
  final MapStateManager state;
  final PlaceModel place;

  const PlaceDetailsSheet({
    super.key,
    required this.state,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBookmarked = state.isPlaceBookmarked(place.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 120 : 35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Category & Close row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.color.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(place.icon, size: 14, color: place.color),
                      const SizedBox(width: 5),
                      Text(
                        place.categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: place.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (place.isOpenNow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Open Now',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: state.dismissPlaceDetails,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Place Title & Distance
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (place.distanceMeters != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          GeoUtils.formatDistance(place.distanceMeters!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating & Reviews
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  place.rating?.toStringAsFixed(1) ?? '4.5',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${place.reviewsCount ?? 128} reviews)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const Spacer(),
                Text(
                  '${place.location.latitude.toStringAsFixed(4)}, ${place.location.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Action Buttons Row
            Row(
              children: [
                // Primary Directions Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    icon: state.isLoadingRoute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.directions_rounded),
                    label: Text(
                      state.isLoadingRoute ? 'Calculating...' : 'Directions',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    onPressed: state.isLoadingRoute
                        ? null
                        : () {
                            state.calculateRouteTo(place);
                          },
                  ),
                ),
                const SizedBox(width: 10),

                // Favorite / Bookmark Button
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      color: isBookmarked ? const Color(0xFFF59E0B) : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    tooltip: isBookmarked ? 'Saved to Bookmarks' : 'Save Place',
                    onPressed: () {
                      state.toggleSavePlace(place);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBookmarked ? 'Removed from saved places' : 'Saved to favorites!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Copy Coordinates / Share
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy Coordinates',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '${place.location.latitude}, ${place.location.longitude}',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coordinates copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
