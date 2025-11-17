import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class VisitedPathObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final uri = GoRouter.of(navigator!.context).state.fullPath;
    print('🧭 didPush called');
    print('➡️ Current route: ${route.settings.name}');
    print('⬅️ Previous route: ${previousRoute?.settings.name}');
    if (uri != null) {
      print('🌐 Full path detected: $uri');
      logVisitedPath(uri);
    } else {
      print('⚠️ No URI found for current route.');
    }
  }

  void logVisitedPath(String path) async {
    final url = 'https://throughthelensbackend.onrender.com/save_path.php';
    final uri = Uri.parse('$url?path=${path.toLowerCase()}');

    print('🚀 Sending GET request to: $uri');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('✅ Path logged successfully: $path');
        print('📄 Server response: ${response.body}');
      } else {
        print('❌ Server error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error logging path: $e');
    }
  }
}
