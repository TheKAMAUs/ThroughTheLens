import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/videoplay_Item.dart';
import 'package:memoriesweb/videoBloc/videoState.dart';
import 'package:memoriesweb/videoBloc/videocubit.dart';
import 'dart:html' as html; // 👈 for disabling right-click on web

import 'dart:js_util' as js_util;

class SnapVideoScroll extends StatefulWidget {
  const SnapVideoScroll({Key? key}) : super(key: key);

  @override
  State<SnapVideoScroll> createState() => _SnapVideoScrollState();
}

class _SnapVideoScrollState extends State<SnapVideoScroll> {
  late bool isUserAvailable;
  final fadeController = AnimatedTextController();

  @override
  void initState() {
    super.initState();
    _disableChromeDownloadAndContextMenu();

    // You can add initialization logic here
    // For example:
    // - Fetch initial data
    // - Set up listeners
    // - Initialize animations
    // - Load preferences
  }

  @override
  void dispose() {
    super.dispose();

    // You can add cleanup logic here
    // For example:
    // - Cancel timers
    // - Close streams
    // - Remove listeners
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
    final mediaQuery = MediaQuery.of(context);
    final fem = mediaQuery.size.width / 428;

    isUserAvailable = globalUserDoc != null;
    print('Building SnapVideoScroll Widget, user available: $isUserAvailable');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo on the left with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/IMG_20250930_141707.jpg', // replace with your logo path
                height: 40,
              ),
            ),

            // Show login button only if user is NOT logged in
            if (!isUserAvailable)
              TextButton(
                onPressed: () => context.go(Routes.loginPageRIV),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),

      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.hasError) {
            return const Center(child: Text('Error loading videos 😕'));
          } else if (state.downloadedVideos.isEmpty) {
            return const Center(child: Text('No videos available yet 🚧'));
          }

          // ✅ Shuffle & limit videos
          final List<Map<String, String>> videos = List.from(
            state.downloadedVideos,
          )..shuffle();
          final List<Map<String, String>> limitedVideos =
              videos.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌟 Animated Title Container
                Container(
                  height: 90,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 25,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onBackground, // Adapts to theme
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              FlickerAnimatedText(
                                'When we.... 😎',
                                textStyle: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                ),
                              ),
                              FlickerAnimatedText(
                                'When we were..... 🎥',
                                textStyle: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                ),
                              ),
                              FlickerAnimatedText(
                                'When we were Here! 🚀🔥',
                                textStyle: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                ),
                              ),
                            ],
                            repeatForever: true,
                            pause: const Duration(milliseconds: 1000),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 💬 Persuasive Message Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E2C), Color(0xFF2E2E48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            "🎬 Every great story begins with a single moment — your smile 😊, your friends 🤝, your vibe ✨. "
                            "Don’t let those clips sit in your gallery 📱. "
                            "Upload them and let our editors turn your memories into cinematic magic 🌈💫",
                            speed: const Duration(milliseconds: 35),
                            cursor: "💫",
                          ),
                          TypewriterAnimatedText(
                            "🔥 Your moments deserve more than storage space. "
                            "Turn everyday clips — your laughter 😂, your energy ⚡, your vibe 🎶 — "
                            "into cinematic stories worth sharing 💖🎞️. "
                            "Upload now and let our editors bring your memories to life 🎥✨",
                            speed: const Duration(milliseconds: 35),
                            cursor: "🎥",
                          ),
                          TypewriterAnimatedText(
                            "🌟 Behind every raw clip lies a masterpiece waiting to shine ✨. "
                            "From your smile 😄 to your circle ❤️, your world deserves the spotlight 🎇. "
                            "Upload today — we’ll turn your moments into stories that move hearts 💕 and last forever 📽️🎬",
                            speed: const Duration(milliseconds: 35),
                            cursor: "✨",
                          ),
                        ],
                        totalRepeatCount: 3,
                        pause: const Duration(milliseconds: 12000),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🎬 Video List
                ListView.builder(
                  itemCount: limitedVideos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final videoData = limitedVideos[index];
                    final videoUrl = videoData['videoUrl']!;
                    final productName = videoData['firstName']!;
                    final description = videoData['description']!;

                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: VideoPlayerItem(
                        videoUrl: videoUrl,
                        fem: fem,
                        productName: productName,
                        description: description,
                        index: index,
                        onPageChanged: (_) {},
                        isPreloaded: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
