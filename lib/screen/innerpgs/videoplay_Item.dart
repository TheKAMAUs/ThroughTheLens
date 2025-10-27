import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/custom_material_controls.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenVideoPage.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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

    if (kIsWeb) {
      // disable right-click globally on web
      // html.document.onContextMenu.listen((event) => event.preventDefault());
    }
    // _disableChromeDownloadAndContextMenu();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoPlayerController.dispose();
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

      // 👇 Disable download and PiP on web
      if (kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final videos = html.document.getElementsByTagName('video');
          print('🎥 Found ${videos.length} video elements (post-frame).');

          for (int i = 0; i < videos.length; i++) {
            final node = videos[i];
            if (node is html.VideoElement) {
              print('⚙️ [Video #$i] Customizing ${node.src}');
              node.setAttribute('controlsList', 'nodownload');
              node.setAttribute('disablePictureInPicture', '');

              // node.removeAttribute('controls'); // Uncomment if you want to hide controls
            }
          }
          print('✅ Video customization done after frame render.');
        });
      }

      setState(() {
        _isInitialized = true;
      });

      if (widget.isPreloaded) {
        _videoPlayerController.play();
        _isPlaying = true;
      }
    } catch (e) {
      print('Video initialization failed: $e');
    }
  }

  void _togglePlayPause() {
    if (_isDisposed || !_isInitialized) return;

    if (_isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }

    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleMute() {
    if (_isDisposed || !_isInitialized) return;

    _isMuted = !_isMuted;
    _videoPlayerController.setVolume(_isMuted ? 0 : 1);

    if (mounted) setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Video Player
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child:
                    _isInitialized && !_isDisposed
                        ? VisibilityDetector(
                          key: Key('videoPlayerItem_${widget.index}'),
                          onVisibilityChanged: (info) {
                            if (_isDisposed || !_isInitialized) return;

                            if (info.visibleFraction == 0 && _isPlaying) {
                              _videoPlayerController.pause();
                              if (mounted) setState(() => _isPlaying = false);
                            } else if (info.visibleFraction > 0 &&
                                !_isPlaying &&
                                widget.isPreloaded) {
                              _videoPlayerController.play();
                              if (mounted) setState(() => _isPlaying = true);
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

              // Tap areas
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_isDisposed) return;
                    _videoPlayerController.pause();
                    if (mounted) setState(() => _isPlaying = false);

                    context.push(
                      Routes.nestedExPFullScreenVideo,
                      extra: {'url': widget.videoUrl, 'fordownload': 6},
                    );
                  },
                  onDoubleTap: _togglePlayPause,
                ),
              ),

              // Play/Pause overlay
              if (!_isPlaying && _isInitialized)
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

              // Info button
              Positioned(
                bottom: 90,
                left: 40,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    widget.onPageChanged(widget.index);
                    _videoPlayerController.pause();
                    if (mounted) setState(() => _isPlaying = false);
                  },
                  backgroundColor: const Color.fromARGB(255, 255, 39, 126),
                  icon: const Icon(Icons.info),
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      widget.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              // Mute button (mobile only)
              if (!kIsWeb)
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
