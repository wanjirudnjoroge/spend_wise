import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../view_model/auth_view.dart';
import '../view_model/providers.dart';
import 'home_shell.dart';
import 'login_screen.dart';

class RedirectScreen extends ConsumerStatefulWidget {
  const RedirectScreen({super.key});

  @override
  ConsumerState<RedirectScreen> createState() => _RedirectScreenState();
}

class _RedirectScreenState extends ConsumerState<RedirectScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(authViewModelProvider).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);

    switch (auth.status) {
      case AuthStatus.authenticated:
        return const HomeShell();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.blue,
                  size: 48,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
    }
  }
}
