# Neardock changelog

## 1.0.0 — 3 October 2026

Neardock's first release brings local file sharing, conversations and clipboard handoffs together in a dedicated Windows and Android application by Yaze Media.

### Interface and identity
- Introduce the Neardock name, upright geometric N logo and orange-and-ink artwork, including launcher, installer, tray, notification and website assets.
- Build a consistent Windows and Android interface with Send, Receive, Chat, Clipboard and Settings navigation.
- Standardise tab headings, content spacing and sizing; keep the logo stationary.
- Keep the sidebar focused on Neardock and its version, with Yaze Media ownership and links in Settings and About.
- Add prominent Neardock artwork to About and licensing screens.
- Give Windows and Android separate application, installation and settings identities.

### Sharing, conversations and remembered devices
- Add local Chat conversations with optional saved history.
- Add explicit Clipboard Paste, Copy and Send actions, including keyboard paste; never read the clipboard automatically.
- Remember each device's certificate identity, latest random name, model, platform and recent network addresses.
- Update remembered devices by identity instead of creating duplicates when the same installation reopens or changes its name/address.
- Offer Trust & accept on the first encrypted connection, with revocable trust and ordinary one-time review still available.
- Reduce repeated acceptance and completion prompts for trusted devices.
- Guard duplicate receive events, cancelled requests and stale consent; save incoming text only after acceptance.
- Preserve local discovery, encrypted transfers, default ports, permissions, destination handling and compatible transfer behaviour.

### Getting started and settings
- Add a short, skippable first-run welcome with an explicit optional GitHub update-check choice.
- Replace category page transitions with initially collapsed inline Settings sections and search.
- Add remembered-device properties and trust controls.
- Add a diagnostics panel with redacted event summaries, explicit Copy and Clear actions.
- Retain saved appearance, sharing and storage preferences.

### Updates, distribution and website
- Add optional automatic GitHub release checks and manual checks in Settings.
- Require explicit update download approval; verify architecture, release URL, byte count and SHA-256 digest before opening the system installer or providing a portable archive.
- Package unsigned Windows x64 installer and portable builds, and a release-signed Android ARM64 APK.
- Add Windows/Android build workflows, shared-core checks and GitHub Pages deployment.
- Build a responsive product website with real app screenshots, architecture-specific downloads, help, privacy, About and changelog pages.
- Use self-hosted typography, accessible navigation and reduced-motion support, without analytics or external font requests.
- Add installation, development, architecture, signing, release, security, privacy, contribution and verification documentation.
- Publish Apache 2.0 terms for Neardock code additions with Yaze Media copyright, separate brand-asset terms and required dependency acknowledgements.

### Release evidence and limits
- Windows x64 and Android ARM64 release builds and packaging verified locally. Android APK signature verification and in-place installation on the connected phone passed.
- App tests: 89 passed; final focused onboarding/cancellation checks: 5 passed. Flutter analysis passed. See docs/VERIFICATION.md for exact evidence and baseline exceptions.
- Owner accepted the current application for publication. Detailed transfer, installer lifecycle and interoperability checks remain separately tracked; owner approval does not imply every acceptance case was tested.
- Windows builds are unsigned. Windows ARM64, Android ARM32 and Android x64 downloads remain unavailable until verified.
- Sharing requires a reachable local network, which can include a compatible phone hotspot. Sharing across separate internet/mobile-data networks is not enabled.
- Ten researched feature ideas are recorded in docs/FEATURE_RESEARCH.md for later releases; they are not part of 1.0.0.

For code provenance and retained notices, see docs/UPSTREAM.md and NOTICE.md.

### Distribution follow-up — 3 October 2026

- Verify Windows x64 packaging on a clean GitHub runner.
- Add signed Android ARM32 and x64 APK downloads after hosted build, signing identity, native ABI and archive verification.
- Keep the reviewed Android ARM64 APK and Windows packages unchanged; expand the published checksum file and download selector to five app artifacts.
- Verify public download URLs, remote asset hashes and the running app's GitHub version check.
- Refresh the product website with final Windows and Android screenshots and publish it through GitHub Pages.
- Keep Windows ARM64 unavailable with the pinned toolchain; its SDK setup attempt failed and the default build matrix now contains verified targets only.

These distribution notes were added after the 1.0.0 app packages were produced. Their bundled changelog covers the complete application changes above; current architecture availability is listed on the website and release page.
