import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.title, this.nextRoute});

  final String title;
  final String? nextRoute;

  @override
  Widget build(BuildContext context) {
    return BottomButtonScaffold(
      buttonLabel: 'Log in',
      onButtonPressed: () {
        if (nextRoute != null) context.go(nextRoute!);
      },
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            const AppTextField(
              label: 'E-mail',
              hint: 'owner@kono.rest',
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
            ),
            const AppTextField(
              label: 'Password',
              hint: '********',
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
    );
  }
}
