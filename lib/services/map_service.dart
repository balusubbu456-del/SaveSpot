import 'package:url_launcher/url_launcher.dart';

class MapService {
  static Future<void> openMap({
    required double latitude,
    required double longitude,
  }) async {
    final Uri url = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}