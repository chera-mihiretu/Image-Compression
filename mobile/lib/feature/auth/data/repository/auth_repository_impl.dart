import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/auth/data/data_source/firebase_auth_data_source.dart';
import 'package:mobile/feature/auth/domain/entity/user_entity.dart';
import 'package:mobile/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Stream<Option<AppUser>> authStateChanges() async* {
    await for (final user in dataSource.authStateChanges()) {
      yield optionOf(user);
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await dataSource.signInWithGoogle();
      return right(user);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await dataSource.signOut();
      return right(unit);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}
