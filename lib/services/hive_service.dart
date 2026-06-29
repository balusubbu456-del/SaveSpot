import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_place.dart';

class HiveService {
  static final Box _placesBox = Hive.box('places');

  static Future<void> addPlace(SavedPlace place) async {
    await _placesBox.add({
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
    });
  }

  static List<SavedPlace> getPlaces() {
    return _placesBox.values.map((item) {
      final data = Map<String, dynamic>.from(item);

      return SavedPlace(
        name: data['name'],
        latitude: data['latitude'],
        longitude: data['longitude'],
      );
    }).toList();
  }

  static Future<void> deletePlace(int index) async {
    await _placesBox.deleteAt(index);
  }

  static Future<void> updatePlace(int index, SavedPlace place) async {
    await _placesBox.putAt(index, {
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
    });
  }
}