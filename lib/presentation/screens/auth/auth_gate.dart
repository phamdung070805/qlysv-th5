import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../shell/app_shell.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.isAuthenticated) {
          return const _SplashScreen();
        }

        if (viewModel.isAuthenticated) {
          return const AppShell();
        }

        return const SignInScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
