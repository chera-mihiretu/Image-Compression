import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:equatable/equatable.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/auth/domain/entity/user_entity.dart';
import 'package:mobile/feature/auth/domain/repository/auth_repository.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_in_with_google.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  StreamSubscription<Option<AppUser>>? _sub;

  AuthBloc({
    required this.repository,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState.unknown()) {
    on<_AuthStateChanged>(_onAuthStateChanged);
    on<AuthSignInWithGoogleRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    _sub = repository.authStateChanges().listen((event) {
      add(_AuthStateChanged(event));
    });
  }

  void _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) {
    event.user.fold(
      () => emit(const AuthState.unauthenticated()),
      (u) => emit(AuthState.authenticated(u)),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await signInWithGoogleUseCase();
    result.fold(
      (l) => emit(state.copyWith(isLoading: false, failure: l)),
      (r) => emit(AuthState.authenticated(r)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await signOutUseCase();
    result.fold(
      (l) => emit(state.copyWith(isLoading: false, failure: l)),
      (r) => emit(const AuthState.unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
