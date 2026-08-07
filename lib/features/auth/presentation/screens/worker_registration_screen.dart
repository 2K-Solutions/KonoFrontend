import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/validators.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';
import 'package:konofrontend/features/auth/data/auth_repository.dart';
import 'package:konofrontend/features/auth/data/token_storage.dart';

class WorkerRegistrationScreen extends ConsumerStatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  ConsumerState<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends ConsumerState<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authRepositoryProvider).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          secondName: _secondNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
        );

    if (!mounted) return;

    if (result.success) {
      await ref.read(tokenStorageProvider).saveTokens(
            accessToken: result.accessToken!,
            refreshToken: result.refreshToken!,
          );
      if (!mounted) return;
      context.go(AppRoutes.workerWaitForInvite);
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
      buttonLabel: _isLoading ? 'Signing up...' : 'Sign up',
      onButtonPressed: _isLoading ? () {} : _submit,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work with us!', style: Theme.of(context).textTheme.headlineSmall),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'First name',
                        hint: 'Enter your first name',
                        controller: _firstNameController,
                        validator: (value) => Validators.required(value, 'First name'),
                        maxLength: 25,
                      ),
                      AppTextField(
                        label: 'Second name',
                        hint: 'Enter your second name',
                        controller: _secondNameController,
                        validator: (value) => Validators.required(value, 'Second name'),
                        maxLength: 25,
                      ),
                      AppTextField(
                        label: 'Username',
                        hint: 'Choose a username',
                        controller: _usernameController,
                        validator: (value) => Validators.required(value, 'Username'),
                        maxLength: 25,
                      ),
                      AppTextField(
                        label: 'E-mail',
                        hint: 'example@kono.rest',
                        controller: _emailController,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                      ),
                      AppTextField(
                        label: 'Phone number',
                        hint: '+1 234 567 8900',
                        controller: _phoneNumberController,
                        validator: (value) => Validators.required(value, 'Phone number'),
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                      ),
                      AppTextField(
                        label: 'Password',
                        hint: '********',
                        controller: _passwordController,
                        validator: Validators.password,
                        obscureText: true,
                        maxLength: 32,
                      ),
                      AppTextField(
                        label: 'Repeat password',
                        hint: '********',
                        controller: _repeatPasswordController,
                        validator: Validators.matches(() => _passwordController.text, 'Password'),
                        obscureText: true,
                        maxLength: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
