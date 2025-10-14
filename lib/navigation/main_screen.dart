import 'package:memoriesweb/navigation/destination.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('MainScreen'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GNav(
        selectedIndex: navigationShell.currentIndex,
        onTabChange: (index) {
          navigationShell.goBranch(
            index,
          ); // This helps GoRouter navigate to the respective branch
        },
        rippleColor: Color.fromARGB(255, 24, 116, 237).withOpacity(0.5),
        hoverColor: Color.fromARGB(255, 60, 249, 85),
        haptic: true,
        tabBorderRadius: 15,
        tabBackgroundColor: Theme.of(context).primaryColor,
        activeColor: const Color.fromARGB(255, 50, 224, 169),
        iconSize: 24,
        tabMargin: const EdgeInsets.only(left: 30.0, right: 30),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        tabs:
            destinations
                .map(
                  (destination) =>
                      GButton(icon: destination.icon, text: destination.label),
                )
                .toList(),
      ),
    );
  }
}
