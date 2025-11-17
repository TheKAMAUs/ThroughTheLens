import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:memoriesweb/navigation/routes.dart';

import 'package:video_player/video_player.dart';

import 'package:visibility_detector/visibility_detector.dart';
import 'dart:html' as html; // 👈 for disabling right-click on web

import 'dart:js_util' as js_util;
// Web-only import

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final double fem;
  final String productName;
  final String description;
  final int index;
  final void Function(int) onPageChanged;
  final bool isPreloaded;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    required this.fem,
    required this.productName,
    required this.description,
    required this.index,
    required this.onPageChanged,
    required this.isPreloaded,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool _isMuted = kIsWeb;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _videoPlayerController.dispose();
    } catch (e) {
      print('⚠️ Controller already disposed: $e');
    }
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoUrl.isEmpty) return;

    try {
      await _videoPlayerController.initialize();
      if (!mounted || _isDisposed) return;

      _videoPlayerController
        ..setLooping(true)
        ..setVolume(_isMuted ? 0 : 1);

      if (mounted && !_isDisposed) {
        setState(() => _isInitialized = true);
      }

      if (widget.isPreloaded && !_isDisposed) {
        _videoPlayerController.play();
        _isPlaying = true;
      }

      if (kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed) return;
          final videos = html.document.getElementsByTagName('video');
          for (var node in videos) {
            if (node is html.VideoElement) {
              node.setAttribute('controlsList', 'nodownload');
              node.setAttribute('disablePictureInPicture', '');
            }
          }
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        print('❌ Video initialization failed: $e');
      }
    }
  }

  void _togglePlayPause() {
    if (_isDisposed || !_isInitialized) return;

    if (_isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }

    if (mounted && !_isDisposed) setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleMute() {
    if (_isDisposed || !_isInitialized) return;

    _isMuted = !_isMuted;
    _videoPlayerController.setVolume(_isMuted ? 0 : 1);

    if (mounted && !_isDisposed) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const Center(
        child: Text(
          "⚠️ Video disposed",
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child:
                    !_isDisposed && _isInitialized
                        ? VisibilityDetector(
                          key: Key('videoPlayerItem_${widget.index}'),
                          onVisibilityChanged: (info) {
                            if (_isDisposed || !_isInitialized) return;

                            if (info.visibleFraction == 0 && _isPlaying) {
                              _videoPlayerController.pause();
                              if (mounted && !_isDisposed) {
                                setState(() => _isPlaying = false);
                              }
                            } else if (info.visibleFraction > 0 &&
                                !_isPlaying &&
                                widget.isPreloaded) {
                              _videoPlayerController.play();
                              if (mounted && !_isDisposed) {
                                setState(() => _isPlaying = true);
                              }
                            }
                          },
                          child: VideoPlayer(_videoPlayerController),
                        )
                        : const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 249, 65, 185),
                          ),
                        ),
              ),

              // Tap handler
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_isDisposed) return;
                    _videoPlayerController.pause();
                    if (mounted && !_isDisposed) {
                      setState(() => _isPlaying = false);
                    }

                    context.push(
                      RoutesEnum.nestedExpFullScreenVideo.path,
                      extra: {'url': widget.videoUrl, 'fordownload': 6},
                    );
                  },
                  onDoubleTap: _togglePlayPause,
                ),
              ),

              // Overlay play button
              if (!_isDisposed && !_isPlaying && _isInitialized)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),

              // // Info button
              // Positioned(
              //   bottom: 90,
              //   left: 40,
              //   child: FloatingActionButton.extended(
              //     heroTag: null,
              //     onPressed: () {
              //       widget.onPageChanged(widget.index);
              //       _videoPlayerController.pause();
              //       if (mounted) setState(() => _isPlaying = false);
              //     },
              //     backgroundColor: const Color.fromARGB(255, 255, 39, 126),
              //     icon: const Icon(Icons.info),
              //     label: SizedBox(
              //       width: 120,
              //       child: Text(
              //         widget.productName,
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //         maxLines: 2,
              //         overflow: TextOverflow.ellipsis,
              //       ),
              //     ),
              //   ),
              // ),

              // Mute button (mobile only)
              if (!kIsWeb && !_isDisposed)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
