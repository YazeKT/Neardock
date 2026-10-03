# Verification status

Evidence collected locally on 2-3 October 2026. The owner accepted the current application and authorised GitHub publication on 3 October 2026. Owner acceptance does not imply every detailed case below was tested.

## Neardock 1.0.0 checks

- Pinned Flutter 3.41.9 / Dart 3.11.5, Rust 1.97.1, JDK 17 and Windows build tools used.
- Full Flutter app suite: 89 passed. Final focused onboarding and receive cancellation checks: 5 passed after the last consent-flow correction.
- Flutter analysis: no issues. Formatting checked; one existing widget-test formatting issue corrected without changing test behaviour.
- Windows x64 release build passed, including the final bundled changelog. Inno Setup installer and portable ZIP packaging passed. Executables remain unsigned.
- Android ARM64 release build passed, including the final bundled changelog. APK signature verification passed with the existing private Neardock release key. In-place adb install -r succeeded on the connected Samsung SM-S906E; app data was not cleared.
- Windows and Android bundled changelogs cover the full application changes as packaged; the source changelog additionally records later distribution follow-up notes. Portable archive settings.json is empty, and no private signing files occur in the APK or ZIP. SHA-256 values are recorded in the release SHA256SUMS.txt.
- Actual final-build Windows Send, Receive, Chat, Clipboard and inline Settings screens captured. A separate portable screenshot profile avoided exposing owner filenames/history. Android Receive captured from the connected phone. No captured IP addresses or personal filenames are published.
- Website reviewed at desktop and 390-pixel mobile width, with working screenshot selection, loaded images and no horizontal overflow. Local links checked. Downloads distinguish build verification, signing and detailed device testing; unavailable architectures are not offered as downloads.
- Product identity, supported platforms, SVG assets and unchanged transfer-core checks passed. Staged source scanned for private keys, tokens, machine-specific paths, local configuration and personal review output; those files are excluded.

## Preserved baseline evidence

- Unmodified baseline Flutter app tests: 71 passed.
- Isolate tests: 17 passed, 4 existing skips.
- Rust clippy with full features passed; native Rust plugin check passed with an existing unused-import warning.
- Rust core tests on Windows: 77 passed, one existing timestamp-precision test failed. The unchanged baseline reproduces the failure (seven fractional digits versus nine expected). No protocol change was made to mask it.
- Mutual-TLS server info smoke check returned HTTP 200 and protocol 2.2; an unauthenticated request was rejected. This is not a complete cross-device transfer check.
- Baseline provenance and exact commit are recorded in UPSTREAM.md. Rust and isolate implementation sources remain unchanged.

## Owner review and pending detailed checks

The owner reported being happy with current app behaviour and approved publication. The apps have discovered each other locally. This is general acceptance, not an independently recorded matrix of hash-verified file transfers.

Detailed cases still pending: bidirectional file hashes; multiple-file/folder transfers; rejection, cancellation and network recovery on hardware; encrypted first-trust, repeat-trust and revocation flows on both platforms; the reported duplicate-name scenario after both apps restart; Android permissions, share intents and destination access; installer shortcuts, uninstall, updates and settings preservation; portable update behaviour; native Windows Share helper registration; tray sleep-state behaviour; protocol interoperability with other compatible apps; and end-to-end installation from a newer public GitHub release.

Remote Wi-Fi SSIDs are not exposed by the transfer protocol. Saved addresses are connection metadata, not authentication. Trust requires a verified encrypted certificate; unencrypted requests remain subject to review. Different installations/profiles with different certificates are intentionally distinct.

Windows ARM64 has no verified 1.0.0 download because the pinned SDK setup failed. Android ARM32/x64 hosted builds, signatures and packaging are verified; physical execution on those architectures remains pending. No iOS, Fire OS, macOS, Linux or CLI application is supported.

All four draft-release assets were downloaded from GitHub and matched the local SHA-256 values and GitHub asset digests. The product website deployed successfully and was checked in the browser. Hosted CI evidence is recorded below.

GitHub CI initially found two browser-transfer tests still asserting the previous product name. Their assertions were updated to Neardock; transport implementation remains unchanged. All four hosted CI jobs subsequently passed: formatting, Flutter analysis/app/isolate tests, Rust clippy/tests/plugin checks, and product metadata. Run: https://github.com/YazeKT/Neardock/actions/runs/37126295058 . Local browser-transfer integration tests also passed (9/9).

The hosted Windows ARM64 attempt could not resolve a Windows ARM64 Flutter 3.41.9 SDK archive during setup. This pinned-toolchain target remains unavailable; it was removed from the default build matrix rather than publishing x64 binaries as ARM64 or silently upgrading toolchains. See https://github.com/YazeKT/Neardock/actions/runs/37126381277 . Android ARM32/x64 hosted packaging subsequently passed.

Release provenance: the neardock-v1.0.0 tag and local binaries use commit 6d4dd0332b252c3667075494bb20eb67c56a25af. Successful hosted CI ran on 97a980e969b62601532daf63275531bfe13e46e7, which changes only the two browser page branding assertions and verification notes. Runtime app, core implementation and assets are identical. Later documentation/workflow publication commits do not alter the packaged app. The original release tag is retained.

Neardock 1.0.0 was published with the locally verified Windows x64 installer/portable ZIP, signed Android ARM64 APK and checksum file. Website manifest links only those published assets. Physical-device booleans stay false because the detailed acceptance matrix was not independently completed.

## Final distribution follow-up

- Windows x64 build and packaging passed on a clean GitHub runner. The hosted portable ZIP contains an x64 PE executable, clean settings and the packaged changelog, without private configuration.
- Hosted Android ARM32, ARM64 and x64 build jobs passed. All native shared libraries match their declared ABI. APK Signature Scheme v2 verification passed; the signing certificate matches the already-installed Neardock ARM64 app. Bundled changelog text matches the packaged source, allowing platform line-ending differences. No private signing files occur in these archives.
- Android ARM32 and x64 were added to the public release; the previously reviewed ARM64/Windows downloads remain unchanged. Checksums cover five app artifacts. Build verification is true; detailed device acceptance stays independently pending.
- The running Windows app's manual update check reached the public GitHub release and correctly reported the latest stable version. A future-version installation remains pending.
- Final About artwork, Yaze Media identity, compact inline Settings and five-tab screens were visibly reviewed. GitHub Pages and live Windows/Android download selection were checked in the browser.

Hosted evidence: https://github.com/YazeKT/Neardock/actions/runs/37126381277 (Windows x64 and Android jobs passed; unsupported Windows ARM64 SDK setup failed and is documented separately). All shared CI jobs passed on the published default branch: https://github.com/YazeKT/Neardock/actions/runs/37126599171 .
