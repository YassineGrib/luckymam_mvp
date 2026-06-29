import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/timeline/widgets/timeline_rail.dart';

const _kTimelineViewKey = 'timeline_view_mode';

final timelineViewModeProvider =
    StateNotifierProvider<TimelineViewModeNotifier, TimelineViewMode>(
  (ref) => TimelineViewModeNotifier(),
);

class TimelineViewModeNotifier extends StateNotifier<TimelineViewMode> {
  TimelineViewModeNotifier() : super(TimelineViewMode.horizontal) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kTimelineViewKey);
    if (stored == TimelineViewMode.vertical.name) {
      state = TimelineViewMode.vertical;
    }
  }

  Future<void> setMode(TimelineViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTimelineViewKey, mode.name);
  }
}
