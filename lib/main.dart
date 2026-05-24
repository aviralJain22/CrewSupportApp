import 'package:background_fetch/background_fetch.dart';
import 'package:crew_support/core/env.dart';
import 'package:crew_support/services/location_sync_service.dart';
import 'package:crew_support/utils/AppColor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';

const String _bgFetchLastSuccessAtKey = 'debug_bg_fetch_last_success_at';
const String _bgFetchLastEventAtKey = 'debug_bg_fetch_last_event_at';
const String _bgFetchLastSkipAtKey = 'debug_bg_fetch_last_skip_at';

@pragma('vm:entry-point')
Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool isTimeout = task.timeout;

  if (isTimeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  try {
    await _recordBackgroundFetchEvent(
      prefsKey: _bgFetchLastEventAtKey,
      logLabel: 'BackgroundFetch event (headless)',
    );

    final bool didRun = await LocationSyncService.runBestEffortSyncIfEnabled(
      minDistanceM: 300,
      minInterval: const Duration(minutes: 5),
    );

    if (!didRun) {
      await _recordBackgroundFetchEvent(
        prefsKey: _bgFetchLastSkipAtKey,
        logLabel: 'BackgroundFetch skip (headless)',
      );
      debugPrint('[Location][background][headless] BackgroundFetch ran but location sync skipped.');
    } else {
      await _recordBackgroundFetchEvent(
        prefsKey: _bgFetchLastSuccessAtKey,
        logLabel: 'successful background location sync (headless)',
      );
      debugPrint('[Location][background][headless] BackgroundFetch executed location sync.');
    }
  } catch (e) {
    debugPrint('[Location][background][headless] error: $e');
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

Future<void> _recordBackgroundFetchEvent({
  required String prefsKey,
  required String logLabel,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final nowUtc = DateTime.now().toUtc();
  await prefs.setString(prefsKey, nowUtc.toIso8601String());
  debugPrint('[Location][background] Recorded $logLabel at $nowUtc');
}

Future<void> _logBackgroundFetchDebugStatusOnLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final nowUtc = DateTime.now().toUtc();

  final String? lastSuccessRaw = prefs.getString(_bgFetchLastSuccessAtKey);
  final String? lastEventRaw = prefs.getString(_bgFetchLastEventAtKey);
  final String? lastSkipRaw = prefs.getString(_bgFetchLastSkipAtKey);

  DateTime? tryParseUtc(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  final DateTime? lastSuccessAt = tryParseUtc(lastSuccessRaw);
  final DateTime? lastEventAt = tryParseUtc(lastEventRaw);
  final DateTime? lastSkipAt = tryParseUtc(lastSkipRaw);

  String formatGap(DateTime from) {
    final diff = nowUtc.difference(from);
    final totalMinutes = diff.inMinutes;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = totalMinutes % 60;
    return '${days}d ${hours}h ${minutes}m ago';
  }

  if (lastEventAt == null) {
    debugPrint('[Location][background] No recorded BackgroundFetch event found yet on this install/session.');
  } else {
    debugPrint(
      '[Location][background] Last BackgroundFetch event was at $lastEventAt '
      '(${formatGap(lastEventAt)}).',
    );
  }

  if (lastSuccessAt == null) {
    debugPrint('[Location][background] No recorded successful background location sync yet.');
  } else {
    debugPrint(
      '[Location][background] Last successful background location sync was at $lastSuccessAt '
      '(${formatGap(lastSuccessAt)}).',
    );
  }

  if (lastSkipAt != null) {
    debugPrint(
      '[Location][background] Last BackgroundFetch skip was at $lastSkipAt '
      '(${formatGap(lastSkipAt)}).',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait modes only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(fileName: '.env.dev'); // swap for .env.prod via flavors later

  if (!kIsWeb) {
    // Uses native config files (google-services.json / plist)
    await Firebase.initializeApp();

    // Flutter framework errors -> Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Async/Dart errors -> Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize parse
  await Parse().initialize(Env.parseAppId, Env.parseServerUrl,
        clientKey: Env.parseClientKey, liveQueryUrl: Env.parseLiveQueryUrl,
        debug: true);
        //coreStore: CoreStoreMemoryImp()
  
  // Get / create the current Parse Installation (stored locally by SDK)
  final installation = await ParseInstallation.currentInstallation();
  // Optional: subscribe this device to a channel (pub/sub style)
  // Channels are stored on Installation and can be targeted by Cloud Code
  installation.subscribeToChannel('push');

  await installation.save();
  
  // Disable debugPrint in release builds
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  } else {
    // In debug mode, prefix logs with timestamps for better traceability
    final originalDebugPrint = debugPrint;

    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == null) return;

      final now = DateTime.now();
      final formatted =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}.'
          '${now.millisecond.toString().padLeft(3, '0')}';

      originalDebugPrint('[$formatted] $message', wrapWidth: wrapWidth);
    };
  }

  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColor.btnColor1
    ..backgroundColor = AppColor.bgColor1
    ..indicatorColor = AppColor.btnColor1
    ..textColor = AppColor.textColor1
    ..maskColor = AppColor.loadingBarrierColor
    ..userInteractions = true
    ..dismissOnTap = false;

  Future<void> debugPrintParseStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    debugPrint('------ Parse SharedPreferences Dump ------');
    for (var key in keys) {
      final value = prefs.get(key);
      debugPrint('$key: $value');
    }
    debugPrint('------------------------------------------');
  }

  await debugPrintParseStorage();

  await _logBackgroundFetchDebugStatusOnLaunch();

  if (!kIsWeb) {
    debugPrint('[Location][background] Configuring BackgroundFetch...');
    final status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        try {
          debugPrint('[Location][background] BackgroundFetch event received: $taskId');
          await _recordBackgroundFetchEvent(
            prefsKey: _bgFetchLastEventAtKey,
            logLabel: 'BackgroundFetch event',
          );

          final bool didRun = await LocationSyncService.runBestEffortSyncIfEnabled(
            minDistanceM: 300,
            minInterval: const Duration(minutes: 5),
          );

          if (!didRun) {
            await _recordBackgroundFetchEvent(
              prefsKey: _bgFetchLastSkipAtKey,
              logLabel: 'BackgroundFetch skip',
            );
            debugPrint('[Location][background] BackgroundFetch ran but location sync was skipped (disabled / throttled / no permission / no movement).');
          } else {
            await _recordBackgroundFetchEvent(
              prefsKey: _bgFetchLastSuccessAtKey,
              logLabel: 'successful background location sync',
            );
            debugPrint('[Location][background] BackgroundFetch completed and location sync executed.');
          }
        } catch (e) {
          debugPrint('[Location][background] background fetch event error: $e');
        } finally {
          BackgroundFetch.finish(taskId);
        }
      },
      (String taskId) async {
        debugPrint('[Location][background] BackgroundFetch timeout: $taskId (OS killed task before completion)');
        BackgroundFetch.finish(taskId);
      },
    );
    debugPrint('[Location][background] BackgroundFetch configured with status: $status');

    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    debugPrint('[Location][background] BackgroundFetch headless task registered.');
  }

  runApp(const AppRoot());
}