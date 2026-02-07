import 'package:flutter/material.dart';
import '../../profile/profile_screen.dart';

/// Profile tab - wraps ProfileScreen for use in bottom navigation.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
