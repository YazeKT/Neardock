// Modified for Neardock by Yaze Media, 2026. Upstream notices and Apache 2.0 licence retained.
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/server/server_state.dart';
import 'package:localsend_app/pages/receive_history_page.dart';
import 'package:localsend_app/pages/web_share_page.dart';
import 'package:localsend_app/provider/local_ip_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/receive_history_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/pick_directory_path.dart';
import 'package:localsend_app/widget/neardock/screen_header.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class ReceiveTab extends StatefulWidget {
  const ReceiveTab();
  @override
  State<ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  bool _showAdvanced = false;
  @override
  Widget build(BuildContext context) {
    final settings = context.watch(settingsProvider);
    final serverState = context.watch(serverProvider);
    final localIps = context.watch(localIpProvider).localIps;
    final history = context.watch(receiveHistoryProvider).where((e) => !e.isMessage).take(5).toList();
    final theme = Theme.of(context);
    return ResponsiveListView(
      maxWidth: 840,
      padding: const EdgeInsets.all(24),
      tabletPadding: const EdgeInsets.all(32),
      children: [
        ScreenHeader(
          title: t.receiveTab.title,
          subtitle: t.neardockUI.receiveSubtitle,
          trailing: IconButton(
            tooltip: t.receiveTab.infoBox.ip,
            onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
            icon: const Icon(Icons.info_outline),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
                  child: const Icon(Icons.devices, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serverState?.alias ?? settings.alias, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: serverState == null ? theme.colorScheme.error : const Color(0xFF48D997)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(serverState == null ? t.general.offline : t.neardockUI.readyToReceive)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showAdvanced) _InfoBox(serverState: serverState, localIps: localIps, showAdvanced: true),
        const SizedBox(height: 28),
        Text(t.settingsTab.receive.destination, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(settings.destination ?? t.settingsTab.receive.downloads, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              tooltip: t.general.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final path = await pickDirectoryPath();
                if (path != null && context.mounted) await context.ref.notifier(settingsProvider).setDestination(path);
              },
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Text(t.neardockUI.recentFiles, style: theme.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => context.push(() => const ReceiveHistoryPage()),
              icon: const Icon(Icons.history),
              label: Text(t.receiveHistoryPage.title),
            ),
          ],
        ),
        if (history.isEmpty)
          Card(
            child: Padding(padding: const EdgeInsets.all(20), child: Text(t.neardockUI.emptyFiles)),
          ),
        for (final entry in history)
          Card(
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(entry.fileName, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('${entry.senderAlias} · ${entry.timestampString}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(() => const ReceiveHistoryPage()),
            ),
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => context.push(() => const WebSharePage()),
          icon: const Icon(Icons.language),
          label: Text(t.receiveTab.link),
        ),
        const SizedBox(height: 16),
        Text(t.neardockUI.visibilityHelp, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final ServerState? serverState;
  final List<String> localIps;
  final bool showAdvanced;

  const _InfoBox({
    required this.serverState,
    required this.localIps,
    required this.showAdvanced,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: showAdvanced ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: Container(),
      secondChild: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      Text(t.receiveTab.infoBox.alias),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: SelectableText(serverState?.alias ?? '-'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(t.receiveTab.infoBox.ip),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (localIps.isEmpty) Text(t.general.unknown),
                          ...localIps.map((ip) => SelectableText(ip)),
                        ],
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(t.receiveTab.infoBox.port),
                      const SizedBox(width: 10),
                      SelectableText(serverState?.port.toString() ?? '-'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
