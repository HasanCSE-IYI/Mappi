# Mappi 🗺️

A modern, high-performance, production-grade Flutter Map and Navigation application built with Clean Architecture, Reactive State Management, and Open-Source Mapping Services.

---

## ✨ Features

- **Multi-Layer Map Engine**:
  - Switch smoothly between 5 distinct map tile providers:
    - 🌐 **OpenStreetMap Standard**
    - 🏥 **Humanitarian Map**
    - ⛰️ **OpenTopoMap (Topographic & Elevation)**
    - ⚪ **CartoDB Positron (Clean Light)**
    - ⚫ **CartoDB Dark Matter (Sleek Dark Mode)**
- **Real-Time POI Search & Geocoding**:
  - Autocomplete search powered by Nominatim & Photon geocoding APIs.
  - One-tap quick filter category chips (Food, Fuel, Hotel, Pharmacy, Hospital).
  - Reverse geocoding support on tap.
- **Turn-by-Turn Navigation & HUD**:
  - High-precision OSRM routing engine with multi-modal support (driving, walking, cycling).
  - Dynamic Navigation HUD displaying current maneuver icon, next street, remaining distance, and ETA.
  - Interactive navigation simulation with variable playback speed (1x to 5x).
  - Resilient offline fallback routing mechanism.
- **Saved Places & Bookmarks**:
  - Save favorite places and recent searches with persistent local storage (`shared_preferences`).
  - Search history and quick navigation to bookmarked spots.
- **Design & UX**:
  - Glassmorphic UI cards, smooth bottom sheets, floating map controls, and compass heading.
  - Adaptive theme with full support for light and dark modes.

---

## 🏛️ Architecture & Folder Structure

The project follows Clean Architecture principles:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Map tile URLs, API endpoints, defaults
│   │   └── map_styles.dart         # Style definitions and metadata
│   ├── theme/
│   │   └── app_theme.dart          # Glassmorphic and modern Material 3 theme
│   └── utils/
│       └── geo_utils.dart          # Haversine distance, bearing, formatting
├── data/
│   ├── models/
│   │   ├── place_model.dart        # Geocoding & POI data models
│   │   ├── route_model.dart        # Navigation step & route data models
│   │   └── saved_place_model.dart  # Bookmark data models
│   └── services/
│       ├── geocoding_service.dart  # Photon / Nominatim API client
│       ├── routing_service.dart    # OSRM routing API & fallback generator
│       └── storage_service.dart    # Local persistence service
├── presentation/
│   ├── screens/
│   │   └── map_screen.dart         # Main interactive map screen
│   ├── state/
│   │   └── map_state_manager.dart  # Central reactive ChangeNotifier
│   └── widgets/
│       ├── category_chips_widget.dart
│       ├── layer_selector_sheet.dart
│       ├── map_controls_widget.dart
│       ├── navigation_hud_widget.dart
│       ├── place_details_sheet.dart
│       ├── route_planning_card.dart
│       ├── saved_places_drawer.dart
│       └── search_bar_widget.dart
└── main.dart                       # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/HasanCSE-IYI/Mappi.git
   cd Mappi
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run code analysis and tests**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

5. **Build debug APK**:
   ```bash
   flutter build apk --debug
   ```

---

## 🧪 Testing

The test suite covers geospatial calculations, route generation, and model serialization:

```bash
flutter test
```

All 6 test suites pass with 100% assertions satisfied.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
