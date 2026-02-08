import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Life phase enum representing the journey stages
enum Phase { preGestation, gestation, postPartum, enfance, adulte }

/// Extension with display properties for each phase
extension PhaseExtension on Phase {
  String get labelFr {
    switch (this) {
      case Phase.preGestation:
        return 'Pré-Gestation';
      case Phase.gestation:
        return 'Gestation';
      case Phase.postPartum:
        return 'Post-Partum';
      case Phase.enfance:
        return 'Enfance';
      case Phase.adulte:
        return 'Adulte';
    }
  }

  String get labelAr {
    switch (this) {
      case Phase.preGestation:
        return 'قبل الحمل';
      case Phase.gestation:
        return 'الحمل';
      case Phase.postPartum:
        return 'ما بعد الولادة';
      case Phase.enfance:
        return 'الطفولة';
      case Phase.adulte:
        return 'البلوغ';
    }
  }

  IconData get icon {
    switch (this) {
      case Phase.preGestation:
        return Icons.auto_awesome_rounded;
      case Phase.gestation:
        return Icons.pregnant_woman_rounded;
      case Phase.postPartum:
        return Icons.child_care_rounded;
      case Phase.enfance:
        return Icons.child_friendly_rounded;
      case Phase.adulte:
        return Icons.person_rounded;
    }
  }

  Color get color {
    switch (this) {
      case Phase.preGestation:
        return const Color(0xFF9C7EBF); // Soft violet
      case Phase.gestation:
        return AppColors.coral; // Coral pink
      case Phase.postPartum:
        return AppColors.smaltBlue; // Teal
      case Phase.enfance:
        return AppColors.goldenrod; // Golden
      case Phase.adulte:
        return AppColors.success; // Green
    }
  }

  Color get lightColor {
    switch (this) {
      case Phase.preGestation:
        return const Color(0xFFE8DEF8);
      case Phase.gestation:
        return const Color(0xFFFFE4E8);
      case Phase.postPartum:
        return const Color(0xFFE0F4F4);
      case Phase.enfance:
        return const Color(0xFFFFF8E1);
      case Phase.adulte:
        return const Color(0xFFE8F5E9);
    }
  }
}

/// Milestone category enum
enum MilestoneCategory { emotion, sante, culture, religion }

/// Extension with display properties for categories
extension MilestoneCategoryExtension on MilestoneCategory {
  String get labelFr {
    switch (this) {
      case MilestoneCategory.emotion:
        return 'Émotion';
      case MilestoneCategory.sante:
        return 'Santé';
      case MilestoneCategory.culture:
        return 'Culture';
      case MilestoneCategory.religion:
        return 'Religion';
    }
  }

  String get labelAr {
    switch (this) {
      case MilestoneCategory.emotion:
        return 'عاطفة';
      case MilestoneCategory.sante:
        return 'صحة';
      case MilestoneCategory.culture:
        return 'ثقافة';
      case MilestoneCategory.religion:
        return 'دين';
    }
  }

  IconData get icon {
    switch (this) {
      case MilestoneCategory.emotion:
        return Icons.camera_alt_rounded;
      case MilestoneCategory.sante:
        return Icons.medical_services_rounded;
      case MilestoneCategory.culture:
        return Icons.celebration_rounded;
      case MilestoneCategory.religion:
        return Icons.mosque_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MilestoneCategory.emotion:
        return AppColors.coral;
      case MilestoneCategory.sante:
        return AppColors.success;
      case MilestoneCategory.culture:
        return AppColors.goldenrod;
      case MilestoneCategory.religion:
        return AppColors.smaltBlue;
    }
  }

  Color get lightBg {
    switch (this) {
      case MilestoneCategory.emotion:
        return const Color(0xFFFFE4E8);
      case MilestoneCategory.sante:
        return const Color(0xFFE8F5E9);
      case MilestoneCategory.culture:
        return const Color(0xFFFFF8E1);
      case MilestoneCategory.religion:
        return const Color(0xFFE0F4F4);
    }
  }
}
