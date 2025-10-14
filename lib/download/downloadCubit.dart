// video_download_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/download/downloadState.dart';
import 'package:memoriesweb/model/ordermodel.dart';

class VideoDownloadCubit extends Cubit<VideoDownloadState> {
  final OrderServiceRepo orderRepo;
  List<OrderModel>? orders;

  VideoDownloadCubit(this.orderRepo) : super(VideoInitial());

  Future<void> startDownload(String videoUrl, int fordownload) async {
    if (fordownload == 1) {
      orders = await orderRepo.getOrderWithUrl(videoUrl);
    }

    FileDownloader.downloadFile(
      url: videoUrl,
      name:
          orders != null && orders!.isNotEmpty
              ? "memoriesweb-${orders![0].title}.mp4"
              : "memoriesweb.mp4",
      downloadDestination: DownloadDestinations.publicDownloads,
      subPath: "memoriesweb",
      notificationType: NotificationType.all,
      onProgress: (name, progress) {
        emit(VideoDownloading(progress, "Downloading: $progress%"));
      },
      onDownloadCompleted: (path) {
        emit(VideoDownloadFinished(path));
      },
      onDownloadError: (error) {
        emit(VideoDownloadError(error.toString()));
      },
    );
  }
}
