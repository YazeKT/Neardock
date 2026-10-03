// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'dart:async';
import 'dart:convert';
import 'package:localsend_app/model/persistence/known_device.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:refena_flutter/refena_flutter.dart';

final knownDevicesProvider = NotifierProvider<KnownDevicesNotifier, List<KnownDevice>>((ref) => KnownDevicesNotifier());

/// Identity is the certificate fingerprint, never an alias, address or network name.
class KnownDevicesNotifier extends Notifier<List<KnownDevice>> {
  Future<void> _writes = Future.value();

  @override
  List<KnownDevice> init() {
    final devices = <String, KnownDevice>{};
    for (final raw in ref.read(persistenceProvider).getKnownDevices()) {
      try {
        final device = KnownDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (device.fingerprint.isNotEmpty) devices[device.fingerprint] = device;
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    return devices.values.toList();
  }

  @override
  String describeState(List<KnownDevice> state) => '${state.length} known devices';

  KnownDevice? find(String fingerprint) {
    for (final device in state) {
      if (device.fingerprint == fingerprint) return device;
    }
    return null;
  }

  bool acceptsVerified(String? certificateFingerprint) =>
      certificateFingerprint != null && certificateFingerprint.isNotEmpty && find(certificateFingerprint)?.trusted == true;

  void observe(Device device) {
    if (device.fingerprint.isEmpty) return;
    final old = find(device.fingerprint);
    final now = DateTime.now().toUtc();
    final addresses = <String>{
      if (device.ip != null) device.ip!,
      for (final channel in device.channels)
        if (channel is HttpChannel) channel.host,
      ...?old?.addresses,
    }.take(16).toList();
    final updated = KnownDevice(
      fingerprint: device.fingerprint,
      alias: device.alias,
      model: device.deviceModel,
      type: device.deviceType.name,
      addresses: addresses,
      firstSeen: old?.firstSeen ?? now,
      lastSeen: now,
      trusted: old?.trusted ?? false,
    );
    state = [...state.where((entry) => entry.fingerprint != device.fingerprint), updated];
    unawaited(_save());
  }

  Future<void> setTrusted(String fingerprint, bool value) async {
    state = [for (final device in state) device.fingerprint == fingerprint ? device.withTrust(value) : device];
    await _save();
  }

  Future<void> forget(String fingerprint) async {
    state = state.where((device) => device.fingerprint != fingerprint).toList();
    await _save();
  }

  Future<void> _save() {
    _writes = _writes
        .catchError((Object _) {})
        .then((_) => ref.read(persistenceProvider).setKnownDevices(state.map((device) => jsonEncode(device.toJson())).toList()));
    unawaited(_writes.catchError((Object _) {}));
    return _writes;
  }
}
