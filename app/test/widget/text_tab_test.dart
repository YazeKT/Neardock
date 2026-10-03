import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/model/persistence/conversation_message.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/pages/tabs/text_tab.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/logging/discovery_logs_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/widget/watcher/shortcut_watcher.dart';
import 'package:localsend_isolates/isolate.dart';
import 'package:refena_flutter/refena_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Clipboard contents are read or written only by explicit Paste, Copy or keyboard paste', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final clipboardCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData' || call.method == 'Clipboard.setData') clipboardCalls.add(call.method);
      if (call.method == 'Clipboard.hasStrings') return {'value': true};
      if (call.method == 'Clipboard.getData') return {'text': 'Manual paste example'};
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final persistence = _TextPersistence();
    await tester.pumpWidget(
      RefenaScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          nearbyDevicesProvider.overrideWithNotifier(
            (ref) => NearbyDevicesService(
              isolateController: _UnusedIsolate(),
              favoriteService: FavoritesService(persistence),
              discoveryLogs: DiscoveryLogger(),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ShortcutWatcher(child: TextTab(clipboard: true))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(clipboardCalls, isEmpty);
    await tester.tap(find.text('Paste text'));
    await tester.pumpAndSettle();
    expect(clipboardCalls, ['Clipboard.getData']);
    expect(find.text('Manual paste example'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Copy text').first);
    await tester.tap(find.byTooltip('Copy text').first);
    await tester.pumpAndSettle();
    expect(clipboardCalls, ['Clipboard.getData', 'Clipboard.setData']);
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(clipboardCalls, ['Clipboard.getData', 'Clipboard.setData', 'Clipboard.getData']);
    expect(find.byType(TextTab), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TextPersistence implements PersistenceService {
  @override
  bool getConversationHistoryEnabled() => true;
  @override
  List<String> getConversationMessages() => [
    jsonEncode(
      ConversationMessage(
        id: 'receive:test',
        peerFingerprint: 'test-peer',
        peerAlias: 'Test device',
        text: 'Received example',
        outgoing: false,
        timestamp: DateTime.utc(2026, 10, 2),
        status: 'received',
      ).toJson(),
    ),
  ];
  @override
  List<FavoriteDevice> getFavorites() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedIsolate implements IsolateController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
