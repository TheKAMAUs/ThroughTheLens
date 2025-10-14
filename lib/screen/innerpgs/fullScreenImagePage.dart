import 'package:flutter/material.dart';
import 'package:memoriesweb/screen/innerpgs/imageButton.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final int fordownload;

  const FullScreenImagePage({
    Key? key,
    required this.imageUrl,
    required this.fordownload,
  }) : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  bool _showOverlay = false;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.white);
                },
              ),
            ),
            if (_showOverlay)
              const Icon(Icons.visibility, size: 120, color: Colors.white70),
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
                        (context) => ImageOptionsSheet(
                          imageUrl: widget.imageUrl,
                          fordownload: widget.fordownload,
                        ),
                  );
                }
                : null,
      ),
    );
  }
}
