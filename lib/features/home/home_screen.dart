import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/saved_place.dart';
import '../../services/location_service.dart';
import '../../services/hive_service.dart';
import '../../services/map_service.dart';
import '../../services/share_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<SavedPlace> savedPlaces = [];
  String searchText = "";

  @override
  void initState() {
    super.initState();
    savedPlaces.addAll(HiveService.getPlaces());
  }

  Future<void> saveNewSpot() async {
    final Position? position = await LocationService.getCurrentLocation();

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Save this place",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Example: Friend House",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0D0D0D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;

final place = SavedPlace(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: nameController.text.trim(),
  latitude: position.latitude,
  longitude: position.longitude,
  createdAt: DateTime.now(),
);

                    await HiveService.addPlace(place);

                    setState(() {
                      savedPlaces.add(place);
                    });

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save Place",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> renamePlace(int index, SavedPlace oldPlace) async {
    final TextEditingController nameController =
        TextEditingController(text: oldPlace.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: const Text(
            "Rename Place",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "New place name",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final updatedPlace = oldPlace.copyWith(
  name: nameController.text.trim(),
);

                await HiveService.updatePlace(index, updatedPlace);

                setState(() {
                  savedPlaces[index] = updatedPlace;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePlace(int index) async {
  final place = savedPlaces[index];

  final bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF181818),
        title: const Text(
          "Delete Place?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${place.name}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFFFF4D4F)),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) return;

  await HiveService.deletePlace(index);

  setState(() {
    savedPlaces.removeAt(index);
  });
}

Future<void> toggleFavorite(int index) async {
  final place = savedPlaces[index];

  final updatedPlace = place.copyWith(
    isFavorite: !place.isFavorite,
  );

  await HiveService.updatePlace(index, updatedPlace);

  setState(() {
    savedPlaces[index] = updatedPlace;

    savedPlaces.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  });
}

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = savedPlaces.where((place) {
      return place.name.toLowerCase().contains(searchText);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: saveNewSpot,
        child: const Icon(Icons.add, size: 30),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${getGreeting()} 👋",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "SaveSpot",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                savedPlaces.isEmpty
                    ? "Save your first important place"
                    : "You have ${savedPlaces.length} saved places",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search place...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF181818),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: savedPlaces.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        itemCount: filteredPlaces.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];
                          final originalIndex = savedPlaces.indexOf(place);

                          return _PlaceCard(
                            place: place,
                            onOpenMap: () {
                              MapService.openMap(
                                latitude: place.latitude,
                                longitude: place.longitude,
                              );
                            },
                            onShare: () {
                              ShareService.sharePlace(
                                name: place.name,
                                latitude: place.latitude,
                                longitude: place.longitude,
                              );
                            },
                            onEdit: () {
                              renamePlace(originalIndex, place);
                            },
                            onDelete: () {
                              deletePlace(originalIndex);
                            },
                            onFavorite: () {
  toggleFavorite(originalIndex);
},
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 18),
            Text(
              "No saved places yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap the + button to save your current location.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback onOpenMap;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  const _PlaceCard({
    required this.place,
    required this.onOpenMap,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white10,
                child: Icon(
                  Icons.place,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

            Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  place.isFavorite ? Icons.star : Icons.star_border,
                  color: place.isFavorite ? Colors.amber : Colors.white54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Text(
            "📍 ${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CardAction(
                icon: Icons.map_outlined,
                label: "Maps",
                onTap: onOpenMap,
              ),
              const SizedBox(width: 10),
              _CardAction(
                icon: Icons.share_outlined,
                label: "Share",
                onTap: onShare,
              ),
              const SizedBox(width: 10),
              _CardAction(
                icon: Icons.edit_outlined,
                label: "Edit",
                onTap: onEdit,
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFF4D4F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}