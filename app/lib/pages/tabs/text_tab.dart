// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/pages/home_page.dart';
import 'package:localsend_app/provider/conversation_provider.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_app/widget/dialogs/address_input_dialog.dart';
import 'package:localsend_app/widget/neardock/screen_header.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/file_type.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:uuid/uuid.dart';

class TextTab extends StatefulWidget {
  final bool clipboard;
  final Device? requestPeer;
  const TextTab({required this.clipboard, this.requestPeer, super.key});
  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _composer = TextEditingController();
  final _search = TextEditingController();
  final _drafts = <String, String>{};
  String? _fingerprint;
  Device? _manualDevice;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fingerprint = widget.requestPeer?.fingerprint;
    _composer.addListener(_rebuild);
    _search.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _composer.dispose();
    _search.dispose();
    super.dispose();
  }

  void _select(String fingerprint) {
    if (!widget.clipboard && _fingerprint != null) _drafts[_fingerprint!] = _composer.text;
    setState(() => _fingerprint = fingerprint);
    if (!widget.clipboard) _composer.text = _drafts[fingerprint] ?? '';
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.general.copiedToClipboard)));
  }

  Future<void> _send(Device device, {String? retryText}) async {
    final text = retryText ?? _composer.text;
    if (_sending || text.trim().isEmpty) return;
    setState(() => _sending = true);
    final bytes = utf8.encode(text);
    try {
      await context.ref
          .notifier(sendProvider)
          .startSession(
            target: device,
            files: [
              CrossFile(
                name: '${const Uuid().v4()}.txt',
                fileType: FileType.text,
                size: bytes.length,
                thumbnail: null,
                asset: null,
                path: null,
                bytes: bytes,
                lastModified: null,
                lastAccessed: null,
              ),
            ],
            background: false,
            textReturnTab: widget.clipboard ? HomeTab.clipboard : HomeTab.chat,
          );
      if (retryText == null && mounted) {
        // Keep the compose text on failure. Only a protocol-confirmed completed
        // text session may clear the draft; the inbox preserves the sent text.
        final messages = context.ref.read(conversationProvider);
        final sent = messages.where((m) => m.outgoing && m.peerFingerprint == device.fingerprint && m.text == text).lastOrNull;
        if (sent?.status == 'finished' && _composer.text == text) {
          _composer.clear();
          _drafts.remove(device.fingerprint);
        }
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.neardockUI.sendTextError)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _manualConnection() async {
    final device = await showDialog<Device>(context: context, builder: (_) => const AddressInputDialog());
    if (device != null && mounted) {
      _manualDevice = device;
      _select(device.fingerprint);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final messages = context.watch(conversationProvider);
    final nearby = context.watch(nearbyDevicesProvider).allDevices;
    final sessions = context.watch(sendProvider);
    final favourites = context.watch(favoritesProvider);
    final devices = {
      ...nearby,
      if (_manualDevice case final Device manual) manual.fingerprint: manual,
      if (widget.requestPeer case final Device peer) peer.fingerprint: peer,
    };
    final peers = <String, String>{
      for (final message in messages) message.peerFingerprint: message.peerAlias,
      for (final device in devices.values.where((d) => d.ip != null)) device.fingerprint: device.alias,
    };
    for (final favourite in favourites) {
      if (peers.containsKey(favourite.fingerprint)) peers[favourite.fingerprint] = favourite.alias;
    }
    final device = devices[_fingerprint];
    final conversation = messages.where((m) => m.peerFingerprint == _fingerprint).toList();
    final request = widget.requestPeer != null;
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        final peerList = ListView(
          padding: EdgeInsets.all(constraints.maxWidth >= 850 ? 32 : 24),
          children: [
            ScreenHeader(
              title: t.neardockUI.chat,
              subtitle: t.neardockUI.chatSubtitle,
              trailing: IconButton(tooltip: t.neardockUI.connectAddress, onPressed: _manualConnection, icon: const Icon(Icons.add)),
            ),
            TextField(
              controller: _search,
              decoration: InputDecoration(hintText: t.neardockUI.findDevice, prefixIcon: Icon(Icons.search)),
            ),
            const SizedBox(height: 16),
            if (peers.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text(t.neardockUI.emptyDevices)),
            for (final peer in peers.entries.where((p) => p.value.toLowerCase().contains(_search.text.toLowerCase())))
              Card(
                child: ListTile(
                  selected: peer.key == _fingerprint,
                  leading: Icon(devices[peer.key]?.deviceType.icon ?? Icons.devices),
                  title: Text(peer.value, overflow: TextOverflow.ellipsis),
                  subtitle: Text(devices[peer.key]?.ip != null ? t.neardockUI.nearby : t.neardockUI.offline),
                  onTap: () => _select(peer.key),
                ),
              ),
          ],
        );
        if (widget.clipboard) {
          final incoming = messages.where((m) => !m.outgoing).toList().reversed.take(30);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                padding: EdgeInsets.all(constraints.maxWidth >= 850 ? 32 : 24),
                children: [
                  ScreenHeader(title: t.neardockUI.clipboard, subtitle: t.neardockUI.clipboardSubtitle),
                  Text(t.neardockUI.draftLabel),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _composer,
                    minLines: 5,
                    maxLines: 10,
                    decoration: InputDecoration(hintText: t.neardockUI.draftHint),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final value = await Clipboard.getData(Clipboard.kTextPlain);
                          if (mounted && value?.text != null) _composer.text = value!.text!;
                        },
                        icon: const Icon(Icons.content_paste),
                        label: Text(t.neardockUI.pasteText),
                      ),
                      OutlinedButton.icon(onPressed: _composer.clear, icon: const Icon(Icons.delete_outline), label: Text(t.general.delete)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _devicePicker(devices),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: device?.ip != null && !_sending && _composer.text.trim().isNotEmpty ? () => _send(device!) : null,
                    icon: const Icon(Icons.send),
                    label: Text(t.neardockUI.sendText),
                  ),
                  const SizedBox(height: 32),
                  Text(t.neardockUI.receivedText, style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (incoming.isEmpty) Text(t.neardockUI.emptyText),
                  for (final message in incoming)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(message.text),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${message.peerAlias} · ${DateFormat.yMd().add_jm().format(message.timestamp.toLocal())}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                IconButton(tooltip: t.neardockUI.copyText, onPressed: () => _copy(message.text), icon: const Icon(Icons.copy)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        if (_fingerprint == null) return peerList;
        final thread = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (!wide && !request)
                    IconButton(tooltip: t.general.close, onPressed: () => setState(() => _fingerprint = null), icon: const Icon(Icons.arrow_back)),
                  Icon(device?.deviceType.icon ?? Icons.devices),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(peers[_fingerprint] ?? t.neardockUI.device, style: theme.textTheme.titleMedium),
                        Text(device?.ip != null ? t.neardockUI.nearby : t.neardockUI.offline, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: t.neardockUI.clearConversation,
                    onPressed: () async {
                      if (await confirmClearTextHistory(context)) {
                        if (context.mounted) await context.ref.notifier(conversationProvider).clear(fingerprint: _fingerprint);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(20),
                itemCount: conversation.length,
                itemBuilder: (context, index) {
                  final message = conversation[conversation.length - index - 1];
                  final session = sessions[message.id.replaceFirst('send:', '')];
                  final status = session?.status.name ?? message.status;
                  final failed = [
                    'finishedWithErrors',
                    'declined',
                    'canceledBySender',
                    'canceledByReceiver',
                    'recipientBusy',
                    'tooManyAttempts',
                    'interrupted',
                  ].contains(status);
                  return Align(
                    alignment: message.outgoing ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: wide ? 480 : constraints.maxWidth * .85),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.fromLTRB(16, 12, 10, 6),
                        decoration: BoxDecoration(
                          color: message.outgoing ? theme.colorScheme.primary.withValues(alpha: .16) : theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(message.text),
                            const SizedBox(height: 5),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  '${DateFormat.Hm().format(message.timestamp.toLocal())}${message.outgoing ? ' · ${textStatusLabel(status)}' : ''}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                IconButton(
                                  tooltip: t.neardockUI.copyText,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _copy(message.text),
                                  icon: const Icon(Icons.copy, size: 16),
                                ),
                                if (failed && device?.ip != null && !request)
                                  TextButton(
                                    onPressed: _sending ? null : () => _send(device!, retryText: message.text),
                                    child: Text(t.neardockUI.retry),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!request)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device?.ip != null ? t.neardockUI.localTextHelp : t.neardockUI.offlineTextHelp, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _composer,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(hintText: t.neardockUI.writeMessage),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: device?.ip != null && !_sending && _composer.text.trim().isNotEmpty ? () => _send(device!) : null,
                          child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Icon(Icons.send)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
        if (!wide || request) return thread;
        return Row(
          children: [
            SizedBox(width: 290, child: peerList),
            const VerticalDivider(width: 1),
            Expanded(child: thread),
          ],
        );
      },
    );
  }

  Widget _devicePicker(Map<String, Device> devices) {
    final localDevices = devices.values.where((d) => d.ip != null).toList();
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey(localDevices.map((d) => d.fingerprint).join('/')),
            initialValue: localDevices.any((d) => d.fingerprint == _fingerprint) ? _fingerprint : null,
            decoration: InputDecoration(labelText: t.neardockUI.sendTo),
            isExpanded: true,
            items: [
              for (final d in localDevices)
                DropdownMenuItem(
                  value: d.fingerprint,
                  child: Text(d.alias, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) {
              if (value != null) _select(value);
            },
          ),
        ),
        IconButton(tooltip: t.neardockUI.connectAddress, onPressed: _manualConnection, icon: const Icon(Icons.add)),
      ],
    );
  }
}

String textStatusLabel(String status) => switch (status) {
  'finished' => t.neardockUI.completed,
  'waiting' => t.neardockUI.waiting,
  'sending' => t.neardockUI.sending,
  'declined' => t.neardockUI.rejected,
  'canceledBySender' || 'canceledByReceiver' => t.neardockUI.cancelled,
  'recipientBusy' => t.neardockUI.busy,
  'tooManyAttempts' => t.neardockUI.tooManyAttempts,
  'interrupted' => t.neardockUI.interrupted,
  _ => t.neardockUI.failed,
};

Future<bool> confirmClearTextHistory(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.neardockUI.clearHistoryTitle),
        content: Text(t.neardockUI.clearHistoryHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.general.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.general.delete)),
        ],
      ),
    ) ??
    false;
