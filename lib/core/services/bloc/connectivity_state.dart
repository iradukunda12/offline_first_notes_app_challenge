part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final String status;
  final Color color;

  const ConnectivityState._(this.status, this.color);

  const ConnectivityState.initial() : this._("Online", Colors.green);

  const ConnectivityState.online() : this._("Online", Colors.green);

  const ConnectivityState.offline() : this._("Offline", Colors.red);

  const ConnectivityState.synced()
      : this._("Synced", Colors.orange); // Or any other color for synced

  const ConnectivityState.error(String message) : this._(message, Colors.red);

  @override
  List<Object> get props => [status, color];
}
