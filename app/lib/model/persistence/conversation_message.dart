// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
class ConversationMessage {
  final String id;
  final String peerFingerprint;
  final String peerAlias;
  final String text;
  final bool outgoing;
  final DateTime timestamp;
  final String status;

  const ConversationMessage({
    required this.id,
    required this.peerFingerprint,
    required this.peerAlias,
    required this.text,
    required this.outgoing,
    required this.timestamp,
    required this.status,
  });

  ConversationMessage withStatus(String value) => ConversationMessage(
    id: id,
    peerFingerprint: peerFingerprint,
    peerAlias: peerAlias,
    text: text,
    outgoing: outgoing,
    timestamp: timestamp,
    status: value,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'peerFingerprint': peerFingerprint,
    'peerAlias': peerAlias,
    'text': text,
    'outgoing': outgoing,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'status': status,
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) => ConversationMessage(
    id: json['id'] as String,
    peerFingerprint: json['peerFingerprint'] as String,
    peerAlias: json['peerAlias'] as String,
    text: json['text'] as String,
    outgoing: json['outgoing'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
    status: json['status'] as String,
  );

  @override
  String toString() => 'ConversationMessage(id: $id, outgoing: $outgoing, status: $status)';
}
