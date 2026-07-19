import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analytics_service.dart';
import '../models/print_order.dart';
import '../services/album_pdf_service.dart';

final albumPdfServiceProvider = Provider<AlbumPdfService>((ref) {
  return AlbumPdfService();
});

class PrintOrderActionsState {
  final bool isLoading;
  final String? successMessage;
  final String? error;

  const PrintOrderActionsState({
    this.isLoading = false,
    this.successMessage,
    this.error,
  });

  PrintOrderActionsState copyWith({
    bool? isLoading,
    String? successMessage,
    String? error,
  }) => PrintOrderActionsState(
    isLoading: isLoading ?? this.isLoading,
    successMessage: successMessage,
    error: error,
  );
}

class PrintOrderActionsNotifier extends StateNotifier<PrintOrderActionsState> {
  PrintOrderActionsNotifier() : super(const PrintOrderActionsState());

  Future<bool> submitOrder(PrintOrder order) async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Non connecté');

      await FirebaseFirestore.instance
          .collection('print_orders')
          .add(order.toFirestore());

      AnalyticsService().logEvent(
        'order_created',
        parameters: {
          'albumId': order.albumId,
          'albumType': order.albumType,
          'pageCount': order.pageCount,
          'isVipFree': order.isVipFree,
        },
      );

      state = const PrintOrderActionsState(
        successMessage: 'Commande envoyée ! Nous vous contacterons bientôt.',
      );
      return true;
    } catch (e) {
      state = PrintOrderActionsState(error: 'Erreur : $e');
      return false;
    }
  }

  void clearMessages() {
    state = const PrintOrderActionsState();
  }
}

final printOrderActionsProvider =
    StateNotifierProvider<PrintOrderActionsNotifier, PrintOrderActionsState>((
      ref,
    ) {
      return PrintOrderActionsNotifier();
    });
