import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/tappable_card.dart';
import 'package:konofrontend/features/owner/data/restaurant_repository.dart';
import 'package:konofrontend/features/owner/domain/worker_search_result.dart';
import 'package:konofrontend/features/owner/selected_restaurant_provider.dart';

class InviteWorkerScreen extends ConsumerStatefulWidget {
  const InviteWorkerScreen({super.key});

  @override
  ConsumerState<InviteWorkerScreen> createState() => _InviteWorkerScreenState();
}

class _InviteWorkerScreenState extends ConsumerState<InviteWorkerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<WorkerSearchResult> _results = [];
  bool _isLoading = false;
  String? _invitingUserId;
  final Set<String> _invitedUserIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _performSearch(value));
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ref.read(restaurantRepositoryProvider).searchAvailableWorkers(query.trim());
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _invite(WorkerSearchResult worker) async {
    final restaurant = ref.read(selectedRestaurantProvider);
    if (restaurant == null) {
      _showMessage('Select a restaurant before inviting workers.');
      return;
    }

    setState(() => _invitingUserId = worker.id);

    final result = await ref.read(restaurantRepositoryProvider).inviteWorker(
          restaurantId: restaurant.id,
          userId: worker.id,
        );

    if (!mounted) return;

    setState(() {
      _invitingUserId = null;
      if (result.success) _invitedUserIds.add(worker.id);
    });
    _showMessage(result.success ? 'Invite sent to ${worker.username}.' : result.message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).inputDecorationTheme.labelStyle;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Search for your workers',
                hint: 'Worker username or name',
                controller: _searchController,
                onChanged: _onSearchChanged,
                suffixIcon: const Icon(Icons.search),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_results.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('RECENTLY FOUND', style: labelStyle),
                            Text(
                              '${_results.length} results',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (final worker in _results)
                          _WorkerResultCard(
                            worker: worker,
                            isInviting: _invitingUserId == worker.id,
                            isInvited: _invitedUserIds.contains(worker.id),
                            onInvite: () => _invite(worker),
                          ),
                      ],
                      const SizedBox(height: 24),
                      const _SearchInfoBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerResultCard extends StatelessWidget {
  const _WorkerResultCard({
    required this.worker,
    required this.isInviting,
    required this.isInvited,
    required this.onInvite,
  });

  final WorkerSearchResult worker;
  final bool isInviting;
  final bool isInvited;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TappableCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.username,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  Text(
                    '(${worker.firstName} ${worker.secondName})',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: isInviting || isInvited ? null : onInvite,
              icon: isInviting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(isInvited ? Icons.check : Icons.mail_outline, size: 16),
              label: Text(isInvited ? 'Invited' : 'Invite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.success.withValues(alpha: isInviting ? 1 : 0.15),
                disabledForegroundColor: isInviting ? Colors.white : AppColors.success,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInfoBox extends StatelessWidget {
  const _SearchInfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Workers must have an active Kono Unified account to appear in search results. '
              'If you can\'t find them, ask them to share their exact username.',
              style: TextStyle(color: AppColors.textDark, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
