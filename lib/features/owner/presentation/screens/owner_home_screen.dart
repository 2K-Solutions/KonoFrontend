import 'package:flutter/material.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/icon_menu_card.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are in charge', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Manage your restaurant.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.payments_outlined,
                  label: 'Revenue',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.bar_chart,
                  label: 'Statistics',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.groups_outlined,
                  label: 'Staff list',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {},
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
