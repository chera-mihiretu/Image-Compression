import 'package:flutter/material.dart';
import 'package:mobile/pick_image.dart';
import 'package:mobile/sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: SignIn.routeName,
      routes: {
        SignIn.routeName: (context) => const SignIn(),
        PickImage.routeName: (context) => const PickImage(),
      },
    );
  }
}
