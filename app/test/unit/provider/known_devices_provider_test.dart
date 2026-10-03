import 'dart:convert';
import 'package:localsend_app/provider/known_devices_provider.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:test/test.dart';

class MemoryPersistence implements PersistenceService {
  List<String> devices = [];
  @override
  List<String> getKnownDevices() => devices;
  @override
  Future<void> setKnownDevices(List<String> value) async {
    devices = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Device peer(String fingerprint, {String alias = 'Neat Avocado', String ip = '192.168.1.2'}) => Device(
  signalingId: null,
  ip: ip,
  version: '2.2',
  port: 53317,
  https: true,
  fingerprint: fingerprint,
  alias: alias,
  deviceModel: 'Phone',
  deviceType: DeviceType.mobile,
  download: true,
  channels: [HttpChannel(host: ip, port: 53317, https: true)],
);

void main() {
  late MemoryPersistence persistence;
  late RefenaContainer ref;
  setUp(() {
    persistence = MemoryPersistence();
    ref = RefenaContainer(overrides: [persistenceProvider.overrideWithValue(persistence)]);
  });
  tearDown(() => ref.disposeContainer());

  test('Repeated discovery merges one identity, updated alias and addresses without trusting it', () async {
    final store = ref.notifier(knownDevicesProvider);
    store.observe(peer('A'));
    final firstSeen = store.state.single.firstSeen;
    store.observe(peer('A', alias: 'New alias', ip: '192.168.1.8'));
    await store.setTrusted('A', false);
    expect(store.state.length, 1);
    expect(store.state.single.firstSeen, firstSeen);
    expect(store.state.single.alias, 'New alias');
    expect(store.state.single.addresses, ['192.168.1.8', '192.168.1.2']);
    expect(store.acceptsVerified('A'), false);
    expect(persistence.devices.length, 1);
  });

  test('Trust requires exact verified identity, never same IP or alias or unencrypted claimed identity', () async {
    final store = ref.notifier(knownDevicesProvider);
    store.observe(peer('A'));
    await store.setTrusted('A', true);
    store.observe(peer('B'));
    expect(store.acceptsVerified('A'), true);
    expect(store.acceptsVerified('B'), false);
    expect(store.acceptsVerified(null), false);
    expect(store.acceptsVerified(''), false);
    expect(store.state.length, 2);
  });

  test('Trust survives restart, address changes preserve trust, revocation survives queued writes', () async {
    final store = ref.notifier(knownDevicesProvider);
    store.observe(peer('A'));
    await store.setTrusted('A', true);
    final restarted = RefenaContainer(overrides: [persistenceProvider.overrideWithValue(persistence)]);
    expect(restarted.notifier(knownDevicesProvider).acceptsVerified('A'), true);
    restarted.disposeContainer();
    store.observe(peer('A', ip: '10.0.0.4'));
    await store.setTrusted('A', false);
    expect(jsonDecode(persistence.devices.single)['trusted'], false);
    expect(store.acceptsVerified('A'), false);
  });

  test('Forget cannot be undone by queued discovery writes; malformed saved metadata is ignored', () async {
    persistence.devices = [
      '{broken',
      jsonEncode({'fingerprint': 123}),
    ];
    final store = ref.notifier(knownDevicesProvider);
    expect(store.state, isEmpty);
    store.observe(peer('A'));
    await store.forget('A');
    expect(store.state, isEmpty);
    expect(persistence.devices, isEmpty);
  });
}
