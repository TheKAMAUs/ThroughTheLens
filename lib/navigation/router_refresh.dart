import 'dart:async';
import 'package:flutter/foundation.dart';

/// Allows GoRouter to rebuild whenever the stream emits a new value.
/// Very handy for FirebaseAuth.instance.authStateChanges().
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    print('[GoRouterRefreshStream] Constructor called');
    notifyListeners();
    print('[GoRouterRefreshStream] notifyListeners() called in constructor');

    _subscription = stream.asBroadcastStream().listen((event) {
      print('[GoRouterRefreshStream] Stream event received: $event');
      notifyListeners();
      print('[GoRouterRefreshStream] notifyListeners() called after event');
    });

    print('[GoRouterRefreshStream] Listening to stream...');
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    print('[GoRouterRefreshStream] Disposing...');
    _subscription.cancel();
    print('[GoRouterRefreshStream] Subscription canceled');
    super.dispose();
    print('[GoRouterRefreshStream] Disposed successfully');
  }
}
