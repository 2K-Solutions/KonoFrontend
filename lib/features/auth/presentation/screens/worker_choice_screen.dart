import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/choice_card.dart';

class WorkerChoiceScreen extends StatelessWidget {
  const WorkerChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChoiceCard(
                icon: Icons.person_add_alt_1,
                title: 'Sign up',
                subtitle: 'Join the crew',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                onTap: () => context.push(AppRoutes.workerRegister),
              ),
            ),
            Expanded(
              child: ChoiceCard(
                icon: Icons.login,
                title: 'Log in',
                subtitle: 'Back to work',
                onTap: () => context.push(AppRoutes.workerLogin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
