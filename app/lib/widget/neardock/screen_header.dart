// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const ScreenHeader({required this.title, required this.subtitle, this.trailing, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
