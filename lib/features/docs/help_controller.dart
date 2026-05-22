import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

/// Model for one Help/Guide entry.
class HelpItem {
  final String title;     // Panel header text
  final String? body;     // Optional supporting text
  final String? videoUrl; // Network MP4 URL

  const HelpItem({required this.title, this.body, this.videoUrl});
}

/// GetX controller for the Help/Guide screen.
/// - Holds the list of items (mirrors legacy order & content)
/// - Lazily initializes one VideoPlayer + Chewie per expanded panel
/// - Properly disposes everything on close
class HelpController extends GetxController {
  /// Exact order & titles (and URLs) as in the legacy Guide_Screen.dart.
  final items = const <HelpItem>[
    HelpItem(
      title: 'How to create a Profile?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited-Crew-Support-How-To-Create-A-Profile-1.mp4',
    ),
    HelpItem(
      title: 'How to update a Profile?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited-Crew-Support-How-to-Update-Profile-1.mp4',
    ),
    HelpItem(
      title: 'How to Manage Availability?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited-Crew-Support-How-to-manage-Availability-1.mp4',
    ),
    HelpItem(
      title: 'How to create a Trip?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited-Crew-Support-How-to-create-a-Trip-1.mp4',
    ),
    HelpItem(
      title: 'How to add Type Rating?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited%20-%20Crew%20Support%20-%20Add%20Type%20Rating.mp4',
    ),
    HelpItem(
      title: 'How to edit Type Rating?',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited%20-%20Crew%20Support%20-%20Edit%20Type%20Rating.mp4',
    ),
    HelpItem(
      title: 'Edit Expired Trip Dates',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited%20-%20Crew%20Support%20-%20Edit%20Trip.mp4',
    ),
    HelpItem(
      title: 'How To Add New Crew Member',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Edited%20-%20Crew%20Support%20-%20Add%20Crew%20Member.mp4',
    ),
    HelpItem(
      title: 'How To Create Direct Trip',
      videoUrl:
          'https://crewsupport.net/wp-content/uploads/2022/08/Updated%20-%20New%20Crew%20Support%20-%20How%20to%20create%20a%20direct%20trip%20(1).mp4',
    ),
  ].obs;

  /// Per-index controllers/state.
  final videoControllers = <int, VideoPlayerController>{}.obs; // RxMap
  final chewieControllers = <int, ChewieController>{}.obs;     // RxMap
  final loading = <int, bool>{}.obs;                           // RxMap

  /// Lazily initialize the video at [index] (no-op if already initialized).
  Future<void> ensureInitialized(int index) async {
    if (chewieControllers.containsKey(index) || videoControllers.containsKey(index)) {
      return; // already initialized
    }
    final url = items[index].videoUrl;
    if (url == null || url.trim().isEmpty) return;

    loading[index] = true; // triggers Obx
    try {
      final vp = VideoPlayerController.network(url);
      await vp.initialize();

      final chewie = ChewieController(
        videoPlayerController: vp,
        autoPlay: false, // legacy behavior
        looping: true,   // legacy behavior
        allowMuting: true,
        allowFullScreen: true,
      );

      videoControllers[index] = vp;      // triggers Obx
      chewieControllers[index] = chewie; // triggers Obx
    } catch (e) {
      if (kDebugMode) debugPrint('Video init failed for index $index: $e');
    } finally {
      loading[index] = false; // triggers Obx
    }
  }

  ChewieController? chewieFor(int index) => chewieControllers[index];

  @override
  void onClose() {
    // Dispose all players to avoid leaks.
    for (final c in chewieControllers.values) {
      c.dispose();
    }
    for (final v in videoControllers.values) {
      v.dispose();
    }
    super.onClose();
  }
}