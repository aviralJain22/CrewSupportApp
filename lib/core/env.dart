import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get parseAppId => dotenv.env['PARSE_APP_ID']!;
  static String get parseClientKey => dotenv.env['PARSE_CLIENT_KEY']!;
  static String get parseServerUrl => dotenv.env['PARSE_SERVER_URL']!;
  static String get parseLiveQueryUrl => dotenv.env['PARSE_LIVE_QUERY_URL']!;
}