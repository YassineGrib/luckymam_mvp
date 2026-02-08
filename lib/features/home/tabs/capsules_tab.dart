import 'package:flutter/material.dart';

import '../../capsules/screens/capsules_gallery.dart';

/// Capsules tab - delegates to CapsulesGallery.
class CapsulesTab extends StatelessWidget {
  const CapsulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CapsulesGallery();
  }
}
