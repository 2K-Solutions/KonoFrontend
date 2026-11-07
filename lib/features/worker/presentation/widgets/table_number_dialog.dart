import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/api_error.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/features/worker/data/order_repository.dart';
import 'package:konofrontend/features/worker/domain/restaurant_table.dart';

// Asks for a table number and resolves it to one of the restaurant's tables.
// Returns null (after telling the worker why) when cancelled or the table doesn't exist.
Future<RestaurantTable?> pickTable(BuildContext context, WidgetRef ref, {int? initialNumber}) async {
  final repository = ref.read(orderRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  void show(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  final number = await showDialog<int>(
    context: context,
    builder: (context) => TableNumberDialog(initialNumber: initialNumber),
  );
  if (number == null) return null;

  final List<RestaurantTable> tables;
  try {
    tables = await repository.getTables();
  } catch (error) {
    show(apiErrorMessage(error, fallback: 'Could not load the tables. Please try again.'));
    return null;
  }

  final table = tables.where((table) => table.number == number).firstOrNull;
  if (table == null) show('Table $number does not exist.');
  return table;
}

class TableNumberDialog extends StatefulWidget {
  const TableNumberDialog({super.key, this.initialNumber});

  final int? initialNumber;

  @override
  State<TableNumberDialog> createState() => _TableNumberDialogState();
}

class _TableNumberDialogState extends State<TableNumberDialog> {
  // Table numbers are a `short` on the backend.
  static const _maxDigits = 4;

  late String _digits = widget.initialNumber?.toString() ?? '';

  void _append(int digit) {
    if (_digits.length >= _maxDigits || (_digits.isEmpty && digit == 0)) return;
    setState(() => _digits += '$digit');
  }

  void _backspaceOrCancel() {
    if (_digits.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Table number', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Container(
              height: 56,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: AppDecorations.card,
              child: Text(
                _digits.isEmpty ? '–' : _digits,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _digits.isEmpty ? AppColors.textMuted : AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final row in const [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ])
              _KeyRow(children: [for (final digit in row) _DigitKey(digit: digit, onTap: _append)]),
            _KeyRow(
              children: [
                _Key(
                  color: AppColors.danger,
                  onTap: _backspaceOrCancel,
                  tooltip: _digits.isEmpty ? 'Cancel' : 'Delete',
                  child: Icon(_digits.isEmpty ? Icons.close : Icons.backspace_outlined, color: Colors.white),
                ),
                _DigitKey(digit: 0, onTap: _append),
                _Key(
                  color: _digits.isEmpty ? AppColors.success.withValues(alpha: 0.3) : AppColors.success,
                  onTap: _digits.isEmpty ? null : () => Navigator.of(context).pop(int.parse(_digits)),
                  tooltip: 'Confirm',
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final int digit;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return _Key(
      color: const Color(0xFFF2F2F2),
      onTap: () => onTap(digit),
      child: Text(
        '$digit',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.onTap, required this.child, this.tooltip});

  final Color color;
  final VoidCallback? onTap;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final key = SizedBox(
      height: 56,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(child: child),
        ),
      ),
    );
    return tooltip == null ? key : Tooltip(message: tooltip!, child: key);
  }
}
