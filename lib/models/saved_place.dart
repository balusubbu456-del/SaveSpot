class SavedPlace {
  final String name;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final String address;

  SavedPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.address = "",
  });

  SavedPlace copyWith({
    String? name,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    String? address,
  }) {
    return SavedPlace(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      address: address ?? this.address,
    );
  }
}