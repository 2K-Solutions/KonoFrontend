import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';
import 'package:konofrontend/core/widgets/tappable_card.dart';
import 'package:konofrontend/features/auth/data/logout.dart';
import 'package:konofrontend/features/worker/data/invite_repository.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  ConsumerState<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen> {
  bool _isLeaving = false;

  Future<void> _logout() async {
    await logout(ref);
    if (!mounted) return;
    context.go(AppRoutes.roleSelection);
  }

  Future<void> _leaveRestaurant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave restaurant?'),
        content: const Text(
          'You will lose access to the floor system until an owner invites you again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLeaving = true);

    final result = await ref.read(inviteRepositoryProvider).abandonRestaurant();

    if (!mounted) return;

    if (result.success) {
      // Startup refreshes the token so the new account type routes to the invites screen.
      context.go(AppRoutes.startup);
      return;
    }

    setState(() => _isLeaving = false);
    _showMessage(result.message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).inputDecorationTheme.labelStyle;
    final isWorker = ref.watch(accessTokenClaimsProvider).value?['accountType'] == 'worker';

    return BottomButtonScaffold(
      buttonLabel: 'Save changes',
      buttonIcon: Icons.save_outlined,
      onButtonPressed: () {},
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROFILE', style: labelStyle),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marko Marković',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text('Waiter #124', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Change photo',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const AppTextField(label: 'Full name', hint: 'Marko Marković', maxLength: 50),
            const AppTextField(label: 'Username', hint: 'marko_m', maxLength: 25),
            const AppTextField(
              label: 'E-mail',
              hint: 'marko.markovic@kono.rest',
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
            ),
            const AppTextField(
              label: 'Phone number',
              hint: '+1 234 567 8900',
              keyboardType: TextInputType.phone,
              maxLength: 15,
            ),
            const SizedBox(height: 16),
            Text('SETTINGS', style: labelStyle),
            const SizedBox(height: 12),
            Container(
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  SwitchListTile(
                    value: false,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.primary,
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: const Text('Dark mode'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: const Text('Language'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'English',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TappableCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: _logout,
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Log out',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            if (isWorker) ...[
              const SizedBox(height: 12),
              TappableCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: _isLeaving ? null : _leaveRestaurant,
                child: Row(
                  children: [
                    _isLeaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.exit_to_app, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Leave restaurant',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
