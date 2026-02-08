import 'package:flutter/material.dart';
import '../../timeline/screens/timeline_screen.dart';

/// Timeline tab - wraps the TimelineScreen for use in bottom navigation.
class TimelineTab extends StatelessWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TimelineScreen();
  }
}
