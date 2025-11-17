import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final List<Map<String, String>> downloadedVideos; // Home videos
  final List<Map<String, String>> exploreVideos; // Explore videos
  final bool isLoading;
  final bool hasError;

  const VideoState({
    this.downloadedVideos = const [],
    this.exploreVideos = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  VideoState copyWith({
    List<Map<String, String>>? downloadedVideos,
    List<Map<String, String>>? exploreVideos,
    bool? isLoading,
    bool? hasError,
  }) {
    return VideoState(
      downloadedVideos: downloadedVideos ?? this.downloadedVideos,
      exploreVideos: exploreVideos ?? this.exploreVideos,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object> get props => [
    downloadedVideos,
    exploreVideos,
    isLoading,
    hasError,
  ];
}
