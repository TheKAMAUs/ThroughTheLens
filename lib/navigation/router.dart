import 'package:memoriesweb/login/loginRivaan.dart';
import 'package:memoriesweb/navigation/main_screen.dart';
import 'package:memoriesweb/navigation/routes.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:memoriesweb/auth_wrapper.dart';
import 'package:memoriesweb/screen/explore_page.dart';
import 'package:memoriesweb/screen/forClients/assignedOrders.dart';
import 'package:memoriesweb/screen/forEditors/acceptedorders.dart';
import 'package:memoriesweb/screen/home_page.dart';
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
                  path:
                      Routes.acceptedOrders, // Nested route under SplashScreen
                  builder: (context, state) => AcceptedOrdersPage(),
                ),
                GoRoute(
                  path:
                      Routes.assignedOrders, // Nested route under SplashScreen
                  builder: (context, state) => AssignedOrdersPage(),
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