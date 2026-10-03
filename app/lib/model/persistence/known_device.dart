// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
class KnownDevice {
  final String fingerprint;
  final String alias;
  final String? model;
  final String type;
  final List<String> addresses;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final bool trusted;

  const KnownDevice({
    required this.fingerprint,
    required this.alias,
    required this.model,
    required this.type,
    required this.addresses,
    required this.firstSeen,
    required this.lastSeen,
    required this.trusted,
  });

  KnownDevice withTrust(bool value) => KnownDevice(
    fingerprint: fingerprint,
    alias: alias,
    model: model,
    type: type,
    addresses: addresses,
    firstSeen: firstSeen,
    lastSeen: lastSeen,
    trusted: value,
  );

  Map<String, dynamic> toJson() => {
    'fingerprint': fingerprint,
    'alias': alias,
    'model': model,
    'type': type,
    'addresses': addresses,
    'firstSeen': firstSeen.toIso8601String(),
    'lastSeen': lastSeen.toIso8601String(),
    'trusted': trusted,
  };

  factory KnownDevice.fromJson(Map<String, dynamic> json) => KnownDevice(
    fingerprint: json['fingerprint'] as String,
    alias: json['alias'] as String,
    model: json['model'] as String?,
    type: json['type'] as String,
    addresses: (json['addresses'] as List).cast<String>(),
    firstSeen: DateTime.parse(json['firstSeen'] as String),
    lastSeen: DateTime.parse(json['lastSeen'] as String),
    trusted: json['trusted'] == true,
  );
}
