import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/auth/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Stream<Option<AppUser>> authStateChanges();
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, Unit>> signOut();
}
