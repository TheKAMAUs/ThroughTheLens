import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(
    label: 'Home',
    icon: Icons.dashboard_outlined,
  ), // Originally: Dashboard
  Destination(
    label: 'Explore',
    icon: Icons.explore,
  ), // Originally: Verification
  Destination(
    label: 'Upload',
    icon: Icons.add_a_photo_rounded,
  ), // Originally: Ad Marketplace
  Destination(label: 'Profile', icon: Icons.person_outline), // Unchanged
  // Destination(label: 'Support', icon: Icons.support_agent_outlined), // You can later reuse this
];
