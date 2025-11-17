import 'package:flutter/material.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/seo/header_updater.dart';

class SeoRouteObserver extends NavigatorObserver {
  void _updateForRoute(Route<dynamic>? route) {
    if (route == null) return;

    final currentPath = route.settings.name ?? '';
    print('🧭 SEO tracking: $currentPath');

    for (final page in RoutesEnum.values) {
      if (currentPath == page.path) {
        print('🌍 Updating meta for: ${page.title}');
        HeadUpdater.update(
          title: page.title,
          description: page.description,
          keywords: page.keywords,
          robots: page.robots,
          canonicalUrl: page.canonicalUrl,
          imageUrl: page.imageUrl,
          schemaType: page.schemaType,
        );
        break;
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateForRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateForRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateForRoute(newRoute);
  }
}
