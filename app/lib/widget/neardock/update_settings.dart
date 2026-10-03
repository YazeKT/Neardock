// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/provider/update_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NeardockUpdateSettings extends StatefulWidget {
  const NeardockUpdateSettings({super.key});
  @override
  State<NeardockUpdateSettings> createState() => _NeardockUpdateSettingsState();
}

class _NeardockUpdateSettingsState extends State<NeardockUpdateSettings> {
  @override
  Widget build(BuildContext context) {
    final update = context.watch(neardockUpdateProvider);
    final persistence = context.ref.read(persistenceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Check for updates on launch'),
          subtitle: const Text('Contacts GitHub. Installation always needs your approval.'),
          value: persistence.getAutomaticUpdatesEnabled(),
          onChanged: (value) async {
            await persistence.setAutomaticUpdatesEnabled(value);
            if (mounted) setState(() {});
          },
        ),
        Text(update.message),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: update.busy ? null : () => context.ref.notifier(neardockUpdateProvider).check(),
              icon: const Icon(Icons.refresh),
              label: const Text('Check now'),
            ),
            if (update.release != null)
              FilledButton.icon(onPressed: update.busy ? null : _install, icon: const Icon(Icons.system_update_alt), label: const Text('Update')),
            TextButton(
              onPressed: () => launchUrl(Uri.parse(neardockReleasesUrl), mode: LaunchMode.externalApplication),
              child: const Text('Releases & changelog'),
            ),
          ],
        ),
        if (update.busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
        const SizedBox(height: 8),
        Text(
          Platform.isWindows
              ? 'Windows installers are unsigned. Portable updates preserve your settings when you replace app files only.'
              : 'Android opens its system installer. Updates must use the same Neardock signing identity.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _install() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Neardock?'),
        content: const Text(
          'Download the matching release from YazeKT/Neardock and verify its SHA-256 digest. The system installer will ask you to finish the update. Portable builds download a ZIP for manual replacement; keep settings.json.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Download update')),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final portable = context.ref.read(persistenceProvider).isPortableMode();
    final file = await context.ref.notifier(neardockUpdateProvider).download(portable: portable);
    if (file == null || !mounted) return;
    try {
      if (Platform.isWindows && file.path.endsWith('.exe')) {
        await Process.start(file.path, const [], mode: ProcessStartMode.detached);
      } else {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The system could not open the update: ${result.message}')));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the verified update. Try the releases page.')));
      }
    }
  }
}
