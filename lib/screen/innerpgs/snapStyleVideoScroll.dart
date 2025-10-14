import 'dart:io';

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

class SnapVideoScroll extends StatelessWidget {
  final PageController _pageController = PageController();

  SnapVideoScroll({Key? key}) : super(key: key);

  late bool isUserAvailable;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final fem = mediaQuery.size.width / 428;

    isUserAvailable = globalUserDoc != null;
    print('Building SnapVideoScroll Widget, user available: $isUserAvailable');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            print('Loading videos...');
            return Center(child: CircularProgressIndicator());
          } else if (state.hasError) {
            print('Error loading videos');
            return Center(child: Text('Error loading videos'));
          } else if (state.downloadedVideos.isEmpty) {
            print('No downloaded videos found. Showing placeholder.');
            return Center(child: Text('No videos available'));
          }

          final List<Map<String, String>> shuffledVideos = List.from(
            state.downloadedVideos,
          )..shuffle();

          return PageView.builder(
            controller: _pageController,
            itemCount: shuffledVideos.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final videoData = shuffledVideos[index];
              final videoUrl = videoData['videoUrl']!;
              final productName = videoData['firstName']!;
              final description = videoData['description']!;

              print('Building VideoPlayerItem for index: $index');

              return FutureBuilder<File>(
                future: DefaultCacheManager().getSingleFile(videoUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading video'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('Video not found in cache'));
                  } else {
                    final file = snapshot.data!;
                    return VideoPlayerItem(
                      videoUrl: file.path, // Use the cached file path
                      fem: fem,
                      productName: productName,
                      description: description,

                      index: index,
                      onPageChanged: (int newIndex) {
                        print(
                          'Page changed callback triggered for index $index',
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _pageController.animateToPage(
                            newIndex,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      isPreloaded:
                          true, // Assuming videos are preloaded for simplicity
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
