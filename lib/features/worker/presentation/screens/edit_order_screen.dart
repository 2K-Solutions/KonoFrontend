import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/api_error.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/features/worker/data/order_draft.dart';
import 'package:konofrontend/features/worker/data/order_repository.dart';
import 'package:konofrontend/features/worker/data/order_service.dart';
import 'package:konofrontend/features/worker/domain/order.dart';
import 'package:konofrontend/features/worker/presentation/widgets/order_line_list.dart';
import 'package:konofrontend/features/worker/presentation/widgets/table_badge.dart';

// Edits an order that was already sent. Changes stay local until the worker saves.
class EditOrderScreen extends ConsumerStatefulWidget {
  const EditOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  Order? _order;
  int? _tableNumber;
  String? _loadError;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    _load();
  }

  Future<void> _load() async {
    final repository = ref.read(orderRepositoryProvider);
    final service = ref.read(orderServiceProvider);

    try {
      final orders = await repository.getMyOrders();
      final order = orders.where((order) => order.id == widget.orderId).firstOrNull;
      if (order == null) throw StateError('missing');

      final lines = await service.loadOrderLines(order.id);
      int? tableNumber;
      try {
        final tables = await repository.getTables();
        tableNumber = tables.where((table) => table.id == order.tableId).firstOrNull?.number;
      } catch (_) {
        // The table number is only shown in the badge; the order can be edited without it.
      }

      if (!mounted) return;
      ref.read(orderDraftProvider(widget.orderId).notifier).load(lines: lines);
      setState(() {
        _order = order;
        _tableNumber = tableNumber;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error is StateError
            ? 'This order no longer exists.'
            : apiErrorMessage(error, fallback: 'Could not load the order. Please try again.');
      });
    }
  }

  Future<void> _save() async {
    final order = _order;
    if (order == null || _isSaving) return;
    final lines = ref.read(orderDraftProvider(widget.orderId)).lines;

    // The backend rejects orders without items, so an emptied order is deleted instead.
    if (lines.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete this order?'),
          content: const Text('You removed every item, so the order will be deleted.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final repository = ref.read(orderRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    String message;
    var saved = false;
    try {
      if (lines.isEmpty) {
        await repository.deleteOrder(order.id);
        message = 'The order was deleted.';
      } else {
        await repository.editOrder(orderId: order.id, tableId: order.tableId, lines: lines);
        message = 'The order was updated.';
      }
      saved = true;
    } catch (error) {
      message = apiErrorMessage(error, fallback: 'Could not save the order. Please try again.');
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      ref.invalidate(myOrdersProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the draft alive while this screen (or the menu on top of it) is open.
    ref.watch(orderDraftProvider(widget.orderId));
    final canEdit = _order != null && !_isSaving;

    return Scaffold(
      appBar: AppBar(
        bottom: _isSaving
            ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit order', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Changes are sent when you save.', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_order != null) TableBadge(number: _tableNumber),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(child: AbsorbPointer(absorbing: _isSaving, child: _buildBody())),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [
          BottomAction(icon: Icons.arrow_back, label: 'Back', onTap: () => context.pop()),
          if (canEdit)
            BottomAction(
              icon: Icons.add,
              label: 'Add',
              onTap: () => context.push(AppRoutes.workerMenuFor(AppRoutes.workerFood, orderId: widget.orderId)),
            ),
          if (canEdit)
            BottomAction(icon: Icons.check_circle_outline, label: 'Save', color: AppColors.success, onTap: _save),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final loadError = _loadError;
    if (loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loadError, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(onPressed: _retry,icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ),
      );
    }

    return OrderLineList(
      draftKey: widget.orderId,
      emptyMessage: 'Every item was removed.\nSave to delete the order, or tap + to add items.',
    );
  }
}
