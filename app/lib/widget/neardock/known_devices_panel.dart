// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/known_devices_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

class KnownDevicesPanel extends StatelessWidget {
  const KnownDevicesPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final devices = context.watch(knownDevicesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.neardockUI.knownDevices, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(t.neardockUI.deviceTrustHelp),
        if (devices.isEmpty) Text(t.neardockUI.emptyDevices),
        for (final device in devices)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(device.trusted ? Icons.verified_user_outlined : Icons.devices),
            title: Text(device.alias),
            subtitle: Text('${device.model ?? device.type} · ${device.trusted ? t.neardockUI.trusted : t.neardockUI.reviewRequired}'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(device.alias),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SelectableText('${t.neardockUI.deviceModel}: ${device.model ?? device.type}'),
                      const SizedBox(height: 8),
                      SelectableText('${t.neardockUI.addresses}: ${device.addresses.join(', ')}'),
                      const SizedBox(height: 8),
                      Text('${t.neardockUI.lastSeen}: ${DateFormat.yMd().add_jm().format(device.lastSeen.toLocal())}'),
                      const SizedBox(height: 8),
                      SelectableText('${t.neardockUI.fingerprint}: ${device.fingerprint}'),
                      const SizedBox(height: 12),
                      Text(t.neardockUI.deviceTrustHelp),
                    ],
                  ),
                ),
                actions: [
                  if (device.trusted)
                    TextButton(
                      onPressed: () async {
                        await context.ref.notifier(knownDevicesProvider).setTrusted(device.fingerprint, false);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: Text(t.neardockUI.revokeTrust),
                    ),
                  TextButton(
                    onPressed: () async {
                      await context.ref.notifier(knownDevicesProvider).forget(device.fingerprint);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: Text(t.neardockUI.forgetDevice),
                  ),
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t.general.close)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
