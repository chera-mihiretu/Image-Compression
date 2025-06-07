import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/auth/domain/repository/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  const SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.signOut();
}
