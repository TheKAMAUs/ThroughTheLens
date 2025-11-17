import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/preferences_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  final storage = PreferencesService();
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final uid = await PreferencesService.getUid(); // Read saved UID
    if (uid != null && uid.isNotEmpty) {
      setState(() {
        _isAuthenticated = true;
        authService.fetchClient(uid: uid);
      });
      Future.microtask(() => context.go(RoutesEnum.home.path));
    } else {
      setState(() {
        _isAuthenticated = false;
      });
      Future.microtask(() => context.go(RoutesEnum.home.path));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const SizedBox.shrink(); // Just a placeholder during redirect
  }
}
