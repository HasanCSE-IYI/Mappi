import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum BookmarkType {
  home,
  work,
  favorite,
  custom,
}

extension BookmarkTypeExtension on BookmarkType {
  String get displayName {
    switch (this) {
      case BookmarkType.home:
        return 'Home';
      case BookmarkType.work:
        return 'Work';
      case BookmarkType.favorite:
        return 'Favorite';
      case BookmarkType.custom:
        return 'Custom Pin';
    }
  }

  IconData get icon {
    switch (this) {
      case BookmarkType.home:
        return Icons.home_rounded;
      case BookmarkType.work:
        return Icons.work_rounded;
      case BookmarkType.favorite:
        return Icons.star_rounded;
      case BookmarkType.custom:
        return Icons.bookmark_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BookmarkType.home:
        return const Color(0xFF2563EB);
      case BookmarkType.work:
        return const Color(0xFF0284C7);
      case BookmarkType.favorite:
        return const Color(0xFFEAB308);
      case BookmarkType.custom:
        return const Color(0xFF8B5CF6);
    }
  }
}

/// Model for user-saved locations / bookmarks
class SavedPlaceModel {
  final String id;
  final String title;
  final String? customLabel;
  final String address;
  final LatLng location;
  final BookmarkType type;
  final DateTime createdAt;
  final String? notes;

  const SavedPlaceModel({
    required this.id,
    required this.title,
    this.customLabel,
    required this.address,
    required this.location,
    required this.type,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'customLabel': customLabel,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SavedPlaceModel.fromMap(Map<String, dynamic> map) {
    return SavedPlaceModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Saved Spot',
      customLabel: map['customLabel']?.toString(),
      address: map['address']?.toString() ?? '',
      location: LatLng(
        (map['latitude'] as num?)?.toDouble() ?? 0.0,
        (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      type: BookmarkType.values[(map['type'] as int?) ?? 2],
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedPlaceModel.fromJson(String source) =>
      SavedPlaceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
