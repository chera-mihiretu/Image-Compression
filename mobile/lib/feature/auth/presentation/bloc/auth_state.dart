part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final Failure? failure;
  final AppUser? user;
  final bool isUnknown;

  const AuthState({
    required this.isLoading,
    required this.failure,
    required this.user,
    required this.isUnknown,
  });

  const AuthState.unknown()
    : isLoading = false,
      failure = null,
      user = null,
      isUnknown = true;

  const AuthState.unauthenticated()
    : isLoading = false,
      failure = null,
      user = null,
      isUnknown = false;

  const AuthState._authenticated(this.user)
    : isLoading = false,
      failure = null,
      isUnknown = false;

  factory AuthState.authenticated(AppUser user) =>
      AuthState._authenticated(user);

  AuthState copyWith({
    bool? isLoading,
    Failure? failure,
    AppUser? user,
    bool? isUnknown,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      user: user ?? this.user,
      isUnknown: isUnknown ?? this.isUnknown,
    );
  }

  @override
  List<Object?> get props => [isLoading, failure, user, isUnknown];
}
