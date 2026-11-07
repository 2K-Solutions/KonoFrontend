import 'package:flutter/material.dart';
import 'package:konofrontend/core/theme.dart';

class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.color = AppColors.primary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onPressed == null ? color.withValues(alpha: 0.3) : color;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: filled ? BorderSide.none : BorderSide(color: effectiveColor),
    );

    final button = SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: filled ? effectiveColor : Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Icon(icon, color: filled ? Colors.white : effectiveColor, size: 20),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
