import 'package:flutter/material.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenVideoPage.dart';
import 'package:video_player/video_player.dart';

class SmallVideo extends StatefulWidget {
  final String url;
  final int fordownload; // 👈 added int parameter
  const SmallVideo({Key? key, required this.url, required this.fordownload})
    : super(key: key);

  @override
  State<SmallVideo> createState() => _SmallVideoState();
}

class _SmallVideoState extends State<SmallVideo> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the first frame
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.black,
              ),
              child:
                  controller.value.isInitialized
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: VideoPlayer(controller),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FullScreenVideoPage(
                            url: widget.url,
                            fordownload: widget.fordownload,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
