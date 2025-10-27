import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoriesweb/preferences_service.dart';

class AuthState {
  final String? uid;
  final bool isLoading;

  const AuthState({this.uid, this.isLoading = true});

  bool get isLoggedIn => uid != null;

  AuthState copyWith({String? uid, bool? isLoading}) {
    return AuthState(
      uid: uid ?? this.uid,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final uid = await PreferencesService.getUid();
    emit(AuthState(uid: uid, isLoading: false));
  }

  Future<void> login(String uid) async {
    await PreferencesService.saveUid(uid);
    emit(AuthState(uid: uid, isLoading: false));
  }

  Future<void> logout() async {
    await PreferencesService.clearUid();
    emit(const AuthState(uid: null, isLoading: false));
  }
}
