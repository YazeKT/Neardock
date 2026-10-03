// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

class WelcomePanel extends StatefulWidget {
  final Future<void> Function() onComplete;
  const WelcomePanel({required this.onComplete, super.key});
  @override
  State<WelcomePanel> createState() => _WelcomePanelState();
}

class _WelcomePanelState extends State<WelcomePanel> {
  int _step = 0;
  bool _saving = false;
  bool _automaticUpdates = true;
  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await context.ref.read(persistenceProvider).setAutomaticUpdatesEnabled(_automaticUpdates);
      await widget.onComplete();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.wifi, t.neardockUI.setupNetwork, t.neardockUI.setupNetworkBody),
      (Icons.send_outlined, t.neardockUI.setupTransfer, t.neardockUI.setupTransferBody),
      (Icons.content_paste_outlined, t.neardockUI.setupPrivacy, t.neardockUI.setupPrivacyBody),
    ];
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Image.asset('assets/img/logo-128.png', width: 72, height: 72)),
                const SizedBox(height: 20),
                Text(t.neardockUI.welcome, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(t.neardockUI.welcomeSubtitle, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(steps[_step].$1, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Text('${_step + 1} / 3'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(steps[_step].$2, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(steps[_step].$3),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _automaticUpdates,
                  onChanged: (value) => setState(() => _automaticUpdates = value ?? false),
                  title: Text(t.neardockUI.checkUpdates),
                  subtitle: Text(t.neardockUI.updatePrivacy),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (_step < 2) {
                            setState(() => _step++);
                          } else {
                            await _finish();
                          }
                        },
                  child: Text(_step < 2 ? t.neardockUI.next : t.neardockUI.getStarted),
                ),
                TextButton(onPressed: _saving ? null : _finish, child: Text(t.neardockUI.skipSetup)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
