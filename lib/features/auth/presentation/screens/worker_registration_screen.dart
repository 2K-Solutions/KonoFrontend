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
                    AppTextField(label: 'Ime (First name)', hint: 'Unesite ime'),
                    AppTextField(label: 'Prezime (Second name)', hint: 'Unesite prezime'),
                    AppTextField(label: 'E-mail', hint: 'example@kono.hr'),
                    AppTextField(
                      label: 'Broj telefona (Phone number)',
                      hint: '+385 9x xxx xxxx',
                      keyboardType: TextInputType.phone,
                    ),
                    AppTextField(label: 'Lozinka (Password)', hint: '********', obscureText: true),
                    AppTextField(
                      label: 'Ponovite lozinku (Repeat password)',
                      hint: '********',
                      obscureText: true,
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
