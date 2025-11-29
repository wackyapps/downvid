// downloaded_video_list_provider.dart
import 'dart:io';
import 'package:downvid/models/video_downloaded_model/video_downloaded_model.dart';
import 'package:downvid/service_locator.dart';
import 'package:downvid/services/object_box/object_box_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';

class DownloadedVideoListProvider extends ChangeNotifier {
  // final ObjectBox _objectBox = GetIt.instance<ObjectBox>();

  List<VideoDownloadedModel> _downloadedVideos = [];
  List<VideoDownloadedModel> get downloadedVideos => _downloadedVideos;

  // Track which videos are pending deletion (for UNDO)
  final Set<VideoDownloadedModel> _pendingDelete = {};

  // Prevent reload from overriding UNDO
  bool _hasPendingUndo = false;

void loadDownloadedVideos({bool forceRefresh = false}) {
    if (forceRefresh || !_hasPendingUndo) {
      final videos = getIt<ObjectBox>().getAllDownloadedVideos();
      _downloadedVideos = videos;
      _pendingDelete.clear();
      _hasPendingUndo = false;
    }
    notifyListeners();
  }

  Future<void> deleteVideo(VideoDownloadedModel video, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final box = getIt<ObjectBox>().store.box<VideoDownloadedModel>();

    // 1. Optimistic remove from UI
    _downloadedVideos.remove(video);
    _pendingDelete.add(video);
    _hasPendingUndo = true; // ← BLOCK auto-reload
    notifyListeners();

    // 2. Show UNDO
    scaffold.showSnackBar(
      SnackBar(
        content: const Text("Video deleted"),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () {
            // UNDO: Bring back in list
            if (_pendingDelete.remove(video)) {
              _downloadedVideos.add(video);
              _hasPendingUndo = _downloadedVideos.any((v) => _pendingDelete.contains(v));
              notifyListeners();
            }
          },
        ),
      ),
    );

    // 3. Wait 4 seconds → commit delete if no undo
    await Future.delayed(const Duration(seconds: 4));

    if (!scaffold.mounted) return;

    // If user didn't press UNDO → actually delete
    if (_pendingDelete.contains(video)) {
      try {
        final file = File(video.videoPath);
        if (await file.exists()) await file.delete();

        box.remove(video.id);
        _pendingDelete.remove(video);
        _hasPendingUndo = _downloadedVideos.any((v) => _pendingDelete.contains(v));

        debugPrint("Video permanently deleted: ${video.title}");
      } catch (e) {
        debugPrint("Delete failed: $e");
        // Revert on failure
        if (!_downloadedVideos.contains(video)) {
          _downloadedVideos.add(video);
          _pendingDelete.remove(video);
          _hasPendingUndo = false;
          notifyListeners();
        }
        scaffold.showSnackBar(const SnackBar(content: Text("Delete failed")));
      }
    }
  }

  // Optional: Call this when leaving screen or app resume
  void clearPendingOperations() {
    _pendingDelete.clear();
    _hasPendingUndo = false;
  }
}