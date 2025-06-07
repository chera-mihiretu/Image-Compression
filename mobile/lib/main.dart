import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/cores/constants/app_theme.dart';
import 'package:mobile/cores/constants/hive_constants.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/feature/auth/data/data_source/firebase_auth_data_source.dart';
import 'package:mobile/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_in_with_google.dart';
import 'package:mobile/feature/auth/domain/usecase/sign_out.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_local_data_source.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_remote_data_source.dart';
import 'package:mobile/feature/image_compression/data/model/compressed_image_model.dart';
import 'package:mobile/feature/image_compression/data/repository/image_repository_impl.dart';
import 'package:mobile/feature/image_compression/domain/usecase/compress_image_usecase.dart';
import 'package:mobile/feature/image_compression/domain/usecase/get_history_usecase.dart';
import 'package:mobile/feature/image_compression/presentation/bloc/image_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/page/page_router.dart';
import 'package:mobile/feature/image_compression/presentation/page/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(CompressedImageModelAdapter());
  await Hive.openBox<CompressedImageModel>(HiveConstants.compressedImagesBox);

  final authDataSource = FirebaseAuthDataSource(
    firebaseAuth: fb.FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  );
  final authRepository = AuthRepositoryImpl(authDataSource);

  final imageLocal = ImageLocalDataSource();
  final imageRemote = ImageRemoteDataSource();
  final imageRepository = ImageRepositoryImpl(
    remote: imageRemote,
    local: imageLocal,
  );

  runApp(
    MyApp(authRepository: authRepository, imageRepository: imageRepository),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ImageRepositoryImpl imageRepository;
  const MyApp({
    super.key,
    required this.authRepository,
    required this.imageRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: imageRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              repository: authRepository,
              signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
              signOutUseCase: SignOutUseCase(authRepository),
            ),
          ),
          BlocProvider(
            create: (_) => ImageBloc(
              compressImageUseCase: CompressImageUseCase(imageRepository),
              getHistoryUseCase: GetHistoryUseCase(imageRepository),
            )..add(const ImageHistoryRequested()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Image Compressor',
          theme: AppTheme.light(),
          initialRoute: SplashPage.routeName,
          routes: appRoutes,
        ),
      ),
    );
  }
}
