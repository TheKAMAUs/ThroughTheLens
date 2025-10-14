// network_state.dart
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkState {}

class NetworkInitial extends NetworkState {}

class NetworkConnected extends NetworkState {
  final ConnectivityResult result;

  NetworkConnected(this.result);
}

class NetworkDisconnected extends NetworkState {
  final ConnectivityResult result;

  NetworkDisconnected(this.result);
}
