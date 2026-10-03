"""Check product identity, platform scope, and honest download metadata."""
from pathlib import Path
import json, re, subprocess, xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[2]
def read(path): return (root/path).read_text(encoding='utf-8')
def require(value, message):
    if not value: raise SystemExit(message)

require('version: 1.0.0+1' in read('app/pubspec.yaml'), 'App version mismatch')
require('MyAppVersion "1.0.0"' in read('support/scripts/compile_windows_exe-inno.iss'), 'Installer version mismatch')
require('Version="1.0.0.0"' in read('support/build/msix/content/AppxManifest.xml'), 'MSIX version mismatch')
require('applicationId "io.github.yazekt.neardock"' in read('app/android/app/build.gradle'), 'Android identity mismatch')
channel='io.github.yazekt.neardock/localsend'
require(channel in read('app/lib/util/native/channel/android_channel.dart'), 'Dart channel mismatch')
require(channel in read('app/android/app/src/main/kotlin/org/localsend/localsend_app/MainActivity.kt'), 'Kotlin channel mismatch')
require('\\\\Neardock\\\\settings.json' in read('app/lib/provider/persistence_provider.dart'), 'Settings must be isolated')
require('Get-AppxPackage LocalSend.App' not in read('support/scripts/compile_windows_exe-inno.iss'), 'Installer must not unregister LocalSend')
for path in (root/'app/assets/i18n').glob('*.json'):
    locale=json.loads(path.read_text(encoding='utf-8'))
    if 'appName' in locale: require(locale['appName']=='Neardock', f'Brand mismatch: {path}')
for path in (root/'branding').glob('*.svg'): ET.parse(path)
manifest=json.loads(read('website/releases.json'))
allowed={'windows-x64-installer','windows-x64-portable','windows-arm64-portable','android-arm32','android-arm64','android-x64'}
require(manifest['version']=='1.0.0', 'Download version mismatch')
for asset in manifest['assets']:
    require(asset['id'] in allowed, 'Unsupported download platform')
    require(asset.get('buildVerified') is True, 'Unverified build in download manifest')
    require(type(asset.get('deviceTested')) is bool, 'Missing physical-device status')
    require(isinstance(asset.get('signing'), str) and asset['signing'], 'Missing signing status')
    require(asset['url'].startswith('https://github.com/YazeKT/Neardock/releases/download/neardock-v1.0.0/'), 'Unexpected download destination')
    require(bool(re.fullmatch('[a-f0-9]{64}', asset['sha256'])), 'Missing checksum')
for path in (root/'.github/workflows').glob('*.yml'):
    require(not re.search('signpath|SIGNPATH|Azure|winget|build_cli|build_linux',path.read_text(),re.I), f'Upstream publishing workflow remains: {path}')
# Protocol code is intentionally unchanged; only embedded web branding may differ.
changed=subprocess.check_output(['git','diff','--name-only','af0416be50770a97760f7070684bc667b759a15c','--','packages/core/src','packages/localsend_isolates'],cwd=root,text=True)
require(not changed.strip(), 'Shared transfer implementation changed')
print('Neardock identity, protocol preservation, platform scope and release metadata checks passed.')
