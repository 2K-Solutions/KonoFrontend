import 'package:flutter/material.dart';
import 'package:konofrontend/core/widgets/primary_button.dart';

class BottomButtonScaffold extends StatelessWidget {
  const BottomButtonScaffold({
    super.key,
    required this.body,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.buttonIcon,
    this.showAppBar = true,
  });

  final Widget body;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final IconData? buttonIcon;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar() : null,
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(label: buttonLabel, icon: buttonIcon, onPressed: onButtonPressed),
        ),
      ),
    );
  }
}
