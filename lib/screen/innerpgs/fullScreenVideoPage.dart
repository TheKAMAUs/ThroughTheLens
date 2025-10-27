// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:io' show Platform; // For mobile runtime checks
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/transactions_service_repo.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/videoButton.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:js_util' as js_util;
// Web-only import
import 'dart:html' as html;

class FullScreenVideoPage extends StatefulWidget {
  final String url;
  final int fordownload;

  const FullScreenVideoPage({
    Key? key,
    required this.url,
    required this.fordownload,
  }) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  final TransServiceRepo trans = TransServiceRepo();

  late VideoPlayerController controller;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool _showOverlay = false;

  // 🧩 Inside your State class
  @override
  void initState() {
    super.initState();

    // Disable Chrome download + context menu
    _disableChromeDownloadAndContextMenu();

    // Initialize your video controller as usual
    print('🎬 Attempting to load video from: ${widget.url}');
    if (widget.url.isEmpty) print('❌ ERROR: widget.url is empty!');

    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        if (!mounted) return; // <--- this prevents the error

        setState(() {});
        controller.play();
        _chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: true,
          showControls: false,
        );
      });
  }

  @override
  void dispose() {
    controller.pause();

    _enableChromeDownloadAndContextMenu(); // restore normal behavior
    controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  /// 🚫 Disable Chrome's download button + right-click context menu
  /// 🚫 Disable Chrome's download button + right-click context menu
  void _disableChromeDownloadAndContextMenu() {
    try {
      // Block right-click / long-press globally (entire screen, not just video)
      html.document.body?.addEventListener('contextmenu', (event) {
        event.preventDefault(); // 👈 disables right-click anywhere
      });

      // Optional: block text/image selection and dragging too
      html.document.body?.style.userSelect = 'none';
      html.document.body?.style.pointerEvents = 'auto';
      html.document.onDragStart.listen((event) => event.preventDefault());

      // Disable Chrome "download" and PiP controls
      final elements = html.document.getElementsByTagName('video');
      for (final node in elements) {
        if (node is html.VideoElement) {
          node.controls = true;
          node.controlsList?.add('nodownload');
          js_util.setProperty(node, 'disablePictureInPicture', true);
        }
      }

      print('🚫 Chrome download + context menu disabled globally.');
    } catch (e) {
      print('⚠️ Could not disable Chrome download: $e');
    }
  }

  /// 🔓 Re-enable Chrome download + right-click
  void _enableChromeDownloadAndContextMenu() {
    try {
      // Restore body event handlers
      html.document.body?.removeEventListener('contextmenu', (event) {
        event.preventDefault();
      });
      html.document.body?.style.userSelect = 'auto';
      html.document.body?.style.pointerEvents = 'auto';

      // Re-enable video controls
      final elements = html.document.getElementsByTagName('video');
      for (final node in elements) {
        if (node is html.VideoElement) {
          node.controlsList?.remove('nodownload');
          js_util.setProperty(node, 'disablePictureInPicture', false);
        }
      }

      print('✅ Chrome download + context menu re-enabled globally.');
    } catch (e) {
      print('⚠️ Could not re-enable Chrome download: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _showOverlay = true;
      } else {
        controller.play();
        _showOverlay = false;
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        onLongPress:
            widget.fordownload == 1 || widget.fordownload == 5
                ? () {
                  if (kIsWeb) {
                    // 🖥️ Web-specific behavior
                    setState(() {
                      // _enableChromeDownloadAndContextMenu();
                      _showDownloadAppDialog(context);
                    });
                  } else {
                    // 📱 Mobile or desktop (non-web) behavior
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder:
                          (context) => VideoOptionsSheet(
                            videoUrl: widget.url,
                            fordownload: widget.fordownload,
                          ),
                    );
                  }
                }
                : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child:
                  _chewieController != null && !_isDisposed
                      ? VisibilityDetector(
                        key: Key('videoPlayerItem_${widget.fordownload}'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction == 0) {
                            if (!_isDisposed) {
                              controller.pause();
                              setState(() => _isPlaying = false);
                            }
                          } else if (info.visibleFraction > 0 && !_isPlaying) {
                            if (!_isDisposed) {
                              controller.play();
                              setState(() => _isPlaying = true);
                            }
                          }
                        },
                        child: Chewie(controller: _chewieController!),
                      )
                      : const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 249, 65, 185),
                        ),
                      ),
            ),
            if (_showOverlay || !controller.value.isPlaying)
              const Icon(Icons.play_arrow, size: 120, color: Colors.white70),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDownloadAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Download on Mobile 📱",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "Downloading videos is only available in our mobile app.\n\n"
          "Get the app now to enjoy full features!",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              const appUrl =
                  "https://play.google.com/store/apps/details?id=com.yourcompany.yourapp";
              // ignore: undefined_prefixed_name
              html.window.open(appUrl, "_blank"); // ✅ Opens in new tab on web
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text("Get the App"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    },
  );
}
