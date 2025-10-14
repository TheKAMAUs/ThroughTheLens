import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/screen/innerpgs/videoButton.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  late VideoPlayerController controller;
  bool _showOverlay = false;

  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    controller =
        VideoPlayerController.network(widget.url)
          ..setLooping(true) // 🔁 Make video loop forever
          ..setVolume(1.0)
          ..initialize().then((_) {
            setState(() {});
            controller.play();
            _chewieController = ChewieController(
              videoPlayerController: controller,
              autoPlay: true, // Auto play if preloaded
              looping: true,
              showControls: false,
            );
            _isPlaying = true;
          });
  }

  @override
  void dispose() {
    controller.dispose();

    _isDisposed = true; // Set disposed flag to true when disposing

    _chewieController?.dispose();
    super.dispose();
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
    });

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child:
                  _chewieController != null && !_isDisposed
                      ? VisibilityDetector(
                        key: Key('videoPlayerItem_${widget.fordownload}'),
                        onVisibilityChanged: (VisibilityInfo info) {
                          if (info.visibleFraction == 0) {
                            if (!_isDisposed) {
                              controller.pause();
                              setState(() {
                                _isPlaying = false;
                              });
                            }
                          } else if (info.visibleFraction > 0 && !_isPlaying) {
                            if (!_isDisposed) {
                              controller.play();
                              setState(() {
                                _isPlaying = true;
                              });
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),

        onLongPress:
            widget.fordownload == 1 || widget.fordownload == 5
                ? () {
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
                : null,
      ),
    );
  }
}
