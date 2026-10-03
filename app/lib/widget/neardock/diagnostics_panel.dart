// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/logging/discovery_logs_provider.dart';
import 'package:localsend_app/provider/logging/http_logs_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// Whitelist known diagnostic tokens; never export raw log messages.
String safeRequestDiagnostic(String raw) {
  final method = RegExp(r'\b(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)\b').firstMatch(raw)?.group(1);
  final status = RegExp(r'(?:HTTP|status|response)[ :]+([1-5][0-9]{2})\b', caseSensitive: false).firstMatch(raw)?.group(1);
  return [?method, if (status != null) 'HTTP $status', if (method == null && status == null) 'Request event'].join(' · ');
}

class DiagnosticsPanel extends StatelessWidget {
  const DiagnosticsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final logs = context.watch(httpLogsProvider);
    final discoveries = context.watch(discoveryLoggerProvider);
    final lines = logs.map((log) => '${log.timestamp.toLocal().toIso8601String()} · ${safeRequestDiagnostic(log.log)}').toList()
      ..addAll(discoveries.map((log) => '${log.timestamp.toLocal().toIso8601String()} · Device discovery event'))
      ..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.neardockUI.logsPrivacy),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: lines.isEmpty ? null : () => Clipboard.setData(ClipboardData(text: lines.join('\n'))),
              icon: const Icon(Icons.copy),
              label: Text(t.neardockUI.copyDiagnostics),
            ),
            TextButton.icon(
              onPressed: logs.isEmpty && discoveries.isEmpty
                  ? null
                  : () {
                      context.ref.notifier(httpLogsProvider).clear();
                      context.ref.notifier(discoveryLoggerProvider).clear();
                    },
              icon: const Icon(Icons.delete_outline),
              label: Text(t.neardockUI.clearLogs),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (lines.isEmpty) Text(t.neardockUI.noLogs),
        // The preview is bounded; the explicit copy action includes all buffered diagnostics.
        for (final line in lines.reversed.take(8)) SelectableText(line, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
