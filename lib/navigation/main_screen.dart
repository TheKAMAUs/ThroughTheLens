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
      extendBody: true, // 👈🏽 lets nav bar float above background

      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: navigationShell, // Smooth transition between pages
        ),
      ),

      // 🌗 Adaptive Glassy Bottom Navigation Bar
      bottomNavigationBar: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final backgroundColor =
              isDark
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9);

          final shadowColor =
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1);

          final activeColor =
              isDark ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700;

          final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[700];

          final tabBackgroundColor =
              isDark
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.blueAccent.withOpacity(0.15);

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10,
              ),
              child: GNav(
                gap: 8,
                selectedIndex: navigationShell.currentIndex,
                onTabChange: (index) {
                  navigationShell.goBranch(index);
                },
                rippleColor:
                    isDark
                        ? Colors.blueAccent.withOpacity(0.25)
                        : Colors.blue.withOpacity(0.15),
                hoverColor:
                    isDark
                        ? Colors.blueAccent.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.08),
                haptic: true,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 500),
                tabBorderRadius: 20,
                tabBackgroundColor: tabBackgroundColor,
                activeColor: activeColor,
                iconSize: 26,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                color: inactiveColor,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: activeColor,
                ),

                // ✨ Tabs
                tabs:
                    destinations
                        .map(
                          (destination) => GButton(
                            icon: destination.icon,
                            text: destination.label,
                          ),
                        )
                        .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
