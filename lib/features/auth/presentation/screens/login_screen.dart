import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/validators.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title, this.nextRoute});

  final String title;
  final String? nextRoute;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.nextRoute != null) context.go(widget.nextRoute!);
  }

  @override
  Widget build(BuildContext context) {
    return BottomButtonScaffold(
      buttonLabel: 'Log in',
      onButtonPressed: _submit,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
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
