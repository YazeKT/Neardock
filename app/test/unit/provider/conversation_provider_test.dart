import 'dart:convert';
import 'package:localsend_app/model/persistence/conversation_message.dart';
import 'package:localsend_app/provider/conversation_provider.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:test/test.dart';

void main() {
  late _MemoryPersistence persistence;
  late RefenaContainer ref;
  setUp(() {
    persistence = _MemoryPersistence();
    ref = RefenaContainer(overrides: [persistenceProvider.overrideWithValue(persistence)]);
  });
  tearDown(() => ref.disposeContainer());

  test('Deduplicates receive events and separates devices sharing an alias', () async {
    final store = ref.notifier(conversationProvider);
    store.add(_message('receive:1', 'device-A'));
    store.add(_message('receive:1', 'device-A'));
    store.add(_message('receive:2', 'device-B'));
    await store.setHistoryEnabled(true);
    expect(store.state.length, 2);
    expect(persistence.messages.length, 2);
    expect(store.state.map((m) => m.peerFingerprint), ['device-A', 'device-B']);
  });

  test('Disabling history cannot be undone by a queued message write', () async {
    final store = ref.notifier(conversationProvider);
    store.add(_message('receive:1', 'device-A'));
    await store.setHistoryEnabled(false);
    store.add(_message('receive:2', 'device-A'));
    await store.setHistoryEnabled(false);
    expect(persistence.messages, isEmpty);
    expect(store.state.length, 2);
    final restarted = RefenaContainer(overrides: [persistenceProvider.overrideWithValue(persistence)]);
    expect(restarted.read(conversationProvider), isEmpty);
    restarted.disposeContainer();
  });

  test('Clearing one conversation preserves other devices and survives relaunch', () async {
    final store = ref.notifier(conversationProvider);
    store.add(_message('receive:1', 'device-A'));
    store.add(_message('receive:2', 'device-B'));
    await store.clear(fingerprint: 'device-A');
    final restarted = RefenaContainer(overrides: [persistenceProvider.overrideWithValue(persistence)]);
    expect(restarted.read(conversationProvider).single.peerFingerprint, 'device-B');
    restarted.disposeContainer();
  });

  test('Relaunch marks incomplete sends interrupted, without fabricating completion', () {
    persistence.messages = [jsonEncode(_message('send:1', 'device-A', outgoing: true, status: 'waiting').toJson())];
    expect(ref.read(conversationProvider).single.status, 'interrupted');
  });

  test('Persists the final transfer result and clear-all removes saved text', () async {
    final store = ref.notifier(conversationProvider);
    store.add(_message('send:1', 'device-A', outgoing: true, status: 'waiting'));
    store.updateStatus('send:1', 'declined');
    await store.setHistoryEnabled(true);
    expect(jsonDecode(persistence.messages.single)['status'], 'declined');
    await store.clear();
    expect(store.state, isEmpty);
    expect(persistence.messages, isEmpty);
  });

  test('Invalid history entries do not hide valid messages', () {
    persistence.messages = ['bad json', '{}', jsonEncode(_message('receive:1', 'device-A').toJson())];
    expect(ref.read(conversationProvider).single.id, 'receive:1');
  });
}

ConversationMessage _message(String id, String fingerprint, {bool outgoing = false, String status = 'received'}) => ConversationMessage(
  id: id,
  peerFingerprint: fingerprint,
  peerAlias: 'Same device name',
  text: 'Text to transfer',
  outgoing: outgoing,
  timestamp: DateTime.utc(2026, 10, 2),
  status: status,
);

class _MemoryPersistence implements PersistenceService {
  bool enabled = true;
  List<String> messages = [];
  @override
  bool getConversationHistoryEnabled() => enabled;
  @override
  List<String> getConversationMessages() => messages;
  @override
  Future<void> setConversationHistoryEnabled(bool value) async {
    enabled = value;
  }

  @override
  Future<void> setConversationMessages(List<String> value) async {
    messages = [...value];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
