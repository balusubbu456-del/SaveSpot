import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_place.dart';

class HiveService {
  static final Box _placesBox = Hive.box('places');

  static Future<void> addPlace(SavedPlace place) async {
    await _placesBox.add({
      'id': place.id,
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'category': place.category,
      'isFavorite': place.isFavorite,
      'createdAt': place.createdAt.toIso8601String(),
      'notes': place.notes,
    });
  }

  static List<SavedPlace> getPlaces() {
    return _placesBox.values.map((item) {
      final data = Map<String, dynamic>.from(item);

      return SavedPlace(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        category: data['category'] ?? 'Others',
        isFavorite: data['isFavorite'] ?? false,
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        notes: data['notes'] ?? '',
      );
    }).toList();
  }

  static Future<void> updatePlace(int index, SavedPlace place) async {
    await _placesBox.putAt(index, {
      'id': place.id,
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'category': place.category,
      'isFavorite': place.isFavorite,
      'createdAt': place.createdAt.toIso8601String(),
      'notes': place.notes,
    });
  }

  static Future<void> deletePlace(int index) async {
    await _placesBox.deleteAt(index);
  }
}