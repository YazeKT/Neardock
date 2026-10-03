// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'dart:async';
import 'dart:convert';
import 'package:localsend_app/model/persistence/conversation_message.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

final conversationProvider = NotifierProvider<ConversationNotifier, List<ConversationMessage>>((ref) => ConversationNotifier());

/// Text inbox shared by Chat and Clipboard. Networking remains in the transfer providers.
class ConversationNotifier extends Notifier<List<ConversationMessage>> {
  Future<void> _writes = Future.value();
  late bool saveHistory;

  @override
  List<ConversationMessage> init() {
    final persistence = ref.read(persistenceProvider);
    saveHistory = persistence.getConversationHistoryEnabled();
    if (!saveHistory) return [];
    final messages = <ConversationMessage>[];
    for (final raw in persistence.getConversationMessages()) {
      try {
        var message = ConversationMessage.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (message.outgoing && ['waiting', 'sending'].contains(message.status)) {
          message = message.withStatus('interrupted');
        }
        if (!messages.any((existing) => existing.id == message.id)) messages.add(message);
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    return messages;
  }

  @override
  String describeState(List<ConversationMessage> state) => '${state.length} conversation messages';

  void add(ConversationMessage message) {
    if (state.any((existing) => existing.id == message.id)) return;
    state = [...state, message];
    unawaited(_save());
  }

  void updateStatus(String id, String status) {
    if (!state.any((message) => message.id == id && message.status != status)) return;
    state = [for (final message in state) message.id == id ? message.withStatus(status) : message];
    unawaited(_save());
  }

  Future<void> setHistoryEnabled(bool enabled) async {
    saveHistory = enabled;
    // Rebuild settings consumers even if the messages themselves did not change.
    state = [...state];
    await ref.read(persistenceProvider).setConversationHistoryEnabled(enabled);
    await _save();
  }

  Future<void> clear({String? fingerprint}) async {
    state = fingerprint == null ? [] : state.where((message) => message.peerFingerprint != fingerprint).toList();
    await _save();
  }

  Future<void> _save() {
    // Serialize writes and read the latest state at execution time, so a queued
    // write cannot restore history after the user disables or clears it.
    _writes = _writes.catchError((Object _) {}).then((_) async {
      await ref
          .read(persistenceProvider)
          .setConversationMessages(
            saveHistory ? state.map((message) => jsonEncode(message.toJson())).toList() : [],
          );
    });
    unawaited(_writes.catchError((Object _) {}));
    return _writes;
  }
}
