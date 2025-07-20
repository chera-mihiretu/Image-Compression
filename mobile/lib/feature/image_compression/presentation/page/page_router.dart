import 'package:flutter/widgets.dart';
import 'package:mobile/feature/auth/presentation/page/login_page.dart';
import 'package:mobile/feature/auth/presentation/page/onboarding_page.dart';
import 'package:mobile/feature/auth/presentation/page/settings_page.dart';
import 'package:mobile/feature/image_compression/presentation/page/image_list_page.dart';
import 'package:mobile/feature/image_compression/presentation/page/preview_page.dart';
import 'package:mobile/feature/image_compression/presentation/page/splash_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  SplashPage.routeName: (_) => const SplashPage(),
  OnboardingPage.routeName: (_) => const OnboardingPage(),
  LoginPage.routeName: (_) => const LoginPage(),
  ImageListPage.routeName: (_) => const ImageListPage(),
  PreviewPage.routeName: (_) => const PreviewPage(),
  SettingsPage.routeName: (_) => const SettingsPage(),
};
