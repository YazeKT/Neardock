# Neardock

**Share files between nearby devices.**

Neardock is a free, open-source file-sharing app for **Windows and Android**.
Send files and messages across your local network, without an account or an
internet connection for local transfers. The initial 1.0.0 release preserves the
existing transfer engine while introducing a Neardock interface, local text conversations,
and manual clipboard sharing.

[Website](https://yazekt.github.io/Neardock/) Â· [Releases](https://github.com/YazeKT/Neardock/releases) Â· [Help](docs/INSTALLATION.md)

## Downloads and verification

Download the Neardock Windows x64 installer or portable ZIP, or the Android ARM64 APK, from
[the 1.0.0 release](https://github.com/YazeKT/Neardock/releases/tag/neardock-v1.0.0). Other
architectures remain unavailable until verified.
Windows packages are unsigned unless the release notes explicitly say otherwise.
Android release APKs use Neardock's own signing key. Availability and verification
are recorded in [VERIFICATION.md](docs/VERIFICATION.md).

## First transfer

1. Install Neardock on your Windows PC and Android device.
2. Connect both devices to the same trusted local network; allow Windows firewall access.
3. Open Neardock on both devices. Choose a recipient and files in Send, then press Send.
   Use Chat for conversations and Clipboard for manual paste-and-send text.
4. Accept the transfer on the receiving device and check the selected destination.

Guest Wi-Fi isolation and VPNs can prevent discovery. See [installation and troubleshooting](docs/INSTALLATION.md).
Neardock preserves the LocalSend protocol and is intended to exchange files with compatible LocalSend devices.

## Project documentation

- [Development and builds](docs/DEVELOPMENT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [New interface and local review](docs/UI_REVIEW.md)
- [Signing and releases](docs/RELEASING.md)
- [Privacy](PRIVACY.md), [security](SECURITY.md), and [contributing](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md) and [changelog](CHANGELOG.md)
- [Upstream provenance](docs/UPSTREAM.md), [notices](NOTICE.md), and [third-party dependencies](THIRD_PARTY_NOTICES.md)

## Foundation and licence

Maintained by **Yaze Media** (GitHub: YazeKT). Based on LocalSend v1.18.2, commit
`af0416be50770a97760f7070684bc667b759a15c`, by Tien Do Nam and contributors.
Code is licensed under [Apache 2.0](LICENSE). New Neardock code: Copyright 2026 Yaze Media.
Brand assets have [separate terms](BRAND_ASSETS.md). Upstream copyright and contributor credit are retained.
Only Windows and Android are Neardock release targets; other inherited source is retained for shared-code stability.
## Current interface refinement

Neardock 1.0.0 includes first-run setup, remembered device properties, encrypted device trust, compact inline Settings, diagnostics and optional GitHub update checks. See [device trust](docs/DEVICE_TRUST.md), [updates](docs/UPDATES.md), and [feature research](docs/FEATURE_RESEARCH.md). The ten researched features are recommendations, not implemented release promises. Cross-network internet sharing is not enabled; a compatible phone hotspot can provide a shared local network.

