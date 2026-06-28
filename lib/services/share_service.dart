import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePlace({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    final String mapsLink =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await Share.share(
      '$name\n\nOpen location:\n$mapsLink',
    );
  }
}