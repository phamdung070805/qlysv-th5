import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '',
  );
  bool _visible = false;

  void _fillDemoAccount(String email) {
    _emailController.text = email;
    _passwordController.text = '123456';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final isDark = theme.brightness == Brightness.dark;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF081018), Color(0xFF0F2733)]
                    : const [Color(0xFFDFF5FA), Color(0xFFF5F9FB)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -70,
                  left: -30,
                  child: _BackdropCircle(
                    size: 210,
                    color: isDark
                        ? const Color(0xFF164E63).withValues(alpha: 0.4)
                        : const Color(0xFF22D3EE).withValues(alpha: 0.28),
                  ),
                ),
                Positioned(
                  right: -40,
                  bottom: -90,
                  child: _BackdropCircle(
                    size: 270,
                    color: isDark
                        ? const Color(0xFF0E7490).withValues(alpha: 0.34)
                        : const Color(0xFF0284C7).withValues(alpha: 0.2),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: AnimatedSlide(
                          offset: _visible ? Offset.zero : const Offset(0, 0.12),
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: _visible ? 1 : 0,
                            duration: const Duration(milliseconds: 520),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Student Manager',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Đăng nhập bằng Email/Password để vào hệ thống quản lý sinh viên.',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nếu bạn đang test nhanh, có thể chọn tài khoản mẫu ở dưới.',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 24),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(Icons.email_outlined),
                                        ),
                                        validator: (value) {
                                          final text = value?.trim() ?? '';
                                          if (text.isEmpty) {
                                            return 'Vui lòng nhập email.';
                                          }
                                          if (!RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          ).hasMatch(text)) {
                                            return 'Email không đúng định dạng.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Mật khẩu',
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        validator: (value) {
                                          if ((value ?? '').isEmpty) {
                                            return 'Vui lòng nhập mật khẩu.';
                                          }
                                          if ((value ?? '').length < 6) {
                                            return 'Mật khẩu phải có ít nhất 6 ký tự.';
                                          }
                                          return null;
                                        },
                                      ),
                                      if (viewModel.errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          viewModel.errorMessage!,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          onPressed: viewModel.isLoading ? null : _submit,
                                          child: const Text('Đăng nhập'),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: viewModel.isLoading
                                              ? null
                                              : () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute<void>(
                                                      builder: (_) => const SignUpScreen(),
                                                    ),
                                                  );
                                                },
                                          child: const Text('Tạo tài khoản mới'),
                                        ),
                                      ),
                                    
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tài khoản mẫu:\n- admin@studentmanager.dev\n- teacher@studentmanager.dev\n- student@studentmanager.dev\nMật khẩu chung: 123456',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
