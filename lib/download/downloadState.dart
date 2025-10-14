// video_download_state.dart
import 'package:equatable/equatable.dart';

abstract class VideoDownloadState extends Equatable {
  const VideoDownloadState();
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoDownloadState {}

class VideoDownloading extends VideoDownloadState {
  final double progress;
  final String status;

  VideoDownloading(this.progress, this.status);

  @override
  List<Object> get props => [progress, status]; // important if using Equatable
}

class VideoDownloadFinished extends VideoDownloadState {
  final String path;
  const VideoDownloadFinished(this.path);
}

class VideoDownloadError extends VideoDownloadState {
  final String error;
  const VideoDownloadError(this.error);
}
