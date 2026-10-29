import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_button_scaffold.dart';
import 'package:konofrontend/core/widgets/tappable_card.dart';
import 'package:konofrontend/features/worker/data/invite_repository.dart';
import 'package:konofrontend/features/worker/domain/restaurant_invite.dart';

class WorkerInvitesScreen extends ConsumerStatefulWidget {
  const WorkerInvitesScreen({super.key});

  @override
  ConsumerState<WorkerInvitesScreen> createState() => _WorkerInvitesScreenState();
}

class _WorkerInvitesScreenState extends ConsumerState<WorkerInvitesScreen> {
  String? _busyInviteId;
  String? _errorMessage;
  String? _joinedRestaurantName;

  Future<void> _accept(RestaurantInvite invite) async {
    setState(() {
      _busyInviteId = invite.id;
      _errorMessage = null;
    });

    final result = await ref.read(inviteRepositoryProvider).accept(invite.id);

    if (!mounted) return;

    if (result.success) {
      if (result.accessToken != null && result.refreshToken != null) {
        await ref.read(tokenStorageProvider).saveTokens(
              accessToken: result.accessToken!,
              refreshToken: result.refreshToken!,
            );
      }
      if (!mounted) return;
      setState(() {
        _busyInviteId = null;
        _joinedRestaurantName = invite.restaurantName;
      });
      return;
    }

    setState(() {
      _busyInviteId = null;
      _errorMessage = result.message;
    });
    ref.invalidate(myInvitesProvider);
  }

  Future<void> _decline(RestaurantInvite invite) async {
    setState(() {
      _busyInviteId = invite.id;
      _errorMessage = null;
    });

    final result = await ref.read(inviteRepositoryProvider).decline(invite.id);

    if (!mounted) return;

    setState(() {
      _busyInviteId = null;
      if (!result.success) _errorMessage = result.message;
    });
    ref.invalidate(myInvitesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final joinedRestaurantName = _joinedRestaurantName;

    if (joinedRestaurantName != null) {
      return BottomButtonScaffold(
        buttonLabel: 'Continue',
        buttonIcon: Icons.arrow_forward,
        showAppBar: false,
        onButtonPressed: () => context.go(AppRoutes.workerHome),
        body: _StatusMessage(
          icon: Icons.check_circle_outline,
          title: 'Welcome to $joinedRestaurantName!',
          subtitle: 'Your account is now active. You can start working on the floor.',
        ),
      );
    }

    final invites = ref.watch(myInvitesProvider);

    return BottomButtonScaffold(
      buttonLabel: 'Check for invites',
      buttonIcon: Icons.refresh,
      showAppBar: false,
      onButtonPressed: () {
        setState(() => _errorMessage = null);
        ref.invalidate(myInvitesProvider);
      },
      body: Stack(
        children: [
          invites.when(
            data: (data) => data.isEmpty
                ? const _StatusMessage(
                    icon: Icons.pending_actions,
                    title: 'Wait till the owner invites you',
                    subtitle: 'Your account is currently inactive. Contact your restaurant manager to '
                        'grant you access to the floor system.',
                  )
                : _InviteList(
                    invites: data,
                    busyInviteId: _busyInviteId,
                    errorMessage: _errorMessage,
                    onAccept: _accept,
                    onDecline: _decline,
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Could not load your invites. Please try again.',
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.workerProfile),
                  customBorder: const CircleBorder(),
                  child: const Center(
                    child: Icon(Icons.person_outline, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteList extends StatelessWidget {
  const _InviteList({
    required this.invites,
    required this.busyInviteId,
    required this.errorMessage,
    required this.onAccept,
    required this.onDecline,
  });

  final List<RestaurantInvite> invites;
  final String? busyInviteId;
  final String? errorMessage;
  final ValueChanged<RestaurantInvite> onAccept;
  final ValueChanged<RestaurantInvite> onDecline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 88, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You\'ve been invited!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Accept an invite to join the restaurant\'s crew.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(errorMessage!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: invites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final invite = invites[index];
                return _InviteCard(
                  invite: invite,
                  isBusy: busyInviteId == invite.id,
                  isDisabled: busyInviteId != null,
                  onAccept: () => onAccept(invite),
                  onDecline: () => onDecline(invite),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.isBusy,
    required this.isDisabled,
    required this.onAccept,
    required this.onDecline,
  });

  final RestaurantInvite invite;
  final bool isBusy;
  final bool isDisabled;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  String get _expiresLabel {
    final minutes = invite.expiresAt.difference(DateTime.now()).inMinutes;
    if (minutes < 1) return 'Expires in less than a minute';
    return 'Expires in $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
    const buttonTextStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

    return TappableCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.restaurantName,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    Text(
                      _expiresLabel,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isDisabled ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 40),
                    shape: buttonShape,
                    textStyle: buttonTextStyle,
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDisabled ? null : onAccept,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check, size: 16),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: buttonShape,
                    textStyle: buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
