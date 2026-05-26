import 'package:crew_support/database/airport_platform.dart';

/// Shared formatter used anywhere we want to show an airport from AirportLite.
///
/// Example output:
/// KJFK John F Kennedy International, New York, US-NY
///
/// If airport is null, falls back to the raw code.
String formatAirportDisplay(AirportLite? airport, {String fallbackCode = ''}) {
  final code = fallbackCode.trim();
  if (airport == null) return code;

  final ident = airport.ident.trim();
  final name = airport.name.trim();
  final municipality = airport.municipality.trim();
  final region = airport.region.trim();

  final buffer = StringBuffer();

  if (ident.isNotEmpty) {
    buffer.write(ident);
  }

  if (name.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(name);
  }

  final locationParts = <String>[];
  if (municipality.isNotEmpty) {
    locationParts.add(municipality);
  }
  if (region.isNotEmpty) {
    locationParts.add(region);
  }

  if (locationParts.isNotEmpty) {
    if (buffer.isNotEmpty) {
      buffer.write(', ');
    }
    buffer.write(locationParts.join(', '));
  }

  final formatted = buffer.toString().trim();
  return formatted.isEmpty ? code : formatted;
}

/// Shared lookup for a single airport code.
/// Returns the exact ident match from the local airport cache if found.
Future<AirportLite?> getAirportFromCodeShared(String code) async {
  final trimmed = code.trim();
  if (trimmed.isEmpty) return null;

  final results = await AirportCache.instance.searchByIdent(
    trimmed,
    limit: 10,
  );

  try {
    return results.firstWhere(
      (a) => a.ident.toLowerCase() == trimmed.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}

/// Shared bulk preload helper.
/// Accepts any iterable of airport codes, resolves them from local cache,
/// and returns a map keyed by trimmed airport code.
///
/// Example:
/// final airportMap = await preloadAirportsForCodes(
///   availabilityList.map((e) => e.airportCode),
/// );
Future<Map<String, AirportLite>> preloadAirportsForCodes(
  Iterable<String?> codes,
) async {
  final uniqueCodes = codes
      .map((e) => e?.trim() ?? '')
      .where((code) => code.isNotEmpty)
      .toSet();

  final result = <String, AirportLite>{};

  for (final code in uniqueCodes) {
    try {
      final airport = await getAirportFromCodeShared(code);
      if (airport != null) {
        result[code] = airport;
      }
    } catch (_) {
      // Ignore individual lookup failures so the rest can still load.
    }
  }

  return result;
}