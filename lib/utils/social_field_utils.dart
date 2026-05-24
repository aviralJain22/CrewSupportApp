// -----------------------------------------------------------------------------
// Social links (shared across profile screens)
// -----------------------------------------------------------------------------

enum SocialPlatform {
  instagram,
  facebook,
  linkedin,
}

class SocialLinkUtils {
  SocialLinkUtils._();

  static String _ensureHttps(String url) {
    final t = url.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('http://')) return 'https://${t.substring(7)}';
    if (t.startsWith('https://')) return t;
    return 'https://$t';
  }

  static String platformLabel(SocialPlatform p) {
    switch (p) {
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
    }
  }

  /// Converts user input like "@username" or "instagram.com/username" to a canonical profile URL.
  /// Returns empty string if input is empty.
  static String canonicalize({required SocialPlatform platform, required String input}) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    // Accept @username forms
    if (raw.startsWith('@')) {
      final u = raw.substring(1).trim();
      if (u.isEmpty) return '';
      switch (platform) {
        case SocialPlatform.instagram:
          return 'https://www.instagram.com/$u/';
        case SocialPlatform.facebook:
          return 'https://www.facebook.com/$u';
        case SocialPlatform.linkedin:
          return 'https://www.linkedin.com/in/$u/';
      }
    }

    final asUrl = _ensureHttps(raw);
    Uri? uri;
    try {
      uri = Uri.parse(asUrl);
    } catch (_) {
      return asUrl;
    }

    final host = uri.host.toLowerCase();
    final path = uri.path;

    if (platform == SocialPlatform.instagram) {
      if (host.endsWith('instagram.com')) {
        final segs = uri.pathSegments;
        if (segs.isNotEmpty) {
          final username = segs.first;
          if (username.isNotEmpty) {
            return 'https://www.instagram.com/$username/';
          }
        }
        return 'https://www.instagram.com/';
      }
    }

    if (platform == SocialPlatform.facebook) {
      if (host.endsWith('facebook.com') || host.endsWith('fb.com')) {
        // Facebook has multiple URL shapes; keep the full path.
        return 'https://www.facebook.com$path';
      }
    }

    if (platform == SocialPlatform.linkedin) {
      if (host.endsWith('linkedin.com')) {
        // Prefer www + keep /in/... /company/... etc
        return 'https://www.linkedin.com$path';
      }
    }

    return asUrl;
  }

  /// Basic validation: checks scheme + allowed host.
  static bool isValid({required SocialPlatform platform, required String url}) {
    if (url.trim().isEmpty) return false;

    Uri? uri;
    try {
      uri = Uri.parse(url.trim());
    } catch (_) {
      return false;
    }

    if (uri.scheme != 'https') return false;

    final host = uri.host.toLowerCase();
    switch (platform) {
      case SocialPlatform.instagram:
        return host == 'instagram.com' || host == 'www.instagram.com';
      case SocialPlatform.facebook:
        return host == 'facebook.com' ||
            host == 'www.facebook.com' ||
            host == 'fb.com' ||
            host == 'www.fb.com';
      case SocialPlatform.linkedin:
        return host == 'linkedin.com' || host == 'www.linkedin.com';
    }
  }
}