import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kayko_challenge/core/services/connectivity_services.dart';
import 'package:kayko_challenge/core/services/firestore_sync.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  final Connectivity _connectivity = Connectivity();
  final FirestoreService _firestoreService;
  final bool _isSyncing = false;

  ConnectivityCubit(this._connectivityService, this._firestoreService)
      : super(const ConnectivityState.initial()) {
    startMonitoring();
  }

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _handleConnectivityChange(results);
      },
      onError: (error) {
        emit(ConnectivityState.error("Connection error: $error"));
      },
    );
  }

  Future<void> _handleConnectivityChange(
      List<ConnectivityResult> results) async {
    final isConnected = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    if (!isConnected) {
      emit(const ConnectivityState.offline());
      return;
    }

    emit(const ConnectivityState.online());

    if (!state.isOnline && !_isSyncing) {
      // await _syncNotes();
    }
  }

  void stopMonitoring() {
    _connectivitySubscription.cancel();
  }

  // Future<void> _syncNotes() async {
  //   if (_isSyncing) return;

  //   _isSyncing = true;
  //   try {
  //     emit(const ConnectivityState.syncing());
  //     await _firestoreService.syncOfflineNotes();
  //     emit(const ConnectivityState.synced());
  //   } catch (e) {
  //     emit(ConnectivityState.error("Failed to sync notes: $e"));
  //   } finally {
  //     _isSyncing = false;

  //     final currentStatus = await _connectivity.checkConnectivity();
  //     await _handleConnectivityChange(currentStatus);
  //   }
  // }

  @override
  Future<void> close() {
    stopMonitoring();
    return super.close();
  }
}
