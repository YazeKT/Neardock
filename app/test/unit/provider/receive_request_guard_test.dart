import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/provider/network/server/controller/receive_controller.dart';
import 'package:localsend_app/provider/network/server/server_utils.dart';
import 'package:localsend_isolates/isolate.dart';
import 'package:localsend_isolates/rust/api/model.dart';
import 'package:localsend_isolates/rust/api/server.dart';

HttpServerPrepareUploadEvent request(String id) => HttpServerPrepareUploadEvent(
  sessionId: id,
  ip: '192.168.1.2',
  certFingerprint: 'identity-A',
  files: {},
  info: const RegisterDtoV2(
    alias: 'Neat Avocado',
    version: '2.2',
    fingerprint: 'identity-A',
    port: 53317,
    protocol: ProtocolType.https,
    download: true,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Duplicate prepared event is ignored before state, settings, permissions or UI are accessed again', () async {
    var accesses = 0;
    final sentinel = StateError('Test boundary: settings access');
    final controller = ReceiveController(
      ServerUtils(
        refFunc: () {
          accesses++;
          throw sentinel;
        },
        getState: () => throw StateError('offline'),
        getStateOrNull: () => null,
        setState: (_) {},
      ),
    );
    await expectLater(controller.onPrepareUpload(request('one')), throwsA(same(sentinel)));
    expect(accesses, 1);
    await controller.onPrepareUpload(request('one'));
    expect(accesses, 1);
    await expectLater(controller.onPrepareUpload(request('two')), throwsA(same(sentinel)));
    expect(accesses, 2);
  });
  test('An aborted request arriving before preparation cannot create consent or read private settings', () async {
    var accesses = 0;
    final controller = ReceiveController(
      ServerUtils(
        refFunc: () {
          accesses++;
          throw StateError('No access permitted');
        },
        getState: () => throw StateError('offline'),
        getStateOrNull: () => null,
        setState: (_) {},
      ),
    );
    controller.onPrepareUploadAborted(HttpServerPrepareUploadAbortedEvent(sessionId: 'aborted'));
    await controller.onPrepareUpload(request('aborted'));
    expect(accesses, 0);
  });
}
