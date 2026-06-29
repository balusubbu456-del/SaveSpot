class SavedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final String notes;

  SavedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.category = "Others",
    this.isFavorite = false,
    required this.createdAt,
    this.notes = "",
  });

  SavedPlace copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    String? notes,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}