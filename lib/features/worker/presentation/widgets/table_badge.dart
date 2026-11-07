import 'package:flutter/material.dart';
import 'package:konofrontend/core/theme.dart';

// The round table-number badge in the top corner of the order screens.
class TableBadge extends StatelessWidget {
  const TableBadge({super.key, required this.number, this.onTap});

  final int? number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasNumber = number != null;

    return Tooltip(
      message: hasNumber ? 'Table $number' : 'Choose a table',
      child: Material(
        color: hasNumber ? AppColors.primary : Colors.white,
        shape: CircleBorder(side: BorderSide(color: hasNumber ? AppColors.primary : AppColors.border)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: hasNumber
                  ? Text(
                      '$number',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    )
                  : const Icon(Icons.table_restaurant_outlined, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
