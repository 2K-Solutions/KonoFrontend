import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/validators.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.go(AppRoutes.workerWaitForInvite);
  }

  @override
  Widget build(BuildContext context) {
    return BottomButtonScaffold(
      buttonLabel: 'Sign up',
      onButtonPressed: _submit,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work with us!', style: Theme.of(context).textTheme.headlineSmall),
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
