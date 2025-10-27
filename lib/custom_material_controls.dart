import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final VoidCallback? onPlayPause;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onMuteToggle;
  final bool isPlaying;
  final bool isMuted;
  final bool isFullscreen;

  const CustomVideoControls({
    super.key,
    required this.controller,
    required this.showControls,
    this.onPlayPause,
    this.onEnterFullscreen,
    this.onMuteToggle,
    required this.isPlaying,
    required this.isMuted,
    this.isFullscreen = false,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  bool _controlsVisible = true;
  late Duration _currentPosition;
  late Duration _videoDuration;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.controller.value.position;
    _videoDuration = widget.controller.value.duration;

    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _currentPosition = widget.controller.value.position;
        _videoDuration = widget.controller.value.duration;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _seekToPosition(double value) {
    final newPosition = value * _videoDuration.inMilliseconds;
    widget.controller.seekTo(Duration(milliseconds: newPosition.round()));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showControls) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top controls
              _buildTopControls(),

              // Center play/pause button
              Expanded(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: widget.onPlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onMuteToggle != null)
            _buildControlButton(
              icon: widget.isMuted ? Icons.volume_off : Icons.volume_up,
              onTap: widget.onMuteToggle,
            ),
          const SizedBox(width: 8),
          if (widget.onEnterFullscreen != null)
            _buildControlButton(
              icon:
                  widget.isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
              onTap: widget.onEnterFullscreen,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: const Color(0xFFFF277E),
                    inactiveTrackColor: Colors.white54,
                    thumbColor: const Color(0xFFFF277E),
                  ),
                  child: Slider(
                    value:
                        _videoDuration.inMilliseconds > 0
                            ? _currentPosition.inMilliseconds /
                                _videoDuration.inMilliseconds
                            : 0.0,
                    onChanged: _seekToPosition,
                    onChangeStart: (_) {
                      if (widget.isPlaying) {
                        widget.controller.pause();
                      }
                    },
                    onChangeEnd: (_) {
                      if (widget.isPlaying) {
                        widget.controller.play();
                      }
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_videoDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottom buttons
          Row(
            children: [
              _buildControlButton(
                icon: widget.isPlaying ? Icons.pause : Icons.play_arrow,
                onTap: widget.onPlayPause,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Custom Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
