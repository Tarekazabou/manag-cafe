import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.connected;
  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  Stream<ConnectivityStatus> get statusChanges => _statusController.stream;

  void initialize() {
    _subscription =
        _connectivity.onConnectivityChanged.listen((result) {
      final newStatus = result.isEmpty ||
              result.every((r) => r == ConnectivityResult.none)
          ? ConnectivityStatus.disconnected
          : ConnectivityStatus.connected;

      _currentStatus = newStatus;
      _statusController.add(newStatus);
    });
  }

  void dispose() {
    _subscription.cancel();
    _statusController.close();
  }
}
