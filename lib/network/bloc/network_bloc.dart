// network_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity = Connectivity();

  NetworkCubit() : super(NetworkInitial()) {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      for (var result in results) {
        _updateConnectionStatus(result);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      emit(NetworkDisconnected(result));
    } else {
      emit(NetworkConnected(result));
    }
  }
}
