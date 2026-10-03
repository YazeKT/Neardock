import 'package:localsend_app/provider/update_provider.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> release({String tag = 'neardock-v1.2.3', bool draft = false, bool prerelease = false}) => {
    'tag_name': tag,
    'draft': draft,
    'prerelease': prerelease,
    'assets': [
      {
        'name': 'Neardock-1.2.3-android-arm64.apk',
        'browser_download_url': 'https://github.com/YazeKT/Neardock/releases/download/neardock-v1.2.3/Neardock-1.2.3-android-arm64.apk',
      },
    ],
  };
  test('Stable releases compare numerically without downgrading or adopting previews', () {
    expect(isNewerRelease('1.10.0', '1.9.9'), isTrue);
    expect(isNewerRelease('1.0.0', '1.0.0'), isFalse);
    expect(isNewerRelease('1.0.0', '2.0.0'), isFalse);
    expect(isNewerRelease('2.0.0-beta', '1.0.0'), isFalse);
    expect(NeardockRelease.parse(release(draft: true)), isNull);
    expect(NeardockRelease.parse(release(prerelease: true)), isNull);
    expect(NeardockRelease.parse(release(tag: 'v1.2.3')), isNull);
  });
  test('Only the exact Neardock repository asset is selected', () {
    final parsed = NeardockRelease.parse(release())!;
    expect(parsed.assetFor('android-arm64.apk'), isNotNull);
    expect(parsed.assetFor('windows-x64.zip'), isNull);
    for (final value in [
      'http://github.com/YazeKT/Neardock/releases/download/neardock-v1.2.3/a.apk',
      'https://github.com.evil.example/YazeKT/Neardock/releases/download/neardock-v1.2.3/a.apk',
      'https://github.com/other/Neardock/releases/download/neardock-v1.2.3/a.apk',
      'https://github.com/YazeKT/Neardock/releases/download/neardock-v1.2.3/a.apk?next=evil',
    ]) {
      expect(NeardockRelease.validAssetUrl(value, 'neardock-v1.2.3', 'a.apk'), isFalse);
    }
  });
}
