# Verification status

Evidence collected locally on 2–3 October 2026. The owner accepted the current application and authorised GitHub publication on 3 October 2026. Owner acceptance does not imply every detailed case below was tested.

## Neardock 1.0.0 checks

- Pinned Flutter 3.41.9 / Dart 3.11.5, Rust 1.97.1, JDK 17 and Windows build tools used.
- Full Flutter app suite: 89 passed. Final focused onboarding and receive cancellation checks: 5 passed after the last consent-flow correction.
- Flutter analysis: no issues. Formatting checked; one existing widget-test formatting issue corrected without changing test behaviour.
- Windows x64 release build passed, including the final bundled changelog. Inno Setup installer and portable ZIP packaging passed. Executables remain unsigned.
- Android ARM64 release build passed, including the final bundled changelog. APK signature verification passed with the existing private Neardock release key. In-place adb install -r succeeded on the connected Samsung SM-S906E; app data was not cleared.
- Windows and Android bundled changelogs match the source. Portable archive settings.json is empty, and no private signing files occur in the APK or ZIP. SHA-256 values are recorded in the release SHA256SUMS.txt.
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

Windows ARM64 and Android ARM32/x64 are configured build targets but have no verified 1.0.0 downloads yet. Corresponding execution and packaging remain pending. No iOS, Fire OS, macOS, Linux or CLI application is supported.

GitHub release asset hashes, source commit and hosted website will be checked during publication. Hosted CI results are separate from the completed local checks and must be reported accurately.
