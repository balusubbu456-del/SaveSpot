class SavedPlace {
  final String name;
  final double latitude;
  final double longitude;

  SavedPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  SavedPlace copyWith({
    String? name,
    double? latitude,
    double? longitude,
  }) {
    return SavedPlace(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}