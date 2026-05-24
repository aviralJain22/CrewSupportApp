// On mobile/desktop: use the real Isar-backed implementation.
// On web: use the stub so dart2js never sees the 64-bit integer literals
// in airport_code_model.g.dart that are unrepresentable in JavaScript.
export 'airport_code_model.dart'
    if (dart.library.html) 'airport_platform_web.dart';
