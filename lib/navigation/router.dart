import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoriesweb/auth/authCubit.dart';
import 'package:memoriesweb/login/loginRivaan.dart';
import 'package:memoriesweb/navigation/main_screen.dart';
import 'package:memoriesweb/navigation/routes.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:memoriesweb/auth_wrapper.dart';

import 'package:memoriesweb/screen/explore_page.dart';
import 'package:memoriesweb/screen/forClients/assignedOrders.dart';
import 'package:memoriesweb/screen/forEditors/acceptedorders.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenImagePage.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenVideoPage.dart';

import 'package:memoriesweb/screen/innerpgs/profileEditPage.dart';
import 'package:memoriesweb/screen/innerpgs/snapStyleVideoScroll.dart';
import 'package:memoriesweb/screen/innerpgs/userDetailPage.dart';
import 'package:memoriesweb/screen/profile_page.dart';
import 'package:memoriesweb/screen/upload_page.dart';
import 'package:memoriesweb/screen/videos.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      // Routes.home,
      Routes.authWrapper,

  debugLogDiagnostics: true,

  // redirect: (BuildContext context, GoRouterState state) {
  //   final authState = context.read<AuthCubit>().state;

  //   print('🧭 [GoRouter Redirect]');
  //   print('→ Current path: ${state.fullPath}');
  //   print(
  //     '→ AuthState: isLoading=${authState.isLoading}, isLoggedIn=${authState.isLoggedIn}, uid=${authState.uid}',
  //   );

  //   // 🕒 Wait until we know if the user is logged in
  //   if (authState.isLoading) {
  //     print('⏳ Still loading auth state, skipping redirect.');
  //     return null;
  //   }

  //   final isAuthPage =
  //       state.fullPath == Routes.loginPageRIV ||
  //       state.fullPath == Routes.authWrapper;

  //   // 🔒 Not logged in → redirect to login
  //   if (!authState.isLoggedIn && !isAuthPage) {
  //     print('🚫 User not logged in → redirecting to ${Routes.authWrapper}');
  //     return Routes.home;
  //   }

  //   // 🏠 Logged in and trying to access login/auth → go home
  //   if (authState.isLoggedIn && isAuthPage) {
  //     print('✅ User is logged in → redirecting to ${Routes.home}');
  //     return Routes.home;
  //   }

  //   // ✅ No redirect needed
  //   print('➡️ No redirect required, staying on ${state.fullPath}');
  //   return null;
  // },
  routes: [
    GoRoute(
      path: Routes.authWrapper,
      builder: (context, state) => AuthWrapper(),
    ),
    GoRoute(
      path: Routes.loginPageRIV,
      builder: (context, state) => LoginScreen(),
    ),

    GoRoute(
      path: Routes.videoEdited, // e.g. "/videoEdited/:edited"
      builder: (context, state) {
        final editedParam =
            state.pathParameters['edited']; // Expect "true" or "false"
        final edited = editedParam == 'true';

        // Extract the onDone function from state.extra
        final void Function(String path, String fileName)? onDone =
            state.extra as void Function(String, String)?;

        print('Full location: ${state.uri}');
        print('Path params: ${state.pathParameters}');
        print('Extra: ${state.extra}');
        print('Extra type: ${state.extra.runtimeType}');

        return VideosPage(edited: edited, onDone: onDone);
      },
    ),

    GoRoute(
      path: Routes.videoComplaint, // e.g. "/videoEdited/:complaint"
      builder: (context, state) {
        final complaint = state.pathParameters['complaint'] == 'true';
        // Extract the onDone function from state.extra
        final void Function(String path, String fileName)? onComplaint =
            state.extra as void Function(String, String)?;

        print('Full location: ${state.uri}');
        print('Path params: ${state.pathParameters}');
        print('Extra: ${state.extra}');
        print('Extra type: ${state.extra.runtimeType}');

        return VideosPage(complaint: complaint, onComplaint: onComplaint);
      },
    ),

    GoRoute(
      path: Routes.videos, // Nested route under SplashScreen
      builder: (context, state) => const VideosPage(),
    ),

    GoRoute(
      path: Routes.uploadwitheditor, // '/upload/:assignedEditorId'
      builder: (context, state) {
        final editorId = state.pathParameters['assignedEditorId'];
        print('🔵 Navigated to UploadPage with assignedEditorId: $editorId');
        //    final editorId = state.extra as String?;
        // print('🔵 Navigated with extra editorId: $editorId');
        return UploadPage(assignedEditorId: editorId);
      },
      routes: [
        GoRoute(
          path: Routes.videoswithEditor, // 'videos'
          builder: (context, state) {
            final editorId = state.pathParameters['assignedEditorId'];
            print(
              '🟢 Navigated to VideosPage with assignedEditorId: $editorId',
            );
            return VideosPage(assignedEditorId: editorId);
          },
        ),
      ],
    ),

    StatefulShellRoute.indexedStack(
      builder:
          (context, state, navigationShell) =>
              MainScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home, // Nested path for dashboard
              builder:
                  (context, state) => SnapVideoScroll(), // Dashboard widget
              routes: [
                GoRoute(
                  path: Routes.fullScreenVideo,
                  builder: (context, state) {
                    final videoUrl = state.uri.queryParameters['url'] ?? '';
                    final fordownload =
                        int.tryParse(
                          state.uri.queryParameters['fordownload'] ?? '0',
                        ) ??
                        0;

                    return FullScreenVideoPage(
                      url: videoUrl,
                      fordownload: fordownload,
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Ad Marketplace Route
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.explore,
              builder: (context, state) => const ExplorePage(),
              routes: [
                GoRoute(
                  path: Routes.acceptedOrders, // Nested route under ExplorePage
                  builder: (context, state) => AcceptedOrdersPage(),
                ),
                GoRoute(
                  path: Routes.assignedOrders, // Nested route under ExplorePage
                  builder: (context, state) => AssignedOrdersPage(),
                ),

                // GoRoute(
                //   path: Routes.fullScreenVideo, // e.g. 'video'
                //   builder: (context, state) {
                //     final videoUrl = state.uri.queryParameters['url'] ?? '';
                //     final fordownload =
                //         int.tryParse(
                //           state.uri.queryParameters['fordownload'] ?? '0',
                //         ) ??
                //         0;

                //     print('🎥 Extracted URL from query: $videoUrl');
                //     return FullScreenVideoPage(
                //       url: videoUrl,
                //       fordownload: fordownload,
                //     );
                //   },
                // ),
                GoRoute(
                  path: Routes.fullScreenVideo, // e.g. 'video'
                  builder: (context, state) {
                    // Safely read from state.extra
                    final extra = state.extra as Map<String, dynamic>? ?? {};
                    final videoUrl = extra['url'] ?? '';
                    final fordownload = extra['fordownload'] ?? 0;

                    print(
                      '🎥 Extracted from extra → URL: $videoUrl | fordownload: $fordownload',
                    );

                    return FullScreenVideoPage(
                      url: videoUrl,
                      fordownload: fordownload,
                    );
                  },
                ),

                GoRoute(
                  path: Routes.fullScreenImage, // e.g. 'image'
                  builder: (context, state) {
                    // Safely read from state.extra
                    final extra = state.extra as Map<String, dynamic>? ?? {};
                    final imageUrl = extra['url'] ?? '';
                    final fordownload = extra['fordownload'] ?? 0;

                    print(
                      '🖼 Extracted from extra → URL: $imageUrl | fordownload: $fordownload',
                    );

                    return FullScreenImagePage(
                      imageUrl: imageUrl,
                      fordownload: fordownload,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // My Ads Route
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.upload,
              builder: (context, state) => UploadPage(),
            ),
          ],
        ),
        // Profile Settings Route
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              builder: (context, state) => ProfilePage(isSelfPage: true),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.profilEdit, // Nested route under SplashScreen
      builder: (context, state) => ProfileEditPage(),
    ),
    GoRoute(
      path: Routes.userDetailPage, // Nested route under SplashScreen
      builder: (context, state) => UserDetailPage(),
    ),

    GoRoute(
      path: Routes.userDetailPage, // Nested route under SplashScreen
      builder: (context, state) => AcceptedOrdersPage(),
    ),
  ],
);

// "https://firebasestorage.googleapis.com/v0/b/admotion-media-1.firebasestorage.app/o/videos%2F9tYG35pyf2?alt=media&token=dea7bb5b-19fd-4d60-b33c-bd24a31de5e7"




// "https://firebasestorage.googleapis.com/v0/b/admotion-media-1.firebasestorage.app/o/videos%2FvyAhYZhBda?alt=media&token=a8756f5e-74bb-44ac-b896-e3dc4703c549"
// (str