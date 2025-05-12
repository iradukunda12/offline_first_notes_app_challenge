part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final String status;
  final Color color;
  final bool isOnline;
  final bool isSyncing;

  const ConnectivityState._({
    required this.status,
    required this.color,
    this.isOnline = false,
    this.isSyncing = false,
  });

  const ConnectivityState.initial()
      : this._(
          status: "Checking connection...",
          color: Colors.grey,
        );

  const ConnectivityState.online()
      : this._(
          status: "Online",
          color: Colors.green,
          isOnline: true,
        );

  const ConnectivityState.offline()
      : this._(
          status: "Offline",
          color: Colors.red,
        );

  const ConnectivityState.syncing()
      : this._(
          status: "Syncing...",
          color: Colors.orange,
          isOnline: true,
          isSyncing: true,
        );

  const ConnectivityState.synced()
      : this._(
          status: "Synced",
          color: Colors.green,
          isOnline: true,
        );

  const ConnectivityState.error(String message)
      : this._(
          status: message,
          color: Colors.red,
        );

  @override
  List<Object> get props => [status, color, isOnline, isSyncing];
}
