import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/cores/constants/hive_constants.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/feature/auth/data/data_source/firebase_auth_data_source.dart';
import 'package:mobile/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile/feature/auth/domain/repository/auth_repository.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_in_with_google.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_out.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_local_data_source.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_remote_data_source.dart';
import 'package:mobile/feature/image_compression/data/model/compressed_image_model.dart';
import 'package:mobile/feature/image_compression/data/repository/image_repository_impl.dart';
import 'package:mobile/feature/image_compression/domain/repository/image_repository.dart';
import 'package:mobile/feature/image_compression/domain/usecase/compress_image_usecase.dart';
import 'package:mobile/feature/image_compression/domain/usecase/get_history_usecase.dart';
import 'package:mobile/feature/image_compression/presentation/bloc/image_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Env & Firebase
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CompressedImageModelAdapter());
  await Hive.openBox<CompressedImageModel>(HiveConstants.compressedImagesBox);

  // External
  getIt.registerLazySingleton<fb.FirebaseAuth>(() => fb.FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(
      firebaseAuth: getIt<fb.FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<ImageLocalDataSource>(
    () => ImageLocalDataSource(),
  );
  getIt.registerLazySingleton<ImageRemoteDataSource>(
    () => ImageRemoteDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(remote: getIt(), local: getIt()),
  );

  // Use cases
  getIt.registerFactory<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(getIt()),
  );
  getIt.registerFactory<SignOutUseCase>(() => SignOutUseCase(getIt()));
  getIt.registerFactory<CompressImageUseCase>(
    () => CompressImageUseCase(getIt()),
  );
  getIt.registerFactory<GetHistoryUseCase>(() => GetHistoryUseCase(getIt()));

  // Blocs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: getIt<AuthRepository>(),
      signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
    ),
  );
  getIt.registerFactory<ImageBloc>(
    () => ImageBloc(
      compressImageUseCase: getIt<CompressImageUseCase>(),
      getHistoryUseCase: getIt<GetHistoryUseCase>(),
    ),
  );
}
