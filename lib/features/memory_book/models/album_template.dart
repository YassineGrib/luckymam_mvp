import 'package:flutter/material.dart';

/// A single event slot within an album template — filled either by
/// attaching an existing capsule or creating a new one.
class AlbumEventSlot {
  final String id;
  final String titleFr;
  final String titleAr;
  final String descriptionFr;
  final IconData icon;
  final int order;

  const AlbumEventSlot({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.descriptionFr,
    required this.icon,
    required this.order,
  });
}

/// A predefined album model: a themed set of life events a mother fills in
/// one by one, either with an existing capsule or a newly captured one.
class AlbumTemplate {
  final String id;
  final String titleFr;
  final String titleAr;
  final String subtitleFr;
  final IconData icon;
  final List<Color> gradientColors;
  final List<AlbumEventSlot> slots;

  const AlbumTemplate({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.subtitleFr,
    required this.icon,
    required this.gradientColors,
    required this.slots,
  });

  int get slotCount => slots.length;
}
