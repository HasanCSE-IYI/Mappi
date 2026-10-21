import 'dart:ui';
import 'package:flutter/material.dart';
import '../state/map_state_manager.dart';

class MapControlsWidget extends StatelessWidget {
  final MapStateManager state;
  final VoidCallback onOpenLayerSelector;

  const MapControlsWidget({
    super.key,
    required this.state,
    required this.onOpenLayerSelector,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Layer Selector Button
        _buildControlButton(
          context: context,
          icon: Icons.layers_rounded,
          tooltip: 'Map Styles & Layers',
          isDark: isDark,
          onPressed: onOpenLayerSelector,
        ),
        const SizedBox(height: 10),

        // Compass / Reset North
        _buildControlButton(
          context: context,
          icon: Icons.explore_rounded,
          tooltip: 'Reset North Orientation',
          isDark: isDark,
          iconColor: Colors.redAccent,
          onPressed: state.resetRotation,
        ),
        const SizedBox(height: 10),

        // My Location / Center
        _buildControlButton(
          context: context,
          icon: state.isFollowMode ? Icons.my_location_rounded : Icons.location_searching_rounded,
          tooltip: 'My Location',
          isDark: isDark,
          iconColor: state.isFollowMode ? const Color(0xFF2563EB) : null,
          onPressed: state.centerOnUser,
        ),
        const SizedBox(height: 10),

        // Zoom In / Out Group
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withAlpha(225)
                    : Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 60 : 20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 22),
                    tooltip: 'Zoom In',
                    onPressed: state.zoomIn,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_rounded, size: 22),
                    tooltip: 'Zoom Out',
                    onPressed: state.zoomOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withAlpha(225)
                : Colors.white.withAlpha(235),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: 22,
              color: iconColor ?? (isDark ? Colors.white : Colors.black87),
            ),
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
