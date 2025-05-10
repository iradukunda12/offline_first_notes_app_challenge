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

  ConnectivityCubit(this._connectivityService, this._firestoreService)
      : super(const ConnectivityState.initial());

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Start monitoring the connectivity status
  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
            _monitorConnection as void Function(
                List<ConnectivityResult> event)?)
        as StreamSubscription<ConnectivityResult>;
  }

  // Stop monitoring the connectivity status
  void stopMonitoring() {
    _connectivitySubscription.cancel();
  }

  // Monitoring connectivity changes and updating state accordingly
  void _monitorConnection(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      emit(const ConnectivityState.offline());
    } else {
      emit(const ConnectivityState.online());
      _syncNotes(); // sync on reconnect
    }
  }

  // Sync notes when the device comes back online
  Future<void> _syncNotes() async {
    try {
      await _firestoreService.syncOfflineNotes();
      emit(const ConnectivityState.synced());
    } catch (e) {
      emit(ConnectivityState.error("Failed to sync notes"));
    }
  }
}
