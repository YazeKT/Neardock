# Installation and first transfer

## Windows

Choose x64 for most Intel/AMD PCs; choose ARM64 portable for Windows ARM devices.
Installer: run the Neardock EXE, select a destination, and launch from Start.
Portable: extract the entire ZIP to a writable folder and run neardock.exe.
Keep settings.json beside it to retain portable settings. Windows builds are
unsigned; check the release source and SHA256SUMS.txt before deciding to run them.
Installed settings live in %APPDATA%/Neardock/settings.json.

The retained optional MSIX helper supports Windows share integration. Unsigned
helper registration can require developer mode or package trust. A failed helper
registration does not prevent normal transfers or the existing SendTo integration.
Do not claim native Windows Share integration verified until registration and
sharing have been tested on the installed package.

## Android

Choose ARM64 for most recent phones, ARM32 for older devices, x64 for supported
Intel devices/emulators. Download the APK from Neardock's GitHub release. Allow
installation from the browser/file manager only as needed, install, then restore
your preferred installation permission. Grant the permissions requested by the
existing app for discovery and selected storage access. Neardock has its own
identity and does not replace LocalSend.

Future Neardock APKs must use the same signing key. Install over the existing
Neardock APK to preserve its sandbox; do not uninstall first. Developer device
verification uses `adb install -r path/to/Neardock.apk`.

## Transfer and troubleshooting

Connect both devices to the same trusted network and open both apps. Select files
or text in Send, choose the recipient and accept on the receiver. Confirm the
destination. Internet is unnecessary for local transfers.

If discovery fails, check guest-network/AP isolation, VPNs, device permissions,
and Windows firewall access on private networks. The default port is 53317 for
TCP and UDP. Do not expose this port to the public internet.

Two installed products can coexist, but LocalSend and Neardock share the default
port. Close one while using the other on the same device. Changing a port requires
corresponding peer configuration and does not guarantee automatic discovery.
Uninstalling Neardock must not unregister LocalSend. Preserve received files and
back up Neardock settings separately before any deliberate reset.
