import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/cores/constants/app_theme.dart';
import 'package:mobile/cores/di/injector.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/bloc/image_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/page/page_router.dart';
import 'package:mobile/feature/image_compression/presentation/page/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(
          create: (_) => getIt<ImageBloc>()..add(const ImageHistoryRequested()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Image Compressor',
        theme: AppTheme.light(),
        initialRoute: SplashPage.routeName,
        routes: appRoutes,
      ),
    );
  }
}
