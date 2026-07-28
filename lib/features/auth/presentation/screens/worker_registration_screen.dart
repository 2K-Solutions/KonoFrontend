import 'package:flutter/material.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';

class WorkerRegistrationScreen extends StatelessWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomButtonScaffold(
      buttonLabel: 'Sign up',
      onButtonPressed: () {},
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work with us!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    AppTextField(label: 'First name', hint: 'Enter your first name', maxLength: 25),
                    AppTextField(label: 'Last name', hint: 'Enter your last name', maxLength: 25),
                    AppTextField(label: 'E-mail', hint: 'example@kono.rest', maxLength: 50),
                    AppTextField(
                      label: 'Phone number',
                      hint: '+1 234 567 8900',
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                    ),
                    AppTextField(
                      label: 'Password',
                      hint: '********',
                      obscureText: true,
                      maxLength: 32,
                    ),
                    AppTextField(
                      label: 'Repeat password',
                      hint: '********',
                      obscureText: true,
                      maxLength: 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
