import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/auth/presentation/page/login_page.dart';
import 'package:mobile/feature/image_compression/presentation/page/image_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      final state = context.read<AuthBloc>().state;
      if (state.user != null) {
        Navigator.of(context).pushReplacementNamed(ImageListPage.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 96),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
