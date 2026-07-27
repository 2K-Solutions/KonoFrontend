import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/choice_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChoiceCard(
                icon: Icons.storefront_outlined,
                title: 'I am an owner',
                subtitle: 'Manage tables & staff',
                onTap: () => context.push(AppRoutes.ownerLogin),
              ),
            ),
            Expanded(
              child: ChoiceCard(
                icon: Icons.restaurant_menu,
                title: 'I am a worker',
                subtitle: 'Take orders & serve',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                onTap: () => context.push(AppRoutes.workerChoice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
