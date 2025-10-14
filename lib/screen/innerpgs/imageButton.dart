import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart'; // same as before
// import your OrderServiceRepo & OrderModel if needed

class ImageOptionsSheet extends StatefulWidget {
  final String imageUrl;
  final int fordownload;

  const ImageOptionsSheet({
    super.key,
    required this.imageUrl,
    required this.fordownload,
  });

  @override
  State<ImageOptionsSheet> createState() => _ImageOptionsSheetState();
}

class _ImageOptionsSheetState extends State<ImageOptionsSheet> {
  double? _progress;
  String _status = '';
  bool _isDownloading = false;
  bool _isDownloadFinish = false;

  final OrderServiceRepo order = OrderServiceRepo();
  List<OrderModel>? orders;

  Future<void> orderss(String targetUrl) async {
    final orderss = await order.getOrderWithUrl(targetUrl);
    setState(() {
      orders = orderss;
    });
  }

  void _downloadImage() async {
    FileDownloader.downloadFile(
      url: widget.imageUrl,
      name:
          "memoriesweb-${orders != null && orders!.isNotEmpty ? orders![0].title : 'image'}.jpg",
      downloadDestination: DownloadDestinations.publicDownloads,
      subPath: "memoriesweb",
      notificationType: NotificationType.all,
      onProgress: (name, progress) {
        setState(() {
          _progress = progress;
          _status = 'Downloading: $progress%';
          _isDownloading = true;
        });
      },
      onDownloadCompleted: (path) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Image download finished.")),
          ),
        );
        setState(() {
          _progress = null;
          _status = 'Image saved to: $path';
          _isDownloading = false;
          _isDownloadFinish = true;
        });
      },
      onDownloadError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text("Download failed."))),
        );
        setState(() {
          _progress = null;
          _status = 'Download error: $error';
          _isDownloading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading) ...[
            LinearProgressIndicator(
              value: _progress != null ? _progress! / 100 : 0,
            ),
            const SizedBox(height: 8),
            Text(_status, style: const TextStyle(fontSize: 12)),
          ] else if (!_isDownloadFinish) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Download Image"),
              onPressed: () {
                _downloadImage();
                if (widget.fordownload == 1) {
                  orderss(widget.imageUrl);
                }
              },
            ),
          ],
          if (_isDownloadFinish) ...[
            const SizedBox(height: 12),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }
}
