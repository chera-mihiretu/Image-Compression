import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/auth/domain/entity/user_entity.dart';
import 'package:mobile/feature/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  const SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, AppUser>> call() => repository.signInWithGoogle();
}
