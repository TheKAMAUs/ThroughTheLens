import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final double fem;
  final String productName;
  final String description;

  final int index;
  final void Function(int) onPageChanged;
  final bool isPreloaded;

  VideoPlayerItem({
    required this.videoUrl,
    required this.fem,
    required this.productName,
    required this.description,

    required this.index,
    required this.onPageChanged,
    required this.isPreloaded,
  });

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isDisposed = false; // Track if the video player is disposed

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
      'https://firebasestorage.googleapis.com/v0/b/admotion-media-1.firebasestorage.app/o/videos%2FvyAhYZhBda?alt=media&token=a8756f5e-74bb-44ac-b896-e3dc4703c549',
    );
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set disposed flag to true when disposing
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoPlayerController.initialize().then((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          // 👇🏽 Mute if running on web (autoplay allowed only if muted)
          _videoPlayerController.setVolume(kIsWeb ? 0 : 1);

          _videoPlayerController.setLooping(true);
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: widget.isPreloaded, // Auto play if preloaded
            looping: true,
            showControls: false,
            allowMuting: kIsWeb ? true : false,
          );
          _isPlaying = widget.isPreloaded; // Update _isPlaying state
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child:
                _chewieController != null && !_isDisposed
                    ? VisibilityDetector(
                      key: Key('videoPlayerItem_${widget.index}'),
                      onVisibilityChanged: (VisibilityInfo info) {
                        if (info.visibleFraction == 0) {
                          if (!_isDisposed) {
                            _videoPlayerController.pause();
                            setState(() {
                              _isPlaying = false;
                            });
                          }
                        } else if (info.visibleFraction > 0 && !_isPlaying) {
                          if (!_isDisposed) {
                            _videoPlayerController.play();
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
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayPause,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            bottom: 90,
            left: 40,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 60,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    widget.onPageChanged(widget.index);
                    _videoPlayerController.pause();
                    setState(() {
                      _isPlaying = false;
                    });
                  },
                  backgroundColor: const Color.fromARGB(255, 255, 39, 126),
                  icon: const Icon(Icons.info),
                  label: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
