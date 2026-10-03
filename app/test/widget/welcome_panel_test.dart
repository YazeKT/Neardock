import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/widget/neardock/diagnostics_panel.dart';
import 'package:localsend_app/widget/neardock/welcome_panel.dart';
import 'package:refena_flutter/refena_flutter.dart';

void main() {
  test('Diagnostics omit private values and avoid treating addresses as status codes', () {
    expect(safeRequestDiagnostic('POST /upload?pin=1234 192.168.1.2 secret-message status: 200'), 'POST · HTTP 200');
    expect(safeRequestDiagnostic('Connected to 192.168.1.202 files Private.docx'), 'Request event');
    expect(safeRequestDiagnostic('password=abc text=My private message'), 'Request event');
  });
  testWidgets('Welcome explains manual sharing and persists explicit update opt-out at completion', (tester) async {
    final persistence = _WelcomePersistence();
    var completed = false;
    await tester.pumpWidget(
      RefenaScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: MaterialApp(
          home: Scaffold(body: WelcomePanel(onComplete: () async => completed = true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connect your devices'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Make your first transfer'), findsOneWidget);
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(completed, true);
    expect(persistence.automatic, false);
  });
  testWidgets('Skip remains available without permission or device setup', (tester) async {
    final persistence = _WelcomePersistence();
    var completed = false;
    await tester.pumpWidget(
      RefenaScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: MaterialApp(
          home: Scaffold(body: WelcomePanel(onComplete: () async => completed = true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    await tester.ensureVisible(find.text('Skip setup'));
    await tester.tap(find.text('Skip setup'));
    await tester.pumpAndSettle();
    expect(completed, true);
  });
}

class _WelcomePersistence implements PersistenceService {
  bool automatic = true;
  @override
  Future<void> setAutomaticUpdatesEnabled(bool enabled) async {
    automatic = enabled;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
