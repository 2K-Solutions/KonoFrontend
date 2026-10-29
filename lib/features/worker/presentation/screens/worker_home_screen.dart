import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/core/widgets/icon_menu_card.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Take an order', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Choose a category to start.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.local_bar_outlined,
                  label: 'Drinks',
                  borderColor: AppColors.primary,
                  onTap: () => context.push(AppRoutes.workerDrinks),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.restaurant_outlined,
                  label: 'Food',
                  borderColor: AppColors.primary,
                  onTap: () => context.push(AppRoutes.workerFood),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [
          BottomAction(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => context.push(AppRoutes.workerProfile),
          ),
          BottomAction(icon: Icons.table_restaurant_outlined, label: 'Tables', onTap: () {}),
          BottomAction(icon: Icons.edit_note, label: 'Edit order', onTap: () {}),
        ],
      ),
    );
  }
}
