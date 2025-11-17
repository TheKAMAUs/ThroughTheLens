import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

class SmallVideo extends StatefulWidget {
  final String url;
  final int fordownload;
  final bool fromProfile;

  const SmallVideo({
    Key? key,
    required this.url,
    required this.fordownload,
    this.fromProfile = false,
  }) : super(key: key);

  @override
  State<SmallVideo> createState() => _SmallVideoState();
}

class _SmallVideoState extends State<SmallVideo> {
  late VideoPlayerController controller;
  bool _isInitialized = false;
  bool _showDelete = false; // 👈 Track if delete button is visible
  bool _videoDeleted = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.url)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }

            // 🌐 Web-specific setup
            if (kIsWeb) {
              Future.delayed(const Duration(milliseconds: 500), () {
                final videos = html.document.getElementsByTagName('video');
                for (var i = 0; i < videos.length; i++) {
                  final node = videos[i];
                  if (node is html.VideoElement) {
                    node.setAttribute('controlsList', 'nodownload');
                    node.setAttribute('disablePictureInPicture', '');
                  }
                }
              });
            }
          })
          .catchError((e) {
            print('❌ Error initializing video: $e');
            if (mounted) {
              setState(() => _videoDeleted = true);
            }
          });

    // Listen for runtime errors during playback
    controller.addListener(() {
      if (controller.value.hasError && mounted) {
        setState(() => _videoDeleted = true);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    try {
      // Reference the file from its Firebase Storage URL
      final ref = FirebaseStorage.instance.refFromURL(widget.url);

      // Delete the video from Firebase Storage
      await ref.delete(); 

      // Hide delete button and show success message
      setState(() => _showDelete = false);

      // Show a success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "✅ Video deleted successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );

      print("🗑 Successfully deleted video: ${widget.url}");
    } catch (e) {
      // Show an error SnackBar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Failed to delete video: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );

      print("❌ Error deleting video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: widget.fromProfile ? 171 : 130,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            child:
                _videoDeleted
                    ? Container(
                      color: Colors.black12,
                      child: const Center(
                        child: Text(
                          "🗑 Deleted",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                    : _isInitialized &&
                        controller.value.isInitialized &&
                        controller.value.size.isFinite
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio:
                            controller.value.aspectRatio.isFinite
                                ? controller.value.aspectRatio
                                : 16 / 9,
                        child: VideoPlayer(controller),
                      ),
                    )
                    : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
          ),
        ),

        // Overlay for tap and long-press
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // ✅ Prevent navigation if the video was deleted or failed to load
                if (_videoDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "🗑 This video has been deleted.",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return; // stop execution — don't navigate
                }

                // ✅ Only navigate if video exists
                context.push(
                  RoutesEnum.nestedExpFullScreenVideo.path,
                  extra: {'url': widget.url, 'fordownload': widget.fordownload},
                );
              },
              onLongPress:
                  widget.fromProfile
                      ? () {
                        setState(() => _showDelete = !_showDelete);
                      }
                      : null, // If not from profile, long press does nothing
            ),
          ),
        ),

        // 🗑 Delete button overlay
        if (_showDelete)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
              onPressed: _handleDelete,
            ),
          ),
      ],
    );
  }
}
