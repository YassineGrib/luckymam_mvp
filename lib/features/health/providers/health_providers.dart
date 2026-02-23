import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment.dart';
import '../models/growth_entry.dart';
import '../services/appointment_service.dart';
import '../services/growth_service.dart';

export '../../profile/providers/profile_providers.dart' show childrenProvider;

// ─── Service providers ────────────────────────────────────────────────────────

final growthServiceProvider = Provider<GrowthService>((_) => GrowthService());

final appointmentServiceProvider = Provider<AppointmentService>(
  (_) => AppointmentService(),
);

// ─── Growth entries ───────────────────────────────────────────────────────────

/// Live stream of growth entries for a given child, sorted by date desc.
final growthEntriesProvider = StreamProvider.autoDispose
    .family<List<GrowthEntry>, String>((ref, childId) {
      final service = ref.watch(growthServiceProvider);
      return service.watchEntries(childId);
    });

// ─── Growth actions ───────────────────────────────────────────────────────────

class GrowthActionsState {
  const GrowthActionsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
  final bool isLoading;
  final String? error;
  final String? successMessage;

  GrowthActionsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) => GrowthActionsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    successMessage: successMessage,
  );
}

class GrowthActionsNotifier extends StateNotifier<GrowthActionsState> {
  GrowthActionsNotifier(this._service) : super(const GrowthActionsState());

  final GrowthService _service;

  Future<bool> addEntry({
    required String childId,
    required DateTime date,
    double? weightKg,
    double? heightCm,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.addEntry(
        childId: childId,
        date: date,
        weightKg: weightKg,
        heightCm: heightCm,
        notes: notes,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Mesure enregistrée ✓',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('[GrowthActions] addEntry error: $e');
      return false;
    }
  }

  Future<void> deleteEntry({
    required String childId,
    required String entryId,
  }) async {
    try {
      await _service.deleteEntry(childId: childId, entryId: entryId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final growthActionsProvider =
    StateNotifierProvider<GrowthActionsNotifier, GrowthActionsState>(
      (ref) => GrowthActionsNotifier(ref.read(growthServiceProvider)),
    );

// ─── Appointments ─────────────────────────────────────────────────────────────

/// Live stream of appointments for a given child, sorted by date desc.
final appointmentsProvider = StreamProvider.autoDispose
    .family<List<Appointment>, String>((ref, childId) {
      final service = ref.watch(appointmentServiceProvider);
      return service.watchAppointments(childId);
    });

// ─── Appointment actions ──────────────────────────────────────────────────────

class AppointmentActionsState {
  const AppointmentActionsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
  final bool isLoading;
  final String? error;
  final String? successMessage;

  AppointmentActionsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) => AppointmentActionsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    successMessage: successMessage,
  );
}

class AppointmentActionsNotifier
    extends StateNotifier<AppointmentActionsState> {
  AppointmentActionsNotifier(this._service)
    : super(const AppointmentActionsState());

  final AppointmentService _service;

  Future<bool> addAppointment({
    required String childId,
    required DateTime date,
    required String doctorName,
    required AppointmentType type,
    String? notes,
    List<File> files = const [],
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.addAppointment(
        childId: childId,
        date: date,
        doctorName: doctorName,
        type: type,
        notes: notes,
        files: files,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Rendez-vous enregistré ✓',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('[AppointmentActions] addAppointment error: $e');
      return false;
    }
  }

  Future<void> deleteAppointment({
    required String childId,
    required Appointment appointment,
  }) async {
    try {
      await _service.deleteAppointment(
        childId: childId,
        appointment: appointment,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final appointmentActionsProvider =
    StateNotifierProvider<AppointmentActionsNotifier, AppointmentActionsState>(
      (ref) => AppointmentActionsNotifier(ref.read(appointmentServiceProvider)),
    );
