import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:template_app/classes/objects/address_suggestion.dart';

class AddressLookupHelper {
  static Future<List<AddressSuggestion>> searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      return const [];
    }

    final encoded = Uri.encodeQueryComponent(trimmed);
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=5',
    );

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'template_app/1.0 (drive-time-autocomplete)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const [];
    }

    final payload = jsonDecode(response.body) as List<dynamic>;

    return payload
        .map((item) {
          final map = item as Map<String, dynamic>;
          final displayName = map['display_name']?.toString() ?? '';
          final latitude = double.tryParse(map['lat']?.toString() ?? '');
          final longitude = double.tryParse(map['lon']?.toString() ?? '');

          if (displayName.isEmpty || latitude == null || longitude == null) {
            return null;
          }

          return AddressSuggestion(
            displayName: displayName,
            latitude: latitude,
            longitude: longitude,
          );
        })
        .whereType<AddressSuggestion>()
        .toList();
  }
}
