import 'package:flutter/material.dart';
import '../../data/models/place_model.dart';
import '../state/map_state_manager.dart';

class CategoryChipsWidget extends StatelessWidget {
  final MapStateManager state;

  const CategoryChipsWidget({super.key, required this.state});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(PlaceCategory.restaurant, 'Restaurants', Icons.restaurant_rounded, Color(0xFFEA580C)),
    _CategoryItem(PlaceCategory.cafe, 'Cafes', Icons.local_cafe_rounded, Color(0xFFD97706)),
    _CategoryItem(PlaceCategory.gasStation, 'Gas / Fuel', Icons.local_gas_station_rounded, Color(0xFF0284C7)),
    _CategoryItem(PlaceCategory.hospital, 'Hospitals', Icons.local_hospital_rounded, Color(0xFFDC2626)),
    _CategoryItem(PlaceCategory.shopping, 'Groceries', Icons.shopping_bag_rounded, Color(0xFFDB2777)),
    _CategoryItem(PlaceCategory.hotel, 'Hotels', Icons.hotel_rounded, Color(0xFF7C3AED)),
    _CategoryItem(PlaceCategory.atm, 'ATMs', Icons.atm_rounded, Color(0xFF059669)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _categories[index];
          final isSelected = state.selectedCategory == item.category;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => state.selectCategoryFilter(item.category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color
                      : (isDark
                          ? const Color(0xFF1E293B).withAlpha(220)
                          : Colors.white.withAlpha(235)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? item.color
                        : (isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? item.color.withAlpha(90)
                          : Colors.black.withAlpha(isDark ? 50 : 15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : item.color),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final PlaceCategory category;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem(this.category, this.label, this.icon, this.color);
}
