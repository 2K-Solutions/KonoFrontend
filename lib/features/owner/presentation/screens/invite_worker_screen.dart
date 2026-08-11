import 'package:flutter/material.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';

class InviteWorkerScreen extends StatelessWidget {
  const InviteWorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              AppTextField(
                label: 'Search for your workers',
                hint: 'Worker username or name',
                suffixIcon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
