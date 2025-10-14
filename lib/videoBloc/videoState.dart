import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final List<Map<String, String>> downloadedVideos;
  final bool isLoading;
  final bool hasError;

  const VideoState({
    this.downloadedVideos = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  VideoState copyWith({
    List<Map<String, String>>? downloadedVideos,
    bool? isLoading,
    bool? hasError,
  }) {
    return VideoState(
      downloadedVideos: downloadedVideos ?? this.downloadedVideos,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object> get props => [downloadedVideos, isLoading, hasError];
}
