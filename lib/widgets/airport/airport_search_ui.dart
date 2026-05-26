import 'package:crew_support/database/airport_platform.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:crew_support/utils/sizer_v2_compat.dart';
import 'package:flutter/material.dart';

class AirportSearchUi {
  static String _formatAirportTypeLabel(String rawType) {
    switch (rawType.trim().toLowerCase()) {
      case 'large_airport':
        return 'Large Airport';
      case 'medium_airport':
        return 'Medium Airport';
      case 'small_airport':
        return 'Small Airport';
      case 'heliport':
        return 'Heliport';
      case 'seaplane_base':
        return 'Seaplane Base';
      case 'balloonport':
        return 'Balloonport';
      case 'closed':
        return 'Closed';
      default:
        final normalized = rawType.trim().replaceAll('_', ' ');
        if (normalized.isEmpty) return '';
        return normalized
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
            .join(' ');
    }
  }
  static TextSpan buildHighlightedSpan({
    required String text,
    required String query,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || text.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex < 0) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }

      if (matchIndex > start) {
        spans.add(TextSpan(
          text: text.substring(start, matchIndex),
          style: normalStyle,
        ));
      }

      final matchEnd = matchIndex + trimmedQuery.length;
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchEnd),
        style: highlightStyle,
      ));
      start = matchEnd;
    }

    return TextSpan(children: spans, style: normalStyle);
  }

  static Widget buildAirportResultTitle({
    required AirportLite airport,
    required String query,
    bool showFullDetails = true,
  }) {
    final baseStyle = TextStyle(
      color: AppColor.textColor1,
      fontSize: 10.spV2,
    );

    final highlightStyle = TextStyle(
      color: AppColor.secondaryColor1,
      fontSize: 10.spV2,
      fontWeight: FontWeight.w700,
    );

    return RichText(
      text: TextSpan(
        children: [
          buildHighlightedSpan(
            text: airport.ident,
            query: query,
            normalStyle: baseStyle.copyWith(fontWeight: FontWeight.w600),
            highlightStyle: highlightStyle,
          ),

          // Name is shown, but intentionally NOT highlighted.
          TextSpan(
            text: airport.name.isEmpty ? '' : ' ${airport.name}',
            style: baseStyle,
          ),

          buildHighlightedSpan(
            text: showFullDetails
                ? ', ${airport.municipality}, ${airport.region}'
                : '',
            query: query,
            normalStyle: baseStyle,
            highlightStyle: highlightStyle,
          ),
        ],
      ),
      maxLines: showFullDetails ? 3 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static String airportMatchesSearchSummary(
    AirportLite airport,
    String query,
  ) {
    final typeLabel = _formatAirportTypeLabel(airport.type);
    return typeLabel.isEmpty ? airport.ident : typeLabel;
  }
}