import 'package:flutter/material.dart';
import 'package:konofrontend/core/theme.dart';

class BottomAction {
  const BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.actions});

  final List<BottomAction> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            for (final action in actions) Expanded(child: _BottomActionButton(action: action)),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({required this.action});

  final BottomAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: action.color, size: 28),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: TextStyle(color: action.color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
