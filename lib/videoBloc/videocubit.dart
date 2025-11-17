import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/videoBloc/videoState.dart';

import 'package:path_provider/path_provider.dart';

class VideoCubit extends Cubit<VideoState> {
  final int maxCacheSize = 15;
  final List<String> cachedVideoUrls = [];

  VideoCubit() : super(const VideoState());

  Future<void> fetchVideos() async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('clients')
              .where('editor', isEqualTo: true)
              .get();

      print('Found ${querySnapshot.docs.length} clients with sample videos');

      final List<Map<String, String>> videos = [];

      for (var doc in querySnapshot.docs) {
        List<dynamic> videoUrlList = doc.data()['sampleVideos'] ?? [];

        for (var videoUrl in videoUrlList) {
          String url = videoUrl.toString();
          videos.add({
            'videoUrl': url,
            'firstName': doc.data()['name'] ?? '',
            'description': doc.data()['bio'] ?? '',
          });
        }
      }

      videos.shuffle();
      print('Shuffled videos list FROM EDITORS : $videos');

      // await processVideos(videos);

      emit(
        state.copyWith(
          downloadedVideos: List.from(state.downloadedVideos)..addAll(videos),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
      print("Error fetching videos: $e");
    }
  }

  Future<void> getHomeVideos() async {
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      // 🔥 Fetch the only document inside 'homeVideos'
      final querySnapshot =
          await FirebaseFirestore.instance.collection('homeVideos').get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No documents found in homeVideos collection');
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Assuming only one document exists
      final doc = querySnapshot.docs.first;

      // Extract the list of video URLs
      List<dynamic> videoUrlList = doc.data()['videos'] ?? [];
      List<dynamic> ExpvideoUrlList = doc.data()['exploreVideos'] ?? [];

      print('Found ${videoUrlList.length} home videos');

      final List<Map<String, String>> videos = [];
      final List<Map<String, String>> Explorevideos = [];
      // 🧩 Convert each video URL into a map with extra info
      for (var videoUrl in videoUrlList) {
        String url = videoUrl.toString();
        videos.add({
          'videoUrl': url,
          'firstName': doc.data()['uploaderName'] ?? 'Unknown',
          'description': doc.data()['description'] ?? '',
        });
      }

      for (var videoUrl in ExpvideoUrlList) {
        String url = videoUrl.toString();
        Explorevideos.add({
          'videoUrl': url,
          'firstName': doc.data()['uploaderName'] ?? 'Unknown',
          'description': doc.data()['description'] ?? '',
        });
      }

      Explorevideos.shuffle();
      // 🎲 Shuffle the order for a dynamic feed
      videos.shuffle();

      print('Shuffled home videos list: $videos');

      // 🚀 Emit new state
      emit(
        state.copyWith(
          downloadedVideos: List.from(state.downloadedVideos)..addAll(videos),
          isLoading: false,
        ),
      );

      emit(
        state.copyWith(
          exploreVideos: List.from(state.exploreVideos)..addAll(Explorevideos),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
      print("❌ Error fetching home videos: $e");
    }
  }

  Future<void> processVideos(List<Map<String, String>> videos) async {
    final cacheManager = DefaultCacheManager();

    for (var video in videos) {
      final videoUrl = video['videoUrl']!;
      final fileInfo = await checkCacheFor(videoUrl);

      if (fileInfo == null) {
        print('Downloading video: $videoUrl');
        await cacheManager.downloadFile(videoUrl);
        cachedVideoUrls.add(videoUrl);
      } else {
        print('Video already cached: $videoUrl');
        cachedVideoUrls.add(videoUrl);
      }

      // if (cachedVideoUrls.length > maxCacheSize) {
      //   await deleteOldestCachedVideos(cachedVideoUrls.length - maxCacheSize);
      // }
    }

    emit(
      state.copyWith(
        downloadedVideos: List.from(state.downloadedVideos)..addAll(videos),
        isLoading: false,
      ),
    );
  }

  Future<FileInfo?> checkCacheFor(String url) async {
    final fileInfo = await DefaultCacheManager().getFileFromCache(url);
    if (fileInfo != null) {
      print('Cache hit: $url');
    } else {
      print('Cache miss: $url');
    }
    return fileInfo;
  }

  Future<bool> isCacheEmpty() async {
    // Get the cache folder path manually
    final Directory appDir = await getTemporaryDirectory();
    final Directory cacheDir = Directory('${appDir.path}/libCachedImageData');

    if (!cacheDir.existsSync()) {
      return true; // folder doesn't exist => empty
    }

    return cacheDir.listSync().isEmpty;
  }

  Future<void> deleteOldestCachedVideos(int count) async {
    final cacheManager = DefaultCacheManager();
    final List<String> videosToDelete = cachedVideoUrls.sublist(0, count);

    for (final videoUrl in videosToDelete) {
      await cacheManager.removeFile(videoUrl);
      cachedVideoUrls.remove(videoUrl);
      print('Deleted cached video: $videoUrl');
    }
  }
}
