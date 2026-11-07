import 'package:flutter/material.dart';
import 'package:konofrontend/core/theme.dart';

// Returns the new note (possibly empty), or null when the worker backs out.
Future<String?> showItemNoteDialog(BuildContext context, {required String itemName, String initialNote = ''}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _ItemNoteDialog(itemName: itemName, initialNote: initialNote),
  );
}

class _ItemNoteDialog extends StatefulWidget {
  const _ItemNoteDialog({required this.itemName, required this.initialNote});

  final String itemName;
  final String initialNote;

  @override
  State<_ItemNoteDialog> createState() => _ItemNoteDialogState();
}

class _ItemNoteDialogState extends State<_ItemNoteDialog> {
  late final _controller = TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.itemName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Add a note for the kitchen or bar.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 6,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. medium-rare, no rosemary (allergy)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: buttonShape,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 48),
                      shape: buttonShape,
                    ),
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
