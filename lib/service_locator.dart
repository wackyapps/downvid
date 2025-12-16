// lib/service_locator.dart
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/providers/downloaded_video_list_provider/downloaded_video_list_provider.dart';
import 'package:downvid/services/fdown_service/fbdown_service.dart';
import 'package:downvid/services/object_box/object_box_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. Register ObjectBox FIRST (async)
  final objectBox = await ObjectBox.create();
  getIt.registerSingleton<ObjectBox>(objectBox);

  // 2. Now register everything that depends on ObjectBox
  getIt.registerLazySingleton<FbDownService>(() => FbDownService());

  // 3. Register Provider LAST (it needs ObjectBox)
  getIt.registerLazySingleton<DownloadedVideoListProvider>(
    () => DownloadedVideoListProvider(),
  );

  getIt.registerSingleton<AdProvider>(AdProvider());
  // Load once at startup
  getIt<DownloadedVideoListProvider>().loadDownloadedVideos();

  print('Service Locator: ALL REGISTERED SUCCESSFULLY');
}