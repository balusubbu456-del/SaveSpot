import 'package:geocoding/geocoding.dart';

class AddressService {
  static Future<String> getAddressFromLatLng({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return "$latitude, $longitude";
      }

      final place = placemarks.first;

      final city = place.locality ?? place.subLocality ?? "";
      final state = place.administrativeArea ?? "";
      final country = place.country ?? "";

      return [
        city,
        state,
        country,
      ].where((item) => item.isNotEmpty).join(", ");
    } catch (e) {
      return "$latitude, $longitude";
    }
  }
}