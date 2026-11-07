import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/square_icon_button.dart';
import 'package:konofrontend/features/worker/data/order_draft.dart';
import 'package:konofrontend/features/worker/domain/order.dart';
import 'package:konofrontend/features/worker/presentation/widgets/item_note_dialog.dart';

// The editable lines of an order draft, shared by the current order and edit order screens.
class OrderLineList extends ConsumerWidget {
  const OrderLineList({super.key, required this.draftKey, required this.emptyMessage});

  final String draftKey;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(orderDraftProvider(draftKey).select((draft) => draft.lines));
    final notifier = ref.read(orderDraftProvider(draftKey).notifier);

    if (lines.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: lines.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final line = lines[index];
        return _OrderLineTile(
          line: line,
          onRemove: () => notifier.changeQuantityAt(index, -1),
          onAdd: () => notifier.changeQuantityAt(index, 1),
          onEditNote: () async {
            final note = await showItemNoteDialog(context, itemName: line.name, initialNote: line.description);
            if (note != null) notifier.setNoteAt(index, note);
          },
        );
      },
    );
  }
}

class _OrderLineTile extends StatelessWidget {
  const _OrderLineTile({
    required this.line,
    required this.onRemove,
    required this.onAdd,
    required this.onEditNote,
  });

  final OrderLine line;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final VoidCallback onEditNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                line.isDrink ? Icons.local_bar_outlined : Icons.restaurant_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: line.name,
                    children: [
                      TextSpan(
                        text: '  ${line.quantity}×',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              SquareIconButton(
                icon: line.quantity == 1 ? Icons.delete_outline : Icons.remove,
                onPressed: onRemove,
                color: line.quantity == 1 ? AppColors.danger : AppColors.primary,
                tooltip: line.quantity == 1 ? 'Remove' : 'One less',
              ),
              const SizedBox(width: 8),
              SquareIconButton(icon: Icons.edit_outlined, onPressed: onEditNote, tooltip: 'Edit note'),
              const SizedBox(width: 8),
              SquareIconButton(icon: Icons.add, onPressed: onAdd, filled: true, tooltip: 'One more'),
            ],
          ),
          if (line.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(line.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
