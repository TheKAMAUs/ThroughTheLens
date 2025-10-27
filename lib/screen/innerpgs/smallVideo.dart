import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

class SmallVideo extends StatefulWidget {
  final String url;
  final int fordownload;
  final bool fromProfile; // 👈 add this flag

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

            // 🌐 Apply customizations for web video elements
            if (kIsWeb) {
              print(
                '🌐 Web detected — scanning for <video> elements (initState)...',
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                final videos = html.document.getElementsByTagName('video');
                print('🎥 Found ${videos.length} video elements (initState).');

                for (var i = 0; i < videos.length; i++) {
                  final node = videos[i];
                  if (node is html.VideoElement) {
                    print('⚙️ [Video #$i] Customizing ${node.src}');
                    node.setAttribute('controlsList', 'nodownload');
                    node.setAttribute('disablePictureInPicture', '');
                    // node.removeAttribute(
                    //   'controls',
                    // ); // optional — hide controls
                  }
                }

                print('✅ Video customization done (initState).');
              });
            }
          })
          .catchError((e) {
            print('❌ Error initializing video: $e');
          });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width:
                widget.fromProfile
                    ? 171
                    : 130, // 👈 Cap the width (you can adjust or use MediaQuery)
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            child:
                _isInitialized &&
                        controller.value.isInitialized &&
                        controller.value.size.isFinite
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio:
                            controller.value.aspectRatio.isFinite
                                ? controller.value.aspectRatio
                                : 16 / 9, // 👈 safe fallback
                        child: VideoPlayer(controller),
                      ),
                    )
                    : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
          ),
        ),

        // Transparent tap overlay for navigation
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push(
                  Routes.nestedExPFullScreenVideo,
                  extra: {'url': widget.url, 'fordownload': widget.fordownload},
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
