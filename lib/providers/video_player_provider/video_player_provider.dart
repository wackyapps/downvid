// providers/video_player_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider with ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  String? get errorMessage => _errorMessage;

  Future<void> play(String videoPath) async {
    // 1. Reset previous state
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _errorMessage = null;
    notifyListeners();

    final file = File(videoPath);

    // 2. Critical: Check if file really exists and is readable
    if (!await file.exists()) {
      _errorMessage = "File not found:\n$videoPath";
      notifyListeners();
      return;
    }

    // Optional: check file size > 0
    final length = await file.length();
    if (length == 0) {
      _errorMessage = "File is empty (0 bytes)";
      notifyListeners();
      return;
    }

    debugPrint("Playing existing file: $videoPath (${length ~/ 1024} KB)");

    try {
      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      _isInitialized = true;
      await _controller!.play();
      _errorMessage = null;
      notifyListeners();
    } on PlatformException catch (e) {
      _errorMessage = "Failed to play video:\n${e.message}";
      notifyListeners();
      rethrow;
    } catch (e) {
      _errorMessage = "Unexpected error: $e";
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _controller?.pause();
    notifyListeners();
  }

  Future<void> toggle() async {
    if (isPlaying) {
      await pause();
    } else {
      await _controller?.play();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}