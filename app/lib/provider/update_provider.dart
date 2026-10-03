// Copyright 2026 Yaze Media. Licensed under the Apache License, Version 2.0.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:localsend_app/provider/version_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

const neardockRepository = 'YazeKT/Neardock';
const neardockReleasesUrl = 'https://github.com/$neardockRepository/releases';

class NeardockRelease {
  final String version;
  final String tag;
  final List<Map<String, dynamic>> assets;
  const NeardockRelease(this.version, this.tag, this.assets);

  static NeardockRelease? parse(Map<String, dynamic> json) {
    final tag = json['tag_name'];
    if (json['draft'] != false || json['prerelease'] != false || tag is! String) return null;
    final match = RegExp(r'^neardock-v(\d+\.\d+\.\d+)$').firstMatch(tag);
    if (match == null || json['assets'] is! List) return null;
    final assets = (json['assets'] as List).whereType<Map<String, dynamic>>().toList();
    return NeardockRelease(match.group(1)!, tag, assets);
  }

  Map<String, dynamic>? assetFor(String suffix) {
    final name = 'Neardock-$version-$suffix';
    for (final asset in assets) {
      if (asset['name'] == name && validAssetUrl(asset['browser_download_url'], tag, name)) return asset;
    }
    return null;
  }

  static bool validAssetUrl(Object? value, String tag, String name) {
    if (value is! String) return false;
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'github.com' &&
        uri.userInfo.isEmpty &&
        uri.query.isEmpty &&
        uri.fragment.isEmpty &&
        uri.path == '/$neardockRepository/releases/download/$tag/$name';
  }
}

bool isNewerRelease(String candidate, String current) {
  final format = RegExp(r'^\d+\.\d+\.\d+$');
  if (!format.hasMatch(candidate) || !format.hasMatch(current)) return false;
  final next = candidate.split('.').map(int.parse).toList();
  final installed = current.split('.').map(int.parse).toList();
  for (var index = 0; index < 3; index++) {
    if (next[index] != installed[index]) return next[index] > installed[index];
  }
  return false;
}

class NeardockUpdateState {
  final bool busy;
  final String message;
  final NeardockRelease? release;
  const NeardockUpdateState({this.busy = false, this.message = 'Updates come from Neardock GitHub releases.', this.release});
}

final neardockUpdateProvider = NotifierProvider<NeardockUpdateNotifier, NeardockUpdateState>((ref) => NeardockUpdateNotifier());

class NeardockUpdateNotifier extends Notifier<NeardockUpdateState> {
  @override
  NeardockUpdateState init() => const NeardockUpdateState();

  Future<void> check() async {
    if (state.busy) return;
    state = const NeardockUpdateState(busy: true, message: 'Checking Neardock releases…');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final response = await _get(client, Uri.parse('https://api.github.com/repos/$neardockRepository/releases/latest'));
      if (response.statusCode == 404) {
        await response.drain<void>();
        state = const NeardockUpdateState(message: 'No published Neardock release is available yet.');
        return;
      }
      if (response.statusCode != 200) throw const HttpException('Release check unavailable');
      final bytes = await _readBounded(response, 2 * 1024 * 1024);
      final release = NeardockRelease.parse(jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>);
      if (release == null) {
        state = const NeardockUpdateState(message: 'The published release format is unsupported. Check the releases page.');
        return;
      }
      final installed = await ref.future(versionProvider);
      state = isNewerRelease(release.version, installed.version)
          ? NeardockUpdateState(message: 'Neardock ${release.version} is available.', release: release)
          : const NeardockUpdateState(message: 'You have the latest published stable version.');
    } catch (_) {
      state = const NeardockUpdateState(message: 'Could not check GitHub. Your app still works offline; try again later.');
    } finally {
      client.close(force: true);
    }
  }

  /// Download only after an explicit action. Installation remains an OS prompt.
  Future<File?> download({required bool portable}) async {
    final release = state.release;
    if (release == null || state.busy) return null;
    state = NeardockUpdateState(busy: true, message: 'Downloading and verifying the update…', release: release);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    Directory? staging;
    try {
      final suffix = await _platformSuffix(portable);
      final asset = release.assetFor(suffix);
      if (asset == null) throw const FormatException('No compatible verified update');
      final digest = asset['digest'];
      if (digest is! String || !RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(digest)) {
        throw const FormatException('Release asset has no GitHub SHA-256 digest');
      }
      final size = asset['size'];
      if (size is! int || size <= 0 || size > 512 * 1024 * 1024) throw const FormatException('Invalid update size');
      final response = await _get(client, Uri.parse(asset['browser_download_url'] as String));
      if (response.statusCode != 200) throw const HttpException('Download unavailable');
      staging = await (await getTemporaryDirectory()).createTemp('neardock-update-');
      final file = File('${staging.path}${Platform.pathSeparator}${asset['name']}');
      final sink = file.openWrite();
      var received = 0;
      try {
        await for (final bytes in response.timeout(const Duration(seconds: 60))) {
          received += bytes.length;
          if (received > size) throw const FormatException('Update exceeds declared size');
          sink.add(bytes);
        }
      } finally {
        await sink.close();
      }
      final actual = (await sha256.bind(file.openRead()).first).toString();
      if (received != size || actual != digest.substring(7)) throw const FormatException('Update integrity check failed');
      state = NeardockUpdateState(message: 'Update verified. Complete installation in the system installer.', release: release);
      return file;
    } catch (_) {
      if (staging != null && await staging.exists()) await staging.delete(recursive: true);
      state = NeardockUpdateState(
        message: 'Could not obtain a compatible, verified update. Check the releases page or try again later.',
        release: release,
      );
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _platformSuffix(bool portable) async {
    if (Platform.isWindows) {
      final arch = '${Platform.environment['PROCESSOR_ARCHITECTURE']} ${Platform.environment['PROCESSOR_ARCHITEW6432']}'.toUpperCase();
      if (arch.contains('ARM64')) return 'windows-arm64.zip';
      return portable ? 'windows-x64.zip' : 'windows-x64-unsigned.exe';
    }
    if (Platform.isAndroid) {
      final abis = (await DeviceInfoPlugin().androidInfo).supportedAbis;
      if (abis.contains('arm64-v8a')) return 'android-arm64.apk';
      if (abis.contains('armeabi-v7a')) return 'android-arm32.apk';
      if (abis.contains('x86_64')) return 'android-x64.apk';
    }
    throw UnsupportedError('No supported update architecture');
  }

  Future<HttpClientResponse> _get(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 20));
    request.headers.set(HttpHeaders.userAgentHeader, 'Neardock-update-check');
    request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    return request.close().timeout(const Duration(seconds: 30));
  }

  Future<List<int>> _readBounded(HttpClientResponse response, int limit) async {
    final result = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 30))) {
      if (result.length + chunk.length > limit) throw const FormatException('Response too large');
      result.addAll(chunk);
    }
    return result;
  }
}
