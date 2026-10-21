import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/utils/geo_utils.dart';
import '../../data/models/place_model.dart';
import '../state/map_state_manager.dart';

/// Glassmorphic Floating Search Bar with instant autocomplete & search history
class SearchBarWidget extends StatefulWidget {
  final MapStateManager state;
  final VoidCallback onOpenDrawer;

  const SearchBarWidget({
    super.key,
    required this.state,
    required this.onOpenDrawer,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.searchQuery != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.state.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Floating Search Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withAlpha(220)
                    : Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(25)
                      : Colors.black.withAlpha(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 80 : 25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Menu / Saved drawer button
                  IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: 'Open Menu & Bookmarks',
                    onPressed: widget.onOpenDrawer,
                  ),

                  // Search input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search places, streets, cafes...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 15,
                        ),
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        state.search(val);
                      },
                      onSubmitted: (val) {
                        state.search(val);
                      },
                    ),
                  ),

                  // Clear or Loading Indicator
                  if (state.isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    )
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Clear',
                      onPressed: () {
                        _controller.clear();
                        state.clearSearch();
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(
                        state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: state.isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                        size: 22,
                      ),
                      tooltip: 'Toggle Dark / Light Theme',
                      onPressed: () {
                        state.toggleDarkMode();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),

        // Autocomplete Results or Search History Dropdown
        if (_isFocused || state.searchResults.isNotEmpty)
          _buildDropdownPanel(context, state, isDark),
      ],
    );
  }

  Widget _buildDropdownPanel(BuildContext context, MapStateManager state, bool isDark) {
    final hasResults = state.searchResults.isNotEmpty;
    final hasHistory = state.searchHistory.isNotEmpty && !hasResults;

    if (!hasResults && !hasHistory) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withAlpha(245)
            : Colors.white.withAlpha(245),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          children: [
            if (hasResults) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Search Results (${state.searchResults.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              ...state.searchResults.map((place) => _buildPlaceItem(context, place, state, isDark)),
            ] else if (hasHistory) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isFocused = false),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...state.searchHistory.take(5).map((q) => _buildHistoryItem(context, q, state, isDark)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceItem(BuildContext context, PlaceModel place, MapStateManager state, bool isDark) {
    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: place.color.withAlpha(isDark ? 40 : 25),
          shape: BoxShape.circle,
        ),
        child: Icon(place.icon, color: place.color, size: 20),
      ),
      title: Text(
        place.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        place.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
      ),
      trailing: place.distanceMeters != null
          ? Text(
              GeoUtils.formatDistance(place.distanceMeters!),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      onTap: () {
        _focusNode.unfocus();
        state.selectSearchResult(place);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, String query, MapStateManager state, bool isDark) {
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.history_rounded,
        size: 20,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      title: Text(
        query,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.north_west_rounded, size: 16),
      onTap: () {
        _controller.text = query;
        state.search(query);
      },
    );
  }
}
