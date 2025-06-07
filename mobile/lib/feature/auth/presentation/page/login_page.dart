import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const FlutterLogo(size: 96),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Compress your images in the cloud',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => context.read<AuthBloc>().add(
                            const AuthSignInWithGoogleRequested(),
                          ),
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
