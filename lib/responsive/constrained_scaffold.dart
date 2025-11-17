import 'package:flutter/material.dart';

class ConstrainedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final bool extendBody;
  final Widget? bottomNavigationBar;
  final double bottomPadding;

  const ConstrainedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.extendBody = false,
    this.bottomNavigationBar,
    this.bottomPadding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      appBar: appBar,
      drawer: drawer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                // 🧱 Main body content expands
                Expanded(child: body),

                // 🧭 Constrained Bottom NavBar (centered + fixed bottom)
                if (bottomNavigationBar != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: bottomNavigationBar,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
