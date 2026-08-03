import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/validators.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';
import 'package:konofrontend/features/auth/data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.title,
    this.nextRoute,
    this.wireToBackend = false,
  });

  final String title;
  final String? nextRoute;
  final bool wireToBackend;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.wireToBackend) {
      if (widget.nextRoute != null) context.go(widget.nextRoute!);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authRepositoryProvider).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (result.success) {
      if (widget.nextRoute != null) context.go(widget.nextRoute!);
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomButtonScaffold(
      buttonLabel: _isLoading ? 'Logging in...' : 'Log in',
      onButtonPressed: _isLoading ? () {} : _submit,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              AppTextField(
                label: 'E-mail',
                hint: 'owner@kono.rest',
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                maxLength: 50,
              ),
              AppTextField(
                label: 'Password',
                hint: '********',
                controller: _passwordController,
                validator: (value) => Validators.required(value, 'Password'),
                obscureText: true,
                maxLength: 32,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {},
                  child: const Text('Forgot your password?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
