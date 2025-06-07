part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class _AuthStateChanged extends AuthEvent {
  final Option<AppUser> user;
  const _AuthStateChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
